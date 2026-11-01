import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/no_params.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// A choice card around a field (a radio or checkbox with its label): a
/// pencil box, a darker box on hover, a highlighter wash when checked.
///
/// Mirrors `fieldChoiceRecipe` in `src/lib/ink/recipes/field-ink.ts`.
final Recipe<NoParams> fieldChoiceRecipe = defineRecipe<NoParams>(
  id: 'field-choice',
  kind: 'card',
  layers: const [LayerName.rest, LayerName.hover, LayerName.checked],
  pad: 12,
  draw: _draw,
);

void _draw(Ink ink, Box size, NoParams _, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final r = clamp(math.min(w, h) * 0.06, 2, 4);
  final body = roundRectPoly(1.5, 1.5, w - 3, h - 3, r);
  final wide = w > 360;
  final calm = ctx.calm;
  ink
    ..layer(LayerName.rest, () {
      ink.poly(Material.under, body, PaintKey.slip, 0.7);
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
        opts: StrokeOpts(width: 1.1, simple: wide),
      );
    })
    ..layer(
      LayerName.hover,
      () => box(
        ink,
        0.8,
        0.8,
        w - 1.6,
        h - 1.6,
        pen: switch (calm) {
          true => PenName.pencilFine,
          false => PenName.inkFine,
        },
        corner: r,
        loose: 0.7,
        opts: StrokeOpts(alpha: 0.75, simple: wide),
      ),
    )
    ..layer(LayerName.checked, () {
      ink.part('fill', () => wash(ink, body, PaintKey.hi, alpha: 0.5));
      box(
        ink,
        0,
        0,
        w,
        h,
        pen: switch (calm) {
          true => PenName.pencilFine,
          false => PenName.ink,
        },
        corner: r,
        opts: StrokeOpts(width: 1.05, simple: wide),
      );
    });
}
