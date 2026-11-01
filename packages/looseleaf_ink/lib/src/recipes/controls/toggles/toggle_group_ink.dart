import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Toggle group params.
///
/// Mirrors `ToggleGroupParams` in `src/lib/ink/recipes/toggle-group-ink.ts`.
final class ToggleGroupParams {
  /// Params.
  const ToggleGroupParams({
    required this.joined,
    this.disabled = false,
    this.invalid = false,
  });

  /// Only joined groups draw a frame.
  final bool joined;
  final bool disabled;
  final bool invalid;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'joined': joined,
    if (disabled) 'disabled': true,
    if (invalid) 'invalid': true,
  };
}

/// The frame around a joined toggle group.
///
/// Mirrors `toggleGroupRecipe` in `src/lib/ink/recipes/toggle-group-ink.ts`.
final Recipe<ToggleGroupParams> toggleGroupRecipe =
    defineRecipe<ToggleGroupParams>(
      id: 'toggle-group',
      kind: 'toggle-group',
      layers: const [LayerName.rest, LayerName.disabled],
      pad: 12,
      draw: _draw,
    );

void _draw(Ink ink, Box size, ToggleGroupParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final calm = ctx.calm;
  if (!params.joined) return;
  final r = clamp(math.min(w, h) * 0.09, 2.2, 4.4);
  if (params.disabled) {
    ink.layer(LayerName.disabled, () {
      wash(
        ink,
        roundRectPoly(1.6, 1.6, w - 3.2, h - 3.2, r),
        PaintKey.pencilMark,
        alpha: 0.12,
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
    });
    return;
  }
  final opts = StrokeOpts(
    simple: switch (w > 360) {
      true => true,
      false => null,
    },
    width: switch (params.invalid) {
      true => 1.2,
      false => null,
    },
  );
  final pen = switch ((calm, params.invalid)) {
    (true, true) => PenName.redFine,
    (true, false) => PenName.pencilFine,
    (false, true) => PenName.red,
    (false, false) => PenName.ink,
  };
  ink.layer(
    LayerName.rest,
    () => box(ink, 0, 0, w, h, pen: pen, corner: r, opts: opts),
  );
}
