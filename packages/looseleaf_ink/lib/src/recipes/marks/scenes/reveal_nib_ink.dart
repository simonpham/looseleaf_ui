import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Reveal nib recipe params.
///
/// Mirrors `RevealNibParams` in `src/lib/ink/recipes/reveal-nib-ink.ts`.
final class RevealNibParams {
  /// Params.
  const RevealNibParams({this.color});

  /// The nib's tip colour (tomato by default).
  final PaintKey? color;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    if (color case final PaintKey c) 'color': c.id,
  };
}

/// A fountain pen nib on a 24-unit grid, the cursor of a draw-on reveal.
///
/// Mirrors `revealNibRecipe` in `src/lib/ink/recipes/reveal-nib-ink.ts`.
final Recipe<RevealNibParams> revealNibRecipe = defineRecipe<RevealNibParams>(
  id: 'reveal-nib',
  kind: 'reveal-nib',
  layers: const [LayerName.rest],
  pad: 4,
  draw: _draw,
);

void _draw(Ink ink, Box size, RevealNibParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final color = params.color ?? PaintKey.tomato;
  final s = math.min(w, h) / 24;
  Pt p(double x, double y) => (x * s, y * s);
  List<Pt> segOf(Pt a, Pt b, double bow, int cnt) =>
      seg(a.x, a.y, b.x, b.y, bow, cnt);
  const soft = StrokeOpts(start: StrokeStart.soft, end: StrokeEnd.soft);
  ink.layer(LayerName.rest, () {
    blobFill(
      ink,
      [p(6.5, 17.5), p(18.5, 3.5), p(22.5, 6.5), p(9.5, 19.5)],
      PaintKey.paper,
      alpha: 0.95,
      mis: 0.6,
      material: Material.wash,
    );
    blobFill(
      ink,
      [p(15.4, 7.1), p(18.5, 3.5), p(22.5, 6.5), p(19.2, 10)],
      color,
      alpha: 0.95,
      mis: 0.5,
      material: Material.wash,
    );
    ink.lines(
      [
        Line(segOf(p(6.5, 17.5), p(18.5, 3.5), 0.2, 5), o: soft),
        Line(segOf(p(9.5, 19.5), p(22.5, 6.5), 0.2, 5), o: soft),
        Line(segOf(p(18.5, 3.5), p(22.5, 6.5), 0.1, 3), o: soft),
        Line(
          [p(6.5, 17.5), p(3.2, 21.4), p(9.5, 19.5)],
          o: const StrokeOpts(poly: true, round: 0.4),
        ),
      ],
      PenName.inkFine,
      const StrokeOpts(width: 0.9),
    );
    final dot = p(3.4, 21.6);
    ink.dot(dot.x, dot.y, 1.5 * s, PenName.ink, const StrokeOpts(width: 1));
  });
}
