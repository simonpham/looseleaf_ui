import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/recipes/marks/tools/tools.dart';

const double _minStep = 2.2;

/// [src] without non-finite and too-close points, its last point kept, then
/// smoothed twice; with the pressures (missing ones read as 0.5) when any
/// point had one.
///
/// Mirrors `cleanPoints` in `src/lib/ink/recipes/sketchpad-ink.ts`.
({List<Pt> pts, List<double>? pressure}) cleanPoints(List<SketchPoint> src) {
  final p = <Pt>[];
  final r = <double>[];
  for (final (x, y, pr) in src) {
    if (!x.isFinite || !y.isFinite) continue;
    if (p case [..., final last]
        when JsMath.hypot(x - last.x, y - last.y) < _minStep) {
      continue;
    }
    p.add((x, y));
    r.add(pr ?? -1);
  }
  if (src case [..., (final tx, final ty, final tp)]
      when p.length > 1 && tx.isFinite && ty.isFinite) {
    final last = p[p.length - 1];
    if (JsMath.hypot(tx - last.x, ty - last.y) > 0.4) {
      p.add((tx, ty));
      r.add(tp ?? -1);
    }
  }
  for (var pass = 0; pass < 2 && p.length > 3; pass++) {
    final prev = [...p];
    for (var i = 1; i < p.length - 1; i++) {
      p[i] = (
        (prev[i - 1].x + 2 * prev[i].x + prev[i + 1].x) / 4,
        (prev[i - 1].y + 2 * prev[i].y + prev[i + 1].y) / 4,
      );
    }
  }
  final has = r.any((v) => v >= 0);
  if (!has) return (pts: p, pressure: null);
  return (
    pts: p,
    pressure: [
      for (final v in r)
        switch (v < 0) {
          true => 0.5,
          false => v,
        },
    ],
  );
}

/// Pressure along [pts] (by arc length `t` in `[0, 1]`) from per-point
/// pressures [pr], mapped to a width factor in `[0.55, 1.5]`.
///
/// Mirrors `pressFn` in `src/lib/ink/recipes/sketchpad-ink.ts`.
double Function(double t) pressFn(List<Pt> pts, List<double> pr) {
  final cum = <double>[0];
  for (var i = 1; i < pts.length; i++) {
    cum.add(
      cum[i - 1] +
          JsMath.hypot(pts[i].x - pts[i - 1].x, pts[i].y - pts[i - 1].y),
    );
  }
  final l = JsMath.or(cum[cum.length - 1], 1);
  return (t) {
    final s = clamp(t, 0, 1) * l;
    var i = 1;
    while (i < cum.length - 1 && cum[i] < s) {
      i++;
    }
    final span = JsMath.or(cum[i] - cum[i - 1], 1);
    final u = clamp((s - cum[i - 1]) / span, 0, 1);
    final p = pr[i - 1] + (pr[i] - pr[i - 1]) * u;
    return 0.5 + clamp(p, 0.05, 1);
  };
}

/// A stroke's bounds, `(x0, y0, x1, y1)`.
typedef StrokeBox = (double, double, double, double);

final class _Bounds {
  const _Bounds(this.n, this.size, this.tool, this.b);

  final int n;
  final double size;
  final DrawTool tool;
  final StrokeBox b;
}

final Expando<_Bounds> _boundsOf = Expando('ll-stroke-bounds');

/// The bounds of [s]'s raw points grown by half its width, cached per
/// stroke until its points, size or tool change.
///
/// Mirrors `strokeBounds` in `src/lib/ink/recipes/sketchpad-ink.ts`.
StrokeBox strokeBounds(SketchStroke s) {
  if (_boundsOf[s] case final known?
      when known.n == s.pts.length &&
          known.size == s.size &&
          known.tool == s.tool) {
    return known.b;
  }
  final b = _measureBounds(s);
  _boundsOf[s] = _Bounds(s.pts.length, s.size, s.tool, b);
  return b;
}

StrokeBox _measureBounds(SketchStroke s) {
  var x0 = double.infinity, y0 = double.infinity;
  var x1 = double.negativeInfinity, y1 = double.negativeInfinity;
  for (final (x, y, _) in s.pts) {
    if (x < x0) x0 = x;
    if (x > x1) x1 = x;
    if (y < y0) y0 = y;
    if (y > y1) y1 = y;
  }
  if (x0 == double.infinity) return (0, 0, 0, 0);
  final r = strokeWidth(s.tool, s.size) / 2;
  return (x0 - r, y0 - r, x1 + r, y1 + r);
}

double _segDist(
  double px,
  double py,
  double ax,
  double ay,
  double bx,
  double by,
) {
  final dx = bx - ax, dy = by - ay;
  final l2 = dx * dx + dy * dy;
  final t = switch (l2 == 0) {
    true => 0.0,
    false => clamp(((px - ax) * dx + (py - ay) * dy) / l2, 0, 1),
  };
  return JsMath.hypot(px - (ax + t * dx), py - (ay + t * dy));
}

/// Whether a circle of radius [r] at ([x], [y]) touches stroke [s] (the
/// eraser's hit test).
///
/// Mirrors `strokeHit` in `src/lib/ink/recipes/sketchpad-ink.ts`.
bool strokeHit(SketchStroke s, double x, double y, double r) {
  final reach = r + strokeWidth(s.tool, s.size) / 2;
  final (bx0, by0, bx1, by1) = strokeBounds(s);
  if (x < bx0 - r || x > bx1 + r || y < by0 - r || y > by1 + r) return false;
  final pts = s.pts;
  if (pts.length == 1) {
    return JsMath.hypot(x - pts[0].$1, y - pts[0].$2) <= reach;
  }
  for (var i = 1; i < pts.length; i++) {
    final (ax, ay, _) = pts[i - 1];
    final (bx, by, _) = pts[i];
    if (_segDist(x, y, ax, ay, bx, by) <= reach) return true;
  }
  return false;
}
