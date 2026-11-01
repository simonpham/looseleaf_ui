import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// The text field frame shared by input, textarea, combobox and select.
///
/// Mirrors `FieldFrameParams` in `src/lib/ink/recipes/field-frame-ink.ts`.
final class FieldFrameParams {
  /// Params.
  const FieldFrameParams({
    this.disabled = false,
    this.invalid = false,
    this.readOnly = false,
    this.multiline = false,
    this.ruled = false,
    this.lineHeight,
    this.ruleTop,
    this.grip = false,
  });

  final bool disabled;
  final bool invalid;
  final bool readOnly;

  /// Places the invalid mark near the top instead of the middle.
  final bool multiline;

  /// Draws notebook rules (multiline only).
  final bool ruled;

  /// The rule spacing, 28 when null.
  final double? lineHeight;

  /// The top of the first line, 8 when null.
  final double? ruleTop;

  /// Draws a resize grip in the end corner.
  final bool grip;
}

const double _ruleOffset = 0.74;

void _ruledLines(
  Ink ink,
  double w,
  double h,
  FieldFrameParams p,
  double alpha,
) {
  final lh = p.lineHeight ?? 28;
  final top = p.ruleTop ?? 8;
  final bottom = h - 4;
  for (var i = 0; ; i++) {
    final y = top + i * lh + lh * _ruleOffset;
    if (y > bottom) break;
    ink.stroke(
      [(8, y), (w - 8, y)],
      PenName.pencilFine,
      ruler.merge(
        StrokeOpts(
          color: PaintKey.ruleBlue,
          alpha: alpha,
          width: 1.05,
          simple: true,
        ),
      ),
    );
  }
}

const StrokeOpts _gripOpts = StrokeOpts(alpha: 0.85, simple: true);

void _grip(Ink ink, double w, double h, bool rtl) {
  double x(double v) => switch (rtl) {
    true => w - v,
    false => v,
  };
  final opts = ruler.merge(_gripOpts);
  ink
    ..stroke(
      [(x(w - 12), h - 3.4), (x(w - 3.4), h - 12)],
      PenName.pencilFine,
      opts,
    )
    ..stroke(
      [(x(w - 7.6), h - 3.2), (x(w - 3.2), h - 7.6)],
      PenName.pencilFine,
      opts,
    );
}

/// The red exclamation mark of an invalid field, centered on [x], [y].
///
/// Mirrors `bang` in `src/lib/ink/recipes/field-frame-ink.ts`.
void fieldBang(Ink ink, double x, double y) {
  ink
    ..stroke(
      [(x, y - 7.5), (x + 0.6, y + 1.6)],
      PenName.redfelt,
      const StrokeOpts(end: StrokeEnd.flick, wobble: 0.2, width: 1.7),
    )
    ..dot(x + 0.8, y + 6.8, 1.5, PenName.redfelt);
}

/// Draws a text field: a slip under a pencil box at rest, a darker box on
/// hover, a red box with a squiggle and a bang when invalid, a shaded dashed
/// box when disabled, and a wash when read-only.
///
/// Mirrors `drawFieldFrame` in `src/lib/ink/recipes/field-frame-ink.ts`.
void drawFieldFrame(
  Ink ink,
  Box size,
  FieldFrameParams p,
  RecipeContext ctx,
) {
  final Box(:w, :h) = size;
  final r = clamp(math.min(w, h) * 0.08, 2, 4);
  final body = roundRectPoly(1.5, 1.5, w - 3, h - 3, r);
  final ruled = p.ruled && p.multiline;
  final rtl = ctx.dir == Dir.rtl;

  if (p.disabled) {
    if (ctx.lazyOnly) return;
    ink.layer(LayerName.disabled, () {
      wash(ink, body, PaintKey.paperShade, alpha: 0.9, material: Material.wash);
      if (ruled) _ruledLines(ink, w, h, p, 0.55);
      dashedBox(
        ink,
        0,
        0,
        w,
        h,
        r: r,
        pen: PenName.pencil,
        opts: const StrokeOpts(color: PaintKey.pencilMark),
      );
      if (p.grip) _grip(ink, w, h, rtl);
    });
    return;
  }

  ctx.lazy(LayerName.focus, (fink) => focusRing(fink, 0, 0, w, h, r: r));
  if (!p.readOnly) {
    ctx.lazy(
      LayerName.hover,
      (hink) => box(
        hink,
        0.6,
        0.6,
        w - 1.2,
        h - 1.2,
        pen: switch (p.invalid) {
          true => PenName.redFine,
          false => PenName.inkFine,
        },
        corner: r,
        loose: 0.7,
        opts: StrokeOpts(
          alpha: switch (p.invalid) {
            true => 0.7,
            false => 0.75,
          },
        ),
      ),
    );
  }
  if (ctx.lazyOnly) return;

  final bangY = switch (p.multiline) {
    true => 18.0,
    false => h / 2,
  };
  if (p.invalid) {
    ink.layer(
      LayerName.invalid,
      () => _invalid(ink, w, h, r, body, ruled, rtl, bangY, p, ctx.calm),
    );
    return;
  }

  ink.layer(LayerName.rest, () {
    _rest(ink, w, h, r, body, ruled, p, ctx.calm);
    if (p.grip) _grip(ink, w, h, rtl);
  });
}

void _invalid(
  Ink ink,
  double w,
  double h,
  double r,
  List<Pt> body,
  bool ruled,
  bool rtl,
  double bangY,
  FieldFrameParams p,
  bool calm,
) {
  ink.poly(Material.under, body, PaintKey.slip, 0.7);
  if (ruled) _ruledLines(ink, w, h, p, 0.8);
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
    opts: StrokeOpts(
      width: switch (calm) {
        true => 1.1,
        false => 1.25,
      },
    ),
  );
  final len = clamp(w - 40, 24, 110);
  if (!calm) {
    squiggle(
      ink,
      switch (rtl) {
        true => w - 6 - len,
        false => 6,
      },
      h + 5,
      len,
      pen: PenName.redfeltFine,
      h: 7,
      amp: 0.8,
    );
  }
  if (w >= 72) {
    fieldBang(
      ink,
      switch (rtl) {
        true => 18,
        false => w - 18,
      },
      bangY,
    );
  }
  if (p.grip) _grip(ink, w, h, rtl);
}

void _rest(
  Ink ink,
  double w,
  double h,
  double r,
  List<Pt> body,
  bool ruled,
  FieldFrameParams p,
  bool calm,
) {
  if (p.readOnly) {
    wash(ink, body, PaintKey.paperShade, alpha: 0.6, material: Material.wash);
    if (ruled) _ruledLines(ink, w, h, p, 0.8);
    box(
      ink,
      0,
      0,
      w,
      h,
      pen: PenName.pencilFine,
      corner: r,
      opts: const StrokeOpts(alpha: 0.8),
    );
    return;
  }
  ink.poly(Material.under, body, PaintKey.slip, 0.7);
  if (ruled) _ruledLines(ink, w, h, p, 1);
  if (calm) {
    box(ink, 0, 0, w, h, pen: PenName.pencilFine, corner: r);
    return;
  }
  box(
    ink,
    0,
    0,
    w,
    h,
    pen: PenName.pencil,
    corner: r,
    opts: const StrokeOpts(width: 1.15),
  );
}
