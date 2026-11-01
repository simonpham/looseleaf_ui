import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/fields/field_frame_ink.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// The trigger frame shared by select, native select, date picker and
/// combobox.
///
/// Mirrors `SelectFrameParams` in `src/lib/ink/recipes/select-frame-ink.ts`.
final class SelectFrameParams {
  /// Params.
  const SelectFrameParams({
    this.disabled = false,
    this.invalid = false,
    this.openable = false,
    this.cell,
  });

  final bool disabled;
  final bool invalid;

  /// Draws an `open` layer.
  final bool openable;

  /// The width of the chevron cell at the end, 32 when null.
  final double? cell;
}

void _divider(Ink ink, double x, double h, double alpha) {
  ink.stroke(
    [(x, 7), (x, h - 7)],
    PenName.pencilFine,
    ruler.merge(StrokeOpts(alpha: alpha, simple: true)),
  );
}

/// Draws a select trigger: a field frame with a divider before the chevron
/// cell and, when [SelectFrameParams.openable], a highlighted `open` layer.
///
/// Mirrors `drawSelectFrame` in `src/lib/ink/recipes/select-frame-ink.ts`.
void drawSelectFrame(
  Ink ink,
  Box size,
  SelectFrameParams p,
  RecipeContext ctx,
) {
  final Box(:w, :h) = size;
  final cell = p.cell ?? 32;
  final rtl = ctx.dir == Dir.rtl;
  final tickX = switch (rtl) {
    true => cell,
    false => w - cell,
  };
  final roomy = w >= cell * 2.4;
  final r = clamp(math.min(w, h) * 0.08, 2, 4);
  final body = roundRectPoly(1.5, 1.5, w - 3, h - 3, r);

  if (p.invalid && !p.disabled) {
    ctx
      ..lazy(LayerName.focus, (f) => focusRing(f, 0, 0, w, h, r: r))
      ..lazy(
        LayerName.hover,
        (hv) => box(
          hv,
          0.6,
          0.6,
          w - 1.2,
          h - 1.2,
          pen: PenName.redFine,
          corner: r,
          loose: 0.7,
          opts: const StrokeOpts(alpha: 0.7),
        ),
      );
    if (ctx.lazyOnly) return;
    ink.layer(
      LayerName.invalid,
      () => _invalid(ink, w, h, r, cell, body, rtl, roomy, ctx.calm),
    );
    return;
  }

  drawFieldFrame(ink, size, FieldFrameParams(disabled: p.disabled), ctx);
  if (ctx.lazyOnly) return;
  if (roomy) {
    final layer = switch (p.disabled) {
      true => LayerName.disabled,
      false => LayerName.rest,
    };
    final alpha = switch (p.disabled) {
      true => 0.6,
      false => 0.8,
    };
    ink.layer(layer, () => _divider(ink, tickX, h, alpha));
  }
  if (p.disabled || !p.openable) return;
  ink.layer(LayerName.open, () {
    wash(
      ink,
      body,
      PaintKey.hi,
      alpha: switch (ctx.calm) {
        true => 0.3,
        false => 0.5,
      },
    );
    box(
      ink,
      0.6,
      0.6,
      w - 1.2,
      h - 1.2,
      pen: switch (ctx.calm) {
        true => PenName.pencilFine,
        false => PenName.inkFine,
      },
      corner: r,
      loose: 0.7,
      opts: const StrokeOpts(alpha: 0.85),
    );
  });
}

void _invalid(
  Ink ink,
  double w,
  double h,
  double r,
  double cell,
  List<Pt> body,
  bool rtl,
  bool roomy,
  bool calm,
) {
  ink.poly(Material.under, body, PaintKey.slip, 0.7);
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
  final len = clamp(w - cell - 32, 24, 110);
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
  if (roomy) {
    fieldBang(
      ink,
      switch (rtl) {
        true => cell + 14,
        false => w - cell - 14,
      },
      h / 2,
    );
  }
}
