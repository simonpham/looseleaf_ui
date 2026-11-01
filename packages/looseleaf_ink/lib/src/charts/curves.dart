import 'dart:math' as math;

import 'package:looseleaf_ink/src/core/core.dart';

/// A monotone cubic through [pts] (no overshoot), sampled every [step] px.
///
/// Mirrors `monotoneCurve` in `src/lib/ink/charts/chart-scale.ts`.
List<Pt> monotoneCurve(List<Pt> pts, [double step = 4]) {
  final n = pts.length;
  if (n < 3) return [...pts];
  final dx = <double>[];
  final m = <double>[];
  for (var i = 0; i < n - 1; i++) {
    dx.add(JsMath.or(pts[i + 1].x - pts[i].x, 1e-6));
    m.add((pts[i + 1].y - pts[i].y) / dx[i]);
  }
  final t = List<double>.filled(n, 0);
  t[0] = m[0];
  t[n - 1] = m[n - 2];
  for (var i = 1; i < n - 1; i++) {
    t[i] = switch (m[i - 1] * m[i] <= 0) {
      true => 0,
      false => (m[i - 1] + m[i]) / 2,
    };
  }
  for (var i = 0; i < n - 1; i++) {
    if (m[i] == 0) {
      t[i] = 0;
      t[i + 1] = 0;
      continue;
    }
    final a = t[i] / m[i];
    final b = t[i + 1] / m[i];
    final s = a * a + b * b;
    if (s > 9) {
      final k = 3 / JsMath.sqrt(s);
      t[i] = k * a * m[i];
      t[i + 1] = k * b * m[i];
    }
  }
  final out = <Pt>[(pts[0].x, pts[0].y)];
  for (var i = 0; i < n - 1; i++) {
    final cnt = math.max(2, (dx[i] / step).ceil());
    for (var k = 1; k <= cnt; k++) {
      final u = k / cnt;
      final u2 = u * u;
      final u3 = u2 * u;
      final h00 = 2 * u3 - 3 * u2 + 1;
      final h10 = u3 - 2 * u2 + u;
      final h01 = -2 * u3 + 3 * u2;
      final h11 = u3 - u2;
      out.add((
        pts[i].x + dx[i] * u,
        h00 * pts[i].y +
            h10 * dx[i] * t[i] +
            h01 * pts[i + 1].y +
            h11 * dx[i] * t[i + 1],
      ));
    }
  }
  return out;
}

/// [pts] as a step line: horizontal, then vertical.
///
/// Mirrors `stepCurve` in `src/lib/ink/charts/chart-scale.ts`.
List<Pt> stepCurve(List<Pt> pts) => [
  for (var i = 0; i < pts.length; i++) ...[
    if (i > 0) (pts[i].x, pts[i - 1].y),
    pts[i],
  ],
];

/// Largest-triangle-three-buckets: the indices of [threshold] points that
/// keep [pts]' shape.
///
/// Mirrors `lttb` in `src/lib/ink/charts/chart-scale.ts`.
List<int> lttb(List<Pt> pts, int threshold) {
  final n = pts.length;
  if (threshold >= n || threshold < 3) {
    return [for (var i = 0; i < n; i++) i];
  }
  final keep = <int>[0];
  final every = (n - 2) / (threshold - 2);
  var a = 0;
  for (var i = 0; i < threshold - 2; i++) {
    final s0 = ((i + 1) * every).floor() + 1;
    final s1 = math.min(((i + 2) * every).floor() + 1, n);
    var ax = 0.0;
    var ay = 0.0;
    for (var j = s0; j < s1; j++) {
      ax += pts[j].x;
      ay += pts[j].y;
    }
    final c = math.max(1, s1 - s0);
    ax /= c;
    ay /= c;
    final r0 = (i * every).floor() + 1;
    final r1 = math.min(((i + 1) * every).floor() + 1, n);
    var best = -1.0;
    var pick = r0;
    for (var j = r0; j < r1; j++) {
      final area =
          ((pts[a].x - ax) * (pts[j].y - pts[a].y) -
                  (pts[a].x - pts[j].x) * (ay - pts[a].y))
              .abs();
      if (area > best) {
        best = area;
        pick = j;
      }
    }
    keep.add(pick);
    a = pick;
  }
  keep.add(n - 1);
  return keep;
}

/// At most [max] evenly spread indices of `0..n-1`, ends included.
///
/// Mirrors `thinIndices` in `src/lib/ink/charts/chart-scale.ts`.
List<int> thinIndices(int n, int max) {
  if (n <= max || max < 2) return [for (var i = 0; i < n; i++) i];
  return {
    for (var k = 0; k < max; k++) JsMath.roundInt((k * (n - 1)) / (max - 1)),
  }.toList();
}

/// Every k-th index of `0..n-1`, so at most [max] remain.
///
/// Mirrors `strideIndices` in `src/lib/ink/charts/chart-scale.ts`.
List<int> strideIndices(int n, int max) {
  final k = math.max(1, (n / math.max(1, max)).ceil());
  return [for (var i = 0; i < n; i += k) i];
}
