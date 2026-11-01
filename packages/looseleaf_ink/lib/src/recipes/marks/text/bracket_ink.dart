import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:looseleaf_ink/src/recipes/marks/marks.dart';

/// Which side of the text a bracket stands on.
enum BracketSide { start, end }

/// Bracket recipe params: [inset] is the bracket's distance from its edge.
///
/// Mirrors `BracketParams` in `src/lib/ink/recipes/bracket-ink.ts`.
final class BracketParams {
  /// Params.
  const BracketParams({
    required this.kind,
    required this.side,
    required this.tone,
    required this.weight,
    required this.inset,
    this.animate,
  });

  final BracketKind kind;
  final BracketSide side;
  final MarkPen tone;
  final MarkWeight weight;
  final double inset;
  final bool? animate;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'side': side.name,
    'tone': tone.id,
    'weight': weight.name,
    'inset': inset,
    'animate': ?animate,
  };
}

List<Line> _roundLines(Rng rng, double x, double y, double h, int d) {
  final tip = math.min(11, math.max(3.5, h * 0.13));
  final skew = rng.range(0.78, 1.28);
  final lean = rng.gauss(0, 0.014) * h;
  final pts = <Pt>[];
  for (var i = 0; i <= 14; i++) {
    final t = i / 14;
    pts.add((
      x +
          d * tip * (1 - JsMath.sin(JsMath.pi * JsMath.pow(t, skew))) +
          lean * (t - 0.5) +
          rng.gauss(0, 0.12),
      y + h * t,
    ));
  }
  return [
    Line(
      pts,
      o: const StrokeOpts(
        start: StrokeStart.soft,
        end: StrokeEnd.flick,
        wobble: 0.6,
      ),
    ),
  ];
}

/// A tall bracket beside a block of text: square, curly or round.
///
/// Mirrors `bracketRecipe` in `src/lib/ink/recipes/bracket-ink.ts`.
final Recipe<BracketParams> bracketRecipe = defineRecipe<BracketParams>(
  id: 'bracket',
  kind: 'bracket',
  layers: const [LayerName.rest],
  pad: 12,
  draw: _draw,
);

void _draw(Ink ink, Box size, BracketParams p, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final (:pen, :width, dry: _) = markPen(p.tone, p.weight, 18);
  final left = (p.side == BracketSide.start) == (ctx.dir != Dir.rtl);
  final x = switch (left) {
    true => p.inset,
    false => w - p.inset,
  };
  final trim = math.min(6, h * 0.04).toDouble();
  final tall = math.max(8, h - 2 * trim).toDouble();
  final d = switch (left) {
    true => 1,
    false => -1,
  };
  final rng = ink.next('bracket');
  final lines = switch (p.kind) {
    BracketKind.round => _roundLines(rng, x, trim, tall, d),
    _ => bracketLines(rng, x, trim, tall, kind: p.kind, dir: d),
  };
  ink.layer(LayerName.rest, () {
    if (p.animate ?? false) {
      revealMark(
        ink,
        id: markRevealId(ctx.seed, 'b'),
        lines: lines,
        pen: pen,
        box: size,
        pad: 14,
        width: width,
        opts: const StrokeOpts(dry: structuralDry),
        revealWidth: 5,
      );
      return;
    }
    ink.lines(lines, pen, StrokeOpts(width: width, dry: structuralDry));
  });
}
