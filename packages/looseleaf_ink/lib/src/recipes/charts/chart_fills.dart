import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/charts/charts.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

/// The rectangle [x], [y], [w], [h] as a polygon.
///
/// Mirrors `rectPts` in `src/lib/ink/recipes/chart-ink/parts.ts`.
List<Pt> rectPts(double x, double y, double w, double h) => [
  (x, y),
  (x + w, y),
  (x + w, y + h),
  (x, y + h),
];

/// The pens an annotation is written with.
///
/// Mirrors `NOTE_PEN` in `src/lib/ink/recipes/chart-ink/parts.ts`.
extension NotePenInk on NotePen {
  /// The standard nib.
  PenName get std => switch (this) {
    NotePen.red => PenName.redfelt,
    NotePen.blue => PenName.blue,
    NotePen.ink => PenName.ink,
    NotePen.green => PenName.greenfelt,
  };

  /// The fine nib.
  PenName get fine => switch (this) {
    NotePen.red => PenName.redfeltFine,
    NotePen.blue => PenName.blueFine,
    NotePen.ink => PenName.inkFine,
    NotePen.green => PenName.greenfeltFine,
  };
}

/// The paint a pattern is drawn in over series [slot]: ink over the first
/// slot's yellow, white over the rest.
///
/// Mirrors `hatchOn` in `src/lib/ink/recipes/chart-ink/xy.ts`.
PaintKey hatchOn(int slot) => switch (slot % 8) {
  0 => PaintKey.ink,
  _ => PaintKey.photo,
};

void _stippleIn(
  Ink ink,
  List<Pt> poly,
  double gap,
  PaintKey color,
  double alpha,
  double maxDots,
) {
  final rng = ink.next('dots');
  final b = bboxOf(poly);
  final cols = math.max(1, ((b.x1 - b.x0) / gap).floor());
  final rows = math.max(1, ((b.y1 - b.y0) / (gap * 0.87)).floor());
  final stride = math.max(1, ((cols * rows) / maxDots).ceil());
  final d = StringBuffer();
  var k = 0;
  for (var r = 0; r <= rows; r++) {
    for (var c = 0; c <= cols; c++) {
      if (k++ % stride != 0) continue;
      final shift = switch (r % 2) {
        0 => 0.1,
        _ => 0.5,
      };
      final x = b.x0 + (c + shift) * gap + rng.gauss(0, gap * 0.12);
      final y = b.y0 + (r + 0.4) * gap * 0.87 + rng.gauss(0, gap * 0.1);
      if (!inside(poly, x, y)) continue;
      final s = 0.85 + rng() * 0.6;
      String f(double v) => JsMath.toFixed(v, 1);
      d.write(
        'M${f(x)} ${f(y)}l${f(s)} ${f(-0.2 * s)} ${f(0.1 * s)} ${f(s)} '
        '${f(-s)} ${f(0.1 * s)}z',
      );
    }
  }
  ink.flat(Material.pencil, '$d', color, op: alpha);
}

void _scribbleIn(
  Ink ink,
  List<Pt> poly,
  double gap,
  PaintKey color,
  double alpha,
  double maxPulls,
) {
  final rng = ink.next('scrib');
  final b = bboxOf(poly);
  final g = math.max(gap, (b.y1 - b.y0) / math.max(4, maxPulls));
  final spans = scanSpans(poly, -0.34, g, rng, even: false, jitter: 0.12);
  final pts = <Pt>[];
  for (final (i, sp) in spans.indexed) {
    final (a, c) = switch (i % 2) {
      0 => (sp.a, sp.b),
      _ => (sp.b, sp.a),
    };
    pts
      ..add((a.x + rng.gauss(0, 0.4), a.y + rng.gauss(0, 0.4)))
      ..add((c.x + rng.gauss(0, 0.4), c.y + rng.gauss(0, 0.4)));
  }
  if (pts.length <= 3) return;
  ink.stroke(
    pts,
    PenName.pencil,
    StrokeOpts(
      poly: true,
      round: 1.2,
      simple: true,
      alpha: alpha,
      width: 0.85,
      wobble: 0.5,
      color: color,
    ),
  );
}

/// Fills [poly] with [pattern] in [color]: pencil hatching, cross
/// hatching, rules, stipple or a scribble; [solid] draws nothing. [gapK]
/// scales the spacing and [maxPulls] caps the number of strokes.
///
/// Mirrors `patternFill` in `src/lib/ink/recipes/chart-ink/parts.ts`.
void patternFill(
  Ink ink,
  FillPattern pattern,
  List<Pt> poly, {
  required PaintKey color,
  double? gapK,
  double? alpha,
  double? maxPulls,
}) {
  if (pattern == FillPattern.solid || poly.length < 3) return;
  final b = bboxOf(poly);
  final w = b.x1 - b.x0;
  final h = b.y1 - b.y0;
  if (w < 5 || h < 5) return;
  final a = alpha ?? 0.62;
  final pulls = maxPulls ?? 60;
  final base = 5 * (gapK ?? 1.0);
  final gapDiag = math.max(base, (w + h) / pulls);
  final gapRule = math.max(base, h / pulls);
  final opts = StrokeOpts(color: color);
  switch (pattern) {
    case FillPattern.hatch:
      hatch(
        ink,
        poly,
        pen: PenName.pencil,
        angle: 58,
        gap: gapDiag,
        alpha: a,
        width: 0.8,
        over: 0.5,
        under: 1.2,
        opts: opts,
      );
    case FillPattern.cross:
      hatch(
        ink,
        poly,
        pen: PenName.pencil,
        angle: 52,
        gap: gapDiag * 1.25,
        tones: 2,
        crossAngle: 76,
        alpha: a,
        width: 0.75,
        over: 0.5,
        under: 1.2,
        opts: opts,
      );
    case FillPattern.lines:
      hatch(
        ink,
        poly,
        pen: PenName.pencil,
        angle: 4,
        gap: gapRule * 1.15,
        alpha: a,
        width: 0.8,
        over: 0.6,
        under: 1.2,
        opts: opts,
      );
    case FillPattern.dots:
      _stippleIn(ink, poly, base * 1.3, color, a + 0.12, pulls * 3);
    case FillPattern.scribble || FillPattern.solid:
      _scribbleIn(ink, poly, base * 0.9, color, a, pulls);
  }
}

/// A solid swipe of highlighter over [r], inset along its
/// length ([horizontal] bars run left to right).
///
/// Mirrors `swipeFill` in `src/lib/ink/recipes/chart-ink/parts.ts`.
void swipeFill(
  Ink ink,
  ({double x, double y, double w, double h}) r,
  bool horizontal,
  bool calm,
) {
  final along = switch (horizontal) {
    true => r.w,
    false => r.h,
  };
  final inset = clamp(along * 0.02, 1, 4);
  final (bx, by, bw, bh) = switch (horizontal) {
    true => (r.x + inset, r.y, r.w - inset * 2, r.h),
    false => (r.x, r.y + inset, r.w, r.h - inset * 2),
  };
  solidFill(
    ink,
    roundRectPoly(bx, by, bw, bh, math.min(5, math.min(bw, bh) / 2)),
    PaintKey.hi,
    alpha: switch (calm) {
      true => 0.5,
      false => 0.62,
    },
    rough: 0.05,
  );
}

/// A roughly squared cell path at [x], [y] of [w] × [h], its corners
/// jittered by [amt] (exact when [amt] is 0). Always forks the `cell`
/// stream.
///
/// Mirrors `roughSquare` in `src/lib/ink/recipes/chart-ink/mini.ts`.
String roughSquare(
  Ink ink,
  double x,
  double y,
  double w,
  double h,
  double amt,
) {
  final r = ink.next('cell');
  if (amt <= 0) {
    String f(double v) =>
        JsMath.numberToString(double.parse(JsMath.toFixed(v, 1)));
    return 'M${f(x)} ${f(y)}h${f(w)}v${f(h)}h${f(-w)}z';
  }
  String p(double a, double b) {
    final px = JsMath.toFixed(a + r.gauss(0, amt), 1);
    final py = JsMath.toFixed(b + r.gauss(0, amt), 1);
    return '$px $py';
  }

  return 'M${p(x, y)}L${p(x + w, y)} ${p(x + w, y + h)} ${p(x, y + h)}z';
}
