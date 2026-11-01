import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/no_params.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// A text cell inside a button group: a shaded wash in an inked box.
///
/// Mirrors `buttonGroupTextRecipe` in
/// `src/lib/ink/recipes/button-group-ink.ts`.
final Recipe<NoParams> buttonGroupTextRecipe = defineRecipe<NoParams>(
  id: 'button-group-text',
  kind: 'cell',
  layers: const [LayerName.rest],
  pad: 12,
  draw: (ink, size, _, ctx) {
    final Box(:w, :h) = size;
    final r = clamp(h * 0.09, 2.5, 4.4);
    final inset = clamp(h * 0.06, 1.6, 3);
    final simple = switch (w > 360) {
      true => const StrokeOpts(simple: true),
      false => null,
    };
    ink.layer(LayerName.rest, () {
      wash(
        ink,
        roundRectPoly(inset, inset, w - 2 * inset, h - 2 * inset, r),
        PaintKey.paperShade,
        alpha: 0.95,
        material: Material.wash,
      );
      final pen = switch (ctx.calm) {
        true => PenName.pencilFine,
        false => PenName.ink,
      };
      box(ink, 0, 0, w, h, pen: pen, corner: r, opts: simple);
    });
  },
);
