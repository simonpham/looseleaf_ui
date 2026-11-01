import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/toggles/draw_on_ink.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Checkbox recipe params.
///
/// Mirrors `CheckboxParams` in `src/lib/ink/recipes/checkbox-ink.ts`.
final class CheckboxParams {
  /// Params.
  const CheckboxParams({this.disabled = false, this.invalid = false});

  final bool disabled;
  final bool invalid;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    if (disabled) 'disabled': true,
    if (invalid) 'invalid': true,
  };
}

/// The checkbox: a slip under an inked box, a drop line on hover, a marker
/// fill with a drawn-on tick when checked and a ruled dash when
/// indeterminate, a red box and flick when invalid.
///
/// Mirrors `checkboxRecipe` in `src/lib/ink/recipes/checkbox-ink.ts`.
final Recipe<CheckboxParams> checkboxRecipe = defineRecipe<CheckboxParams>(
  id: 'checkbox',
  kind: 'checkbox',
  layers: const [
    LayerName.rest,
    LayerName.hover,
    LayerName.checked,
    LayerName.indeterminate,
    LayerName.focus,
  ],
  lazy: const [LayerName.focus],
  pad: 12,
  draw: _draw,
);

void _draw(Ink ink, Box size, CheckboxParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final disabled = params.disabled, invalid = params.invalid;
  final s = math.min(w, h);
  final r = clamp(s * 0.1, 1.5, 3);
  final body = roundRectPoly(0.5, 0.5, w - 1, h - 1, r);
  final fine = s < 18;
  final calm = ctx.calm;

  if (!disabled) {
    ctx.lazy(LayerName.focus, (fink) => focusRing(fink, 0, 0, w, h, r: r));
  }
  if (ctx.lazyOnly) return;

  ink.layer(LayerName.rest, () {
    if (disabled) {
      wash(
        ink,
        body,
        PaintKey.pencilMark,
        alpha: 0.35,
        material: Material.wash,
      );
      dashedBox(
        ink,
        0,
        0,
        w,
        h,
        r: r,
        pen: PenName.pencil,
        opts: const StrokeOpts(color: PaintKey.pencil, width: 1.2),
      );
      return;
    }
    ink.poly(Material.under, body, PaintKey.slip, 0.85);
    final pen = switch ((invalid, calm || fine, calm, fine)) {
      (true, true, _, _) => PenName.redFine,
      (true, false, _, _) => PenName.red,
      (false, _, true, _) => PenName.pencilFine,
      (false, _, false, true) => PenName.inkFine,
      (false, _, false, false) => PenName.ink,
    };
    box(
      ink,
      0,
      0,
      w,
      h,
      pen: pen,
      corner: r,
      opts: switch (invalid) {
        true => const StrokeOpts(width: 1.2),
        false => null,
      },
    );
  });

  if (!disabled) {
    ink.layer(LayerName.hover, () {
      if (calm) {
        box(
          ink,
          1,
          1,
          w - 2,
          h - 2,
          pen: switch (invalid) {
            true => PenName.redFine,
            false => PenName.pencilFine,
          },
          corner: r,
          loose: 0.5,
          opts: const StrokeOpts(alpha: 0.75, simple: true),
        );
        return;
      }
      final d = 2 + s / 24;
      ink.lines(
        [
          Line(
            chain(
              [(r + d + 1, h + d), (w + d, h + d), (w + d, r + d + 1)],
              [0, 0],
              math.max(2.5, r),
              ink.next('drop'),
            ),
            o: ruler,
          ),
        ],
        PenName.inkFine,
        const StrokeOpts(width: 1.1),
      );
    });
  }

  final markPen = switch ((disabled, s < 26)) {
    (true, _) => PenName.pencil,
    (false, true) => PenName.ink,
    (false, false) => PenName.inkBrush,
  };
  final fillColor = switch (disabled) {
    true => PaintKey.pencilMark,
    false => PaintKey.marker,
  };
  final fillAlpha = switch (disabled) {
    true => 0.4,
    false => 0.86,
  };
  void fill(double alpha) => ink.part(
    'fill',
    () => blobFill(
      ink,
      body,
      fillColor,
      alpha: alpha,
      mis: clamp(s * 0.08, 1, 2),
    ),
  );

  void invalidMark() {
    if (!invalid || disabled) return;
    box(
      ink,
      0,
      0,
      w,
      h,
      pen: switch (calm || fine) {
        true => PenName.redFine,
        false => PenName.red,
      },
      corner: r,
      opts: const StrokeOpts(width: 1.3),
    );
    final a = 4 + s * 0.14;
    ink.lines(
      [
        Line(
          [(w - 1, -a * 0.95), (w + a * 0.3, -a * 0.4), (w + a, 0.4)],
          o: const StrokeOpts(
            start: StrokeStart.soft,
            end: StrokeEnd.flick,
            wobble: 0.3,
            poly: true,
          ),
        ),
      ],
      PenName.redFine,
      const StrokeOpts(width: 1.25),
    );
  }

  ink
    ..layer(LayerName.checked, () {
      fill(fillAlpha);
      invalidMark();
      reveal(
        ink,
        id: revealId(ctx.seed, 'c'),
        lines: checkLines(ink.next('check'), s * 0.12, -s * 0.1, s * 1.02),
        pen: markPen,
        box: Box(w, h),
      );
    })
    ..layer(LayerName.indeterminate, () {
      fill(fillAlpha * 0.9);
      invalidMark();
      final y = h * 0.52;
      reveal(
        ink,
        id: revealId(ctx.seed, 'i'),
        lines: [
          Line([(w * 0.22, y), (w * 0.78, y)], o: ruler),
        ],
        pen: switch (disabled) {
          true => PenName.pencil,
          false => PenName.ink,
        },
        box: Box(w, h),
        width: switch (s < 20) {
          true => 1.1,
          false => 1.35,
        },
      );
    });
}
