import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:looseleaf_ink/src/recipes/marks/marks.dart';

/// The mark drawn around the text.
enum CircledShape { circle, box, brackets }

/// Circled recipe params: [bleed] is how far the mark stands off the text
/// (0 to [circledBleedMax], [circledBleedDefault] when unset).
///
/// Mirrors `CircledParams` in `src/lib/ink/recipes/circled-ink.ts`.
final class CircledParams {
  /// Params.
  const CircledParams({
    required this.line,
    required this.shape,
    required this.tone,
    required this.weight,
    this.bleed,
  });

  final LineParams line;
  final CircledShape shape;
  final MarkPen tone;
  final MarkWeight weight;
  final double? bleed;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    ...line.toJson(),
    'shape': shape.name,
    'tone': tone.id,
    'weight': weight.name,
    'bleed': ?bleed,
  };
}

/// Mirrors `BLEED_DEFAULT` in `src/lib/ink/recipes/circled-ink.ts`.
const double circledBleedDefault = 2;

/// Mirrors `BLEED_MAX` in `src/lib/ink/recipes/circled-ink.ts`.
const double circledBleedMax = 16;

/// The superellipse power that squares up a one-line loop.
///
/// Mirrors `ONE_LINE_POWER` in `src/lib/ink/recipes/circled-ink.ts`.
const double oneLinePower = 2.5;

/// [bleed] clamped and snapped to halves, or the default.
///
/// Mirrors `bleedOf` in `src/lib/ink/recipes/circled-ink.ts`.
double bleedOf(double? bleed) {
  if (bleed == null || !bleed.isFinite) return circledBleedDefault;
  return JsMath.round(math.min(circledBleedMax, math.max(0, bleed)) * 2) / 2;
}

/// How far the mark around a [w] × [h] run reaches past it.
///
/// Mirrors `circledReach` in `src/lib/ink/recipes/circled-ink.ts`.
double circledReach(double w, double h, double fs, double? bleed) =>
    math.max(14, math.max(w * 0.15 + fs * 0.7, h * 0.4 + fs * 0.5)).ceil() +
    math.max(0, bleedOf(bleed) - circledBleedDefault);

/// The loop radii around text of half-size [tw] × [th] in a box [h] tall.
///
/// Mirrors `loopRadii` in `src/lib/ink/recipes/circled-ink.ts`.
(double, double) loopRadii(
  double tw,
  double th,
  double fs,
  double ch,
  double? bleed,
  double h,
) {
  final b = bleedOf(bleed);
  if (h > ch * 1.5) {
    return (
      tw * 1.08 + fs * 0.34 + (b - circledBleedDefault),
      th * 1.32 + fs * 0.34 + (b - circledBleedDefault),
    );
  }
  return (tw * 1.06 + fs * 0.17 + b, th * 1.18 + fs * 0.08 + b);
}

/// Pushes [lines] out toward a superellipse of power [n] around
/// ([cx], [cy]).
///
/// Mirrors `squareUp` in `src/lib/ink/recipes/circled-ink.ts`.
List<Line> squareUp(
  List<Line> lines,
  double cx,
  double cy,
  double rx,
  double ry,
  double n,
) => [
  for (final l in lines)
    Line(
      [
        for (final (x, y) in l.pts) _squared(x, y, cx, cy, rx, ry, n),
      ],
      o: l.o,
      pen: l.pen,
    ),
];

Pt _squared(
  double x,
  double y,
  double cx,
  double cy,
  double rx,
  double ry,
  double n,
) {
  final u = (x - cx) / rx, v = (y - cy) / ry;
  final r = JsMath.hypot(u, v);
  if (r < 1e-6) return (x, y);
  final k = JsMath.pow(
    JsMath.pow((u / r).abs(), n) + JsMath.pow((v / r).abs(), n),
    -1 / n,
  );
  return (cx + u * k * rx, cy + v * k * ry);
}

/// A hand-drawn circle, box or pair of brackets around a run of text.
///
/// Mirrors `circledRecipe` in `src/lib/ink/recipes/circled-ink.ts`.
final Recipe<CircledParams> circledRecipe = defineRecipe<CircledParams>(
  id: 'circled',
  kind: 'circled',
  layers: const [LayerName.rest],
  padFor: (b, p, _) => circledReach(b.w, b.h, p.line.fs, p.bleed),
  draw: _draw,
);

void _draw(Ink ink, Box size, CircledParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final p = params.line;
  final (:pen, :width, dry: _) = markPen(params.tone, params.weight, p.fs);
  final top = p.base - p.cap;
  final bot = h - (p.ch - p.base - p.desc);
  final cx = w / 2, cy = (top + bot) / 2;
  final tw = w / 2, th = (bot - top) / 2;
  final rng = ink.next('circled');
  final lines = switch (params.shape) {
    CircledShape.box => _boxLines(rng, w, top, bot, p.fs, params.bleed),
    CircledShape.brackets => _bracketLines(rng, w, top, bot, p.fs, params),
    CircledShape.circle => _loopLines(rng, cx, cy, tw, th, h, p, params),
  };
  ink.layer(LayerName.rest, () {
    if (p.animate ?? false) {
      revealMark(
        ink,
        id: markRevealId(ctx.seed, 'c'),
        lines: lines,
        pen: pen,
        box: size,
        pad: circledReach(w, h, p.fs, params.bleed) + 6,
        width: width,
        revealWidth: 5 + p.fs * 0.15,
      );
      return;
    }
    ink.lines(lines, pen, StrokeOpts(width: width));
  });
}

List<Line> _boxLines(
  Rng rng,
  double w,
  double top,
  double bot,
  double fs,
  double? bleed,
) {
  final b = bleedOf(bleed);
  final px = fs * 0.32 + b, py = fs * 0.22 + b * 0.75;
  return boxLines(
    rng,
    -px,
    top - py,
    w + 2 * px,
    bot - top + 2 * py,
    corner: 3,
  );
}

List<Line> _bracketLines(
  Rng rng,
  double w,
  double top,
  double bot,
  double fs,
  CircledParams params,
) {
  final off = fs * 0.3 + bleedOf(params.bleed) - circledBleedDefault;
  final hh =
      bot - top + fs * 0.5 + (bleedOf(params.bleed) - circledBleedDefault);
  final y = top - fs * 0.25 - (bleedOf(params.bleed) - circledBleedDefault) / 2;
  return [
    ...bracketLines(rng, -off, y, hh, kind: BracketKind.square, dir: 1),
    ...bracketLines(
      rng.fork('r'),
      w + off,
      y,
      hh,
      kind: BracketKind.square,
      dir: -1,
    ),
  ];
}

List<Line> _loopLines(
  Rng rng,
  double cx,
  double cy,
  double tw,
  double th,
  double h,
  LineParams p,
  CircledParams params,
) {
  final (rx, ry) = loopRadii(tw, th, p.fs, p.ch, params.bleed, h);
  if (h <= p.ch * 1.5) {
    return squareUp(
      loopLines(rng, cx, cy, rx, ry, drift: rng.fork('d').range(0.01, 0.05)),
      cx,
      cy,
      rx,
      ry,
      oneLinePower,
    );
  }
  return loopLines(rng, cx, cy, rx, ry);
}
