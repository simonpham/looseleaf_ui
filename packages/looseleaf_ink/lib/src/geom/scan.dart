import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';

/// One scanline run inside a polygon: row index, ends and length.
///
/// Mirrors `Span` in `src/lib/ink/geom.ts`.
final class Span {
  /// A span on [row] from [a] to [b].
  const Span({
    required this.row,
    required this.a,
    required this.b,
    required this.len,
  });

  /// The scanline index.
  final int row;

  /// Start point.
  final Pt a;

  /// End point.
  final Pt b;

  /// Length.
  final double len;
}

/// Scanlines across [poly] at [angle], [gap] apart, clipped to its inside.
///
/// Mirrors `scanSpans` in `src/lib/ink/geom.ts`.
List<Span> scanSpans(
  List<Pt> poly,
  double angle,
  double gap,
  Rng rng, {
  double jitter = 0.12,
  double inset = 0,
  bool even = true,
}) {
  final bb = bboxOf(poly);
  final cx = (bb.x0 + bb.x1) / 2, cy = (bb.y0 + bb.y1) / 2;
  final ux = JsMath.cos(angle), uy = JsMath.sin(angle);
  final vx = -uy, vy = ux;
  var pmin = double.infinity, pmax = double.negativeInfinity;
  for (final (x, y) in poly) {
    final p = (x - cx) * vx + (y - cy) * vy;
    if (p < pmin) pmin = p;
    if (p > pmax) pmax = p;
  }
  final offs = switch (even) {
    true => _evenRows(pmin, pmax, inset, gap, jitter, rng),
    false => _looseRows(pmin, pmax, gap, jitter, rng),
  };
  final spans = <Span>[];
  for (var row = 0; row < offs.length; row++) {
    final off = offs[row];
    final ox = cx + vx * off, oy = cy + vy * off;
    final ts = <double>[];
    for (var i = 0; i < poly.length; i++) {
      final (x0, y0) = poly[i];
      final (x1, y1) = poly[(i + 1) % poly.length];
      final d0 = (x0 - ox) * vx + (y0 - oy) * vy;
      final d1 = (x1 - ox) * vx + (y1 - oy) * vy;
      if ((d0 <= 0 && d1 > 0) || (d1 <= 0 && d0 > 0)) {
        final t = d0 / (d0 - d1);
        ts.add((x0 + (x1 - x0) * t - ox) * ux + (y0 + (y1 - y0) * t - oy) * uy);
      }
    }
    ts.sort();
    for (var k = 0; k + 1 < ts.length; k += 2) {
      if (ts[k + 1] - ts[k] < 0.8) continue;
      spans.add(
        Span(
          row: row,
          a: (ox + ux * ts[k], oy + uy * ts[k]),
          b: (ox + ux * ts[k + 1], oy + uy * ts[k + 1]),
          len: ts[k + 1] - ts[k],
        ),
      );
    }
  }
  return spans;
}

List<double> _evenRows(
  double pmin,
  double pmax,
  double inset,
  double gap,
  double jitter,
  Rng rng,
) {
  var lo = pmin + inset, hi = pmax - inset;
  if (hi <= lo) lo = hi = (pmin + pmax) / 2;
  if (hi <= lo) return [(pmin + pmax) / 2];
  final rows = JsMath.roundInt((hi - lo) / gap) + 1;
  if (rows <= 1) return [(pmin + pmax) / 2];
  final step = (hi - lo) / (rows - 1);
  final offs = <double>[];
  for (var r = 0; r < rows; r++) {
    final inner = r > 0 && r < rows - 1;
    final jitterOff = switch (inner) {
      true => (rng() - 0.5) * step * jitter * 2,
      false => 0.0,
    };
    offs.add(lo + r * step + jitterOff);
  }
  return offs;
}

List<double> _looseRows(
  double pmin,
  double pmax,
  double gap,
  double jitter,
  Rng rng,
) {
  final offs = <double>[];
  var p = pmin + gap * rng.range(0.2, 0.9);
  while (p < pmax) {
    offs.add(p);
    p += gap * (1 + (rng() - 0.5) * 2 * jitter);
  }
  return offs;
}
