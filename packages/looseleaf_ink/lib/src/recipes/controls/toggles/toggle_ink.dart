import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// shadcn's toggle variants; `id` is the upstream name (`primary` is
/// upstream's `default`).
enum ToggleVariant {
  primary('default'),
  outline('outline');

  const ToggleVariant(this.id);

  /// The upstream name.
  final String id;
}

/// The marker a pressed toggle is filled with.
enum ToggleTone {
  hi(PaintKey.hi),
  marker(PaintKey.marker);

  const ToggleTone(this.paint);

  /// The fill paint.
  final PaintKey paint;
}

/// Toggle recipe params.
///
/// Mirrors `ToggleParams` in `src/lib/ink/recipes/toggle-ink.ts`.
final class ToggleParams {
  /// Params.
  const ToggleParams({
    required this.variant,
    this.disabled = false,
    this.tone,
    this.joined = false,
    this.vertical = false,
    this.invalid = false,
  });

  final ToggleVariant variant;
  final bool disabled;

  /// The pressed fill, [ToggleTone.hi] when null.
  final ToggleTone? tone;

  /// An item of a joined toggle group: draws a seam instead of a box.
  final bool joined;

  /// The joined group is stacked vertically.
  final bool vertical;
  final bool invalid;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'variant': variant.id,
    if (disabled) 'disabled': true,
    'tone': ?tone?.name,
    if (joined) 'joined': true,
    if (vertical) 'vertical': true,
    if (invalid) 'invalid': true,
  };
}

/// The toggle: a whisper box (or an inked one for outline), a highlighter
/// wash and drop line on hover, a marker fill when pressed; joined items draw
/// only a seam.
///
/// Mirrors `toggleRecipe` in `src/lib/ink/recipes/toggle-ink.ts`.
final Recipe<ToggleParams> toggleRecipe = defineRecipe<ToggleParams>(
  id: 'toggle',
  kind: 'toggle',
  layers: const [
    LayerName.rest,
    LayerName.hover,
    LayerName.checked,
    LayerName.focus,
  ],
  lazy: const [LayerName.focus],
  pad: 12,
  draw: _draw,
);

final class _Toggle {
  _Toggle(this.ink, Box size, this.params, RecipeContext ctx)
    : w = size.w,
      h = size.h,
      calm = ctx.calm,
      rtl = ctx.dir == Dir.rtl {
    invalid = params.invalid && !params.disabled && !params.joined;
    r = clamp(math.min(w, h) * 0.09, 2.2, 4.4);
    final inset = switch (params.joined) {
      true => 0.9,
      false => 0.5,
    };
    body = roundRectPoly(
      inset,
      inset,
      w - 2 * inset,
      h - 2 * inset,
      switch (params.joined) {
        true => 2,
        false => r,
      },
    );
    wide = w > 360;
  }

  final Ink ink;
  final ToggleParams params;
  final double w;
  final double h;
  final bool calm;
  final bool rtl;
  late final bool invalid;
  late final double r;
  late final List<Pt> body;
  late final bool wide;

  bool get defaultVariant => params.variant == ToggleVariant.primary;

  void disabledBox() => dashedBox(
    ink,
    0,
    0,
    w,
    h,
    r: r,
    pen: PenName.pencil,
    opts: const StrokeOpts(color: PaintKey.pencil, width: 1.2),
  );

  void inkBox({double? inset, double? alpha, bool whisper = false}) {
    final i = inset ?? 0;
    final fine = calm || whisper;
    final pen = switch ((invalid, fine)) {
      (true, true) => PenName.redFine,
      (true, false) => PenName.red,
      (false, true) => PenName.pencilFine,
      (false, false) => PenName.ink,
    };
    final a = switch (invalid) {
      true => null,
      false => alpha,
    };
    final withOpts = a != null || wide || calm || invalid;
    final simple = wide || (calm && i > 0);
    box(
      ink,
      i,
      i,
      w - 2 * i,
      h - 2 * i,
      pen: pen,
      corner: r,
      opts: switch (withOpts) {
        true => StrokeOpts(
          alpha: a,
          simple: switch (simple) {
            true => true,
            false => null,
          },
          width: switch (invalid) {
            true => 1.2,
            false => null,
          },
        ),
        false => null,
      },
    );
  }

  void rest() {
    if (params.joined) {
      ink.part('seam', seam, Material.top);
      return;
    }
    if (params.disabled) {
      if (params.variant == ToggleVariant.outline) {
        wash(
          ink,
          body,
          PaintKey.pencilMark,
          alpha: 0.12,
          material: Material.wash,
        );
      }
      disabledBox();
      return;
    }
    if (params.variant == ToggleVariant.outline) {
      inkBox();
      return;
    }
    inkBox(inset: 0.6, alpha: 0.4, whisper: true);
  }

  InkOffset seam() {
    final pen = switch (params.disabled || defaultVariant || calm) {
      true => PenName.pencilFine,
      false => PenName.inkFine,
    };
    final o = ruler.merge(
      StrokeOpts(
        alpha: switch ((params.disabled, defaultVariant)) {
          (true, _) => 0.55,
          (false, true) => 0.42,
          (false, false) => 1,
        },
      ),
    );
    if (params.vertical) {
      ink.lines([
        Line([(w * 0.06, 0.4), (w * 0.94, 0.4)], o: o),
      ], pen);
      return InkOffset.zero;
    }
    final x = switch (rtl) {
      true => w - 0.4,
      false => 0.4,
    };
    ink.lines([
      Line([(x, h * 0.05), (x, h * 0.95)], o: o),
    ], pen);
    return InkOffset.zero;
  }

  void hover() {
    if (defaultVariant && !params.joined) {
      inkBox(inset: 0.6, alpha: 0.6, whisper: true);
    }
    if (!defaultVariant || params.joined) {
      wash(
        ink,
        body,
        PaintKey.hi,
        alpha: switch (params.joined || defaultVariant) {
          true => 0.34,
          false => 0.5,
        },
      );
    }
    if (calm && !params.joined) {
      box(
        ink,
        1,
        1,
        w - 2,
        h - 2,
        pen: PenName.pencilFine,
        corner: r,
        loose: 0.6,
        opts: const StrokeOpts(alpha: 0.7, simple: true),
      );
      return;
    }
    if (calm || params.joined || defaultVariant) return;
    final d = 3.4 + h / 40;
    ink.lines(
      [
        Line(
          chain(
            [(r + d + 2, h + d), (w + d, h + d), (w + d, r + d + 2)],
            [0.25, -0.2],
            math.max(2.5, r + 1),
            ink.next('drop'),
          ),
          o: const StrokeOpts(
            start: StrokeStart.soft,
            end: StrokeEnd.soft,
            wobble: 0.25,
            dry: 0,
          ),
        ),
      ],
      PenName.inkFine,
      const StrokeOpts(width: 1.3),
    );
  }

  void checked() {
    if (params.disabled) {
      wash(
        ink,
        body,
        PaintKey.pencilMark,
        alpha: 0.35,
        material: Material.wash,
      );
      return;
    }
    final tone = params.tone ?? ToggleTone.hi;
    final alpha = switch (tone) {
      ToggleTone.marker => 0.86,
      ToggleTone.hi => 0.82,
    };
    final mis = switch (params.joined) {
      true => 1.3,
      false => clamp(h * 0.06, 1.6, 3),
    };
    final small = math.min(w, h) < 28;
    ink.part('fill', () {
      if (small) return blobFill(ink, body, tone.paint, alpha: alpha, mis: mis);
      return bandFill(
        ink,
        body,
        tone.paint,
        alpha: alpha,
        mis: mis,
        passes: switch (tone == ToggleTone.marker && !calm) {
          true => 2,
          false => 1,
        },
        ends: BandEnds.square,
        w: clamp(math.min(w, h) * 0.3, 5, 9),
        angle: switch (w / h < 1.6) {
          true => -0.04,
          false => -0.02,
        },
      );
    });
    final simple = switch (wide) {
      true => true,
      false => null,
    };
    if (invalid) {
      box(
        ink,
        0,
        0,
        w,
        h,
        pen: switch (calm) {
          true => PenName.redFine,
          false => PenName.red,
        },
        corner: r,
        opts: StrokeOpts(width: 1.3, simple: simple),
      );
      return;
    }
    if (!defaultVariant || params.joined) return;
    if (calm) {
      box(
        ink,
        0,
        0,
        w,
        h,
        pen: PenName.pencilFine,
        corner: r,
        opts: StrokeOpts(simple: simple),
      );
      return;
    }
    box(
      ink,
      0,
      0,
      w,
      h,
      pen: PenName.inkFine,
      corner: r,
      opts: switch (wide) {
        true => const StrokeOpts(simple: true),
        false => null,
      },
    );
  }
}

void _draw(Ink ink, Box size, ToggleParams params, RecipeContext ctx) {
  final t = _Toggle(ink, size, params, ctx);
  if (!params.disabled) {
    ctx.lazy(
      LayerName.focus,
      (fink) => focusRing(fink, 0, 0, size.w, size.h, r: t.r),
    );
  }
  if (ctx.lazyOnly) return;
  ink.layer(LayerName.rest, t.rest);
  if (!params.disabled) ink.layer(LayerName.hover, t.hover);
  ink.layer(LayerName.checked, t.checked);
}
