import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:looseleaf_ink/src/recipes/marks/marks.dart';

/// Tally recipe params: [count] marks in gates of five, [gh] tall.
///
/// Mirrors `TallyParams` in `src/lib/ink/recipes/tally-ink.ts`.
final class TallyParams {
  /// Params.
  const TallyParams({
    required this.count,
    required this.gh,
    required this.tone,
    required this.weight,
    this.rtl,
  });

  final int count;
  final double gh;
  final MarkPen tone;
  final MarkWeight weight;

  /// Mirrors the marks; follows the text direction when unset.
  final bool? rtl;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'count': count,
    'gh': gh,
    'tone': tone.id,
    'weight': weight.name,
    'rtl': ?rtl,
  };
}

/// The box [count] tally marks [gh] tall need.
///
/// Mirrors `tallyBox` in `src/lib/ink/recipes/tally-ink.ts`.
Box tallyBox(int count, double gh) {
  final n = math.max(0, math.min(99, count));
  final step = 0.26 * gh;
  final gw = 1.05 * gh + 6;
  final full = n ~/ 5;
  final rem = n % 5;
  final x0 = (0.6 * step).ceil() + 1;
  final w = switch ((n, rem)) {
    (0, _) => 0.0,
    (_, 0) => x0 + (full - 1) * gw + 3.6 * step + 2,
    _ => x0 + full * gw + (rem - 1) * step + 3,
  };
  return Box(w.ceilToDouble(), (gh + 4).ceilToDouble());
}

/// Tally marks in gates of five, mirrored for right-to-left text.
///
/// Mirrors `tallyRecipe` in `src/lib/ink/recipes/tally-ink.ts`.
final Recipe<TallyParams> tallyRecipe = defineRecipe<TallyParams>(
  id: 'tally',
  kind: 'tally',
  layers: const [LayerName.rest],
  pad: 8,
  draw: _draw,
);

void _draw(Ink ink, Box size, TallyParams p, RecipeContext ctx) {
  final Box(:w) = size;
  final n = math.max(0, math.min(99, p.count));
  if (n == 0) return;
  final (:pen, :width, dry: _) = markPen(
    p.tone,
    p.weight,
    math.max(14, p.gh * 0.9),
  );
  final x0 = (0.6 * 0.26 * p.gh).ceil() + 1;
  final (:lines, width: _) = tallyLines(
    ink.next('tally'),
    x0.toDouble(),
    2,
    n,
    p.gh,
  );
  final mirror = p.rtl ?? ctx.dir == Dir.rtl;
  ink.layer(LayerName.rest, () {
    if (mirror) {
      ink.group(
        GroupAttrs(
          transform: 'translate(${JsMath.numberToString(w)} 0) scale(-1 1)',
        ),
        () => ink.lines(lines, pen, StrokeOpts(width: width)),
      );
      return;
    }
    ink.lines(lines, pen, StrokeOpts(width: width));
  });
}
