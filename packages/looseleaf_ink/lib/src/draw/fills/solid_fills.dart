import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/fills/fills.dart' as support;
import 'package:looseleaf_ink/src/geom/geom.dart';

/// A slightly rough solid fill.
///
/// Mirrors `solidFill` in `src/lib/ink/fills.ts`.
InkOffset solidFill(
  Ink ink,
  List<Pt> poly,
  PaintKey color, {
  double? alpha,
  double? inset,
  double? rough,
  Material? material,
}) {
  final rng = ink.next('solid');
  final insetBy = inset ?? 0;
  final inner = switch (insetBy != 0 && !insetBy.isNaN) {
    true => offsetPoly(poly, -insetBy, 0, 0),
    false => poly,
  };
  ink.poly(
    material ?? Material.marker,
    support.rough(inner, rng, rough ?? 0.1, 4),
    color,
    alpha ?? 0.94,
  );
  return InkOffset.zero;
}

/// A straight-edged fill with 2-decimal coordinates.
///
/// Mirrors `flatFill` in `src/lib/ink/fills.ts`.
void flatFill(
  Ink ink,
  List<Pt> poly,
  PaintKey color, [
  double alpha = 0.5,
  Material material = Material.marker,
]) {
  if (poly.length < 3) return;
  final d =
      'M${poly.map((p) => '${JsMath.toFixed(p.x, 2)} ${JsMath.toFixed(p.y, 2)}').join('L')}Z';
  ink.flat(material, d, color, op: alpha, bbox: bboxOf(poly));
}

double _solidAlpha(double? alpha, double fallback, [int passes = 1]) {
  final k = switch (passes > 1) {
    true => 1.14,
    false => 1.08,
  };
  return clamp((alpha ?? fallback) * k, 0.3, 0.96);
}

const int _maxBandPoints = 72;

/// A marker band from [a] to [b], [width] wide, with chiselled ends.
///
/// Mirrors `bandPoly` in `src/lib/ink/fills.ts`.
List<Pt> bandPoly(
  Pt a,
  Pt b,
  double width,
  Rng rng, [
  double chisel = 0.34,
  int maxPts = _maxBandPoints,
]) {
  final dx = b.x - a.x, dy = b.y - a.y;
  final l = JsMath.or(JsMath.hypot(dx, dy), 1);
  final ux = dx / l, uy = dy / l, nx = -uy, ny = ux;
  final hw = width / 2;
  final side = switch (rng() < 0.5) {
    true => 1,
    false => -1,
  };
  final sk = math.min(0.45 * l, chisel * width) * side;
  final amp = clamp(0.035 * width + 0.0022 * l, 0.12, 0.65);
  final p1 = rng() * tau, p2 = rng() * tau, p3 = rng() * tau, p4 = rng() * tau;
  final cnt = clamp((l / 4).ceilToDouble(), 3, maxPts.toDouble()).toInt();
  final left = <Pt>[], right = <Pt>[];
  for (var i = 0; i <= cnt; i++) {
    final t = i / cnt;
    final wl =
        amp * (JsMath.sin(5.1 * t + p1) + 0.4 * JsMath.sin(13.7 * t + p2));
    final wr =
        amp * (JsMath.sin(5.1 * t + p3) + 0.4 * JsMath.sin(13.7 * t + p4));
    final cx = a.x + dx * t, cy = a.y + dy * t;
    left.add((cx + nx * (hw + wl), cy + ny * (hw + wl)));
    right.add((cx - nx * (hw + wr), cy - ny * (hw + wr)));
  }
  left[0] = (left[0].x + ux * sk, left[0].y + uy * sk);
  right[0] = (right[0].x - ux * sk, right[0].y - uy * sk);
  left[cnt] = (left[cnt].x + ux * sk, left[cnt].y + uy * sk);
  right[cnt] = (right[cnt].x - ux * sk, right[cnt].y - uy * sk);
  return [...left, ...right.reversed];
}

/// The end style of a band fill (accepted for parity; the fill is solid).
enum BandEnds { loose, flag, square }

/// A marker fill; upstream draws it as a [solidFill] today, the band
/// options are accepted and ignored the same way.
///
/// Mirrors `bandFill` in `src/lib/ink/fills.ts`.
InkOffset bandFill(
  Ink ink,
  List<Pt> poly,
  PaintKey color, {
  double? alpha,
  double? mis,
  int? passes,
  double? angle,
  double? w,
  double? overlap,
  BandEnds? ends,
  Material? material,
}) => solidFill(
  ink,
  poly,
  color,
  alpha: _solidAlpha(alpha, 0.85, passes ?? 1),
  material: material,
);

/// A clipped marker fill, drawn as a [solidFill].
///
/// Mirrors `clipFill` in `src/lib/ink/fills.ts`.
InkOffset clipFill(
  Ink ink,
  List<Pt> poly,
  PaintKey color, {
  double? alpha,
  double? mis,
  double? w,
  double? angle,
  double? overlap,
  double? rough,
  bool? rim,
  Material? material,
}) => solidFill(
  ink,
  poly,
  color,
  alpha: _solidAlpha(alpha, 0.92),
  rough: math.min(rough ?? 0.3, 0.3),
  material: material,
  inset: 0,
);

/// A blot fill for small shapes.
///
/// Mirrors `blobFill` in `src/lib/ink/fills.ts`.
InkOffset blobFill(
  Ink ink,
  List<Pt> poly,
  PaintKey color, {
  double? alpha,
  double? mis,
  double? rough,
  Material? material,
}) {
  final rng = ink.next('blob');
  final at = poly;
  ink.poly(
    material ?? Material.marker,
    support.rough(at, rng, math.min(rough ?? 0.1, 0.12), 4),
    color,
    math.max(alpha ?? 0.9, 0.92),
  );
  return support.shiftOf(poly, at);
}

/// A translucent wash, inset and nudged off register by the misreg knob.
///
/// Mirrors `wash` in `src/lib/ink/fills.ts`.
InkOffset wash(
  Ink ink,
  List<Pt> poly,
  PaintKey color, {
  double? alpha,
  double? inset,
  double? shift,
  double? wobble,
  Material? material,
}) {
  final rng = ink.next('wash');
  final b = bboxOf(poly);
  final size = math.max(b.x1 - b.x0, b.y1 - b.y0);
  final dn = shift ?? 0.007 * size + 0.3;
  final misreg = ink.knobs.misreg;
  final p = wobblePoly(
    densifyClosed(
      offsetPoly(poly, -(inset ?? 0.9), dn * 0.85 * misreg, dn * misreg),
      4,
    ),
    rng,
    (wobble ?? 0.7) * ink.knobs.wobble,
    18,
  );
  ink.poly(material ?? Material.marker, p, color, alpha ?? 0.5);
  return InkOffset(dn * 0.85 * misreg, dn * misreg);
}

/// A polygon fill, drawn as a [solidFill].
///
/// Mirrors `polyFill` in `src/lib/ink/fills.ts`.
InkOffset polyFill(
  Ink ink,
  List<Pt> poly,
  PaintKey color, {
  double? alpha,
  double? mis,
  double? angle,
  double? pw,
  double? overlap,
}) =>
    solidFill(ink, poly, color, alpha: clamp((alpha ?? 0.5) * 1.8, 0.3, 0.96));

/// A rectangle fill, drawn as a [solidFill].
///
/// Mirrors `sweepFill` in `src/lib/ink/fills.ts`.
InkOffset sweepFill(
  Ink ink,
  double x,
  double y,
  double w,
  double h,
  PaintKey color, {
  double? alpha,
  double? pw,
  double? overlap,
  double? mis,
}) => solidFill(
  ink,
  [(x, y), (x + w, y), (x + w, y + h), (x, y + h)],
  color,
  alpha: clamp((alpha ?? 0.48) * 1.9, 0.3, 0.96),
);
