import 'dart:math' as math;

import 'package:looseleaf_ink/src/core/core.dart';

Pt _mix(Pt a, Pt b, double t) => (a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t);

/// [cnt] + 1 points from `(x1, y1)` to `(x2, y2)`, bowed sideways by [bow].
///
/// Mirrors `seg` in `src/lib/ink/geom.ts`.
List<Pt> seg(
  double x1,
  double y1,
  double x2,
  double y2, [
  double bow = 0,
  int cnt = 8,
]) {
  final dx = x2 - x1, dy = y2 - y1;
  final len = JsMath.or(JsMath.hypot(dx, dy), 1);
  final nx = -dy / len, ny = dx / len;
  final out = <Pt>[];
  for (var i = 0; i <= cnt; i++) {
    final t = i / cnt;
    final b = bow * JsMath.sin(JsMath.pi * t);
    out.add((x1 + dx * t + nx * b, y1 + dy * t + ny * b));
  }
  return out;
}

/// The polyline with points added every [step] pixels or less.
///
/// Mirrors `densify` in `src/lib/ink/geom.ts`.
List<Pt> densify(List<Pt> pts, [double step = 1.5]) {
  final out = <Pt>[(pts[0].x, pts[0].y)];
  for (var i = 1; i < pts.length; i++) {
    final a = pts[i - 1], b = pts[i];
    final c = math.max(1, (JsMath.hypot(b.x - a.x, b.y - a.y) / step).ceil());
    for (var k = 1; k <= c; k++) {
      out.add(_mix(a, b, k / c));
    }
  }
  return out;
}

/// A centripetal Catmull-Rom spline through [pts], sampled every [step].
///
/// Mirrors `spline` in `src/lib/ink/geom.ts`.
List<Pt> spline(List<Pt> pts, [double step = 1.5]) {
  if (pts.length < 3) return densify(pts, step);
  final out = <Pt>[];
  final first = pts[0],
      second = pts[1],
      last = pts[pts.length - 1],
      prev = pts[pts.length - 2];
  final p = <Pt>[
    (first.x - (second.x - first.x), first.y - (second.y - first.y)),
    ...pts,
    (last.x + (last.x - prev.x), last.y + (last.y - prev.y)),
  ];
  for (var i = 1; i < p.length - 2; i++) {
    final p0 = p[i - 1], p1 = p[i], p2 = p[i + 1], p3 = p[i + 2];
    final d01 = math.max(
      1e-3,
      JsMath.pow(JsMath.hypot(p1.x - p0.x, p1.y - p0.y), 0.5),
    );
    final d12 = math.max(
      1e-3,
      JsMath.pow(JsMath.hypot(p2.x - p1.x, p2.y - p1.y), 0.5),
    );
    final d23 = math.max(
      1e-3,
      JsMath.pow(JsMath.hypot(p3.x - p2.x, p3.y - p2.y), 0.5),
    );
    final cnt = math.max(
      2,
      (JsMath.hypot(p2.x - p1.x, p2.y - p1.y) / step).ceil(),
    );
    final t1 = d01, t2 = d01 + d12, t3 = d01 + d12 + d23;
    for (var k = 0; k < cnt; k++) {
      final u = t1 + (t2 - t1) * (k / cnt);
      final a1 = _mix(p0, p1, u / t1);
      final a2 = _mix(p1, p2, (u - t1) / (t2 - t1));
      final a3 = _mix(p2, p3, (u - t2) / (t3 - t2));
      final b1 = _mix(a1, a2, u / t2);
      final b2 = _mix(a2, a3, (u - t1) / (t3 - t1));
      out.add(_mix(b1, b2, (u - t1) / (t2 - t1)));
    }
  }
  out.add((last.x, last.y));
  return out;
}

/// The polyline with each inner corner rounded by a quadratic of radius [r].
///
/// Mirrors `fillet` in `src/lib/ink/geom.ts`.
List<Pt> fillet(List<Pt> pts, double r) {
  if (pts.length < 3 || r <= 0) return pts;
  final out = <Pt>[pts[0]];
  for (var i = 1; i < pts.length - 1; i++) {
    final a = pts[i - 1], b = pts[i], c = pts[i + 1];
    final l1 = JsMath.or(JsMath.hypot(b.x - a.x, b.y - a.y), 1);
    final l2 = JsMath.or(JsMath.hypot(c.x - b.x, c.y - b.y), 1);
    final rr = math.min(math.min(r, l1 * 0.45), l2 * 0.45);
    final Pt p1 = (
      b.x + ((a.x - b.x) / l1) * rr,
      b.y + ((a.y - b.y) / l1) * rr,
    );
    final Pt p2 = (
      b.x + ((c.x - b.x) / l2) * rr,
      b.y + ((c.y - b.y) / l2) * rr,
    );
    for (var k = 0; k <= 5; k++) {
      final t = k / 5, u = 1 - t;
      out.add((
        u * u * p1.x + 2 * u * t * b.x + t * t * p2.x,
        u * u * p1.y + 2 * u * t * b.y + t * t * p2.y,
      ));
    }
  }
  out.add(pts[pts.length - 1]);
  return out;
}

/// The polyline with inner corners rounded by slightly random radii.
///
/// Mirrors `rounded` in `src/lib/ink/geom.ts`.
List<Pt> rounded(List<Pt> verts, double rad, Rng rng, [int per = 5]) {
  final out = <Pt>[(verts[0].x, verts[0].y)];
  for (var i = 1; i < verts.length - 1; i++) {
    final p = verts[i - 1], v = verts[i], nx = verts[i + 1];
    final l1 = JsMath.or(JsMath.hypot(p.x - v.x, p.y - v.y), 1);
    final l2 = JsMath.or(JsMath.hypot(nx.x - v.x, nx.y - v.y), 1);
    final r = math.min(
      math.min(rad * (0.75 + rng() * 0.5), l1 * 0.48),
      l2 * 0.48,
    );
    if (r < 0.6) {
      out.add((v.x, v.y));
      continue;
    }
    final Pt a = (v.x + ((p.x - v.x) / l1) * r, v.y + ((p.y - v.y) / l1) * r);
    final Pt b = (v.x + ((nx.x - v.x) / l2) * r, v.y + ((nx.y - v.y) / l2) * r);
    final k = 0.9 + rng() * 0.1;
    final Pt c = (
      v.x * k + ((a.x + b.x) / 2) * (1 - k),
      v.y * k + ((a.y + b.y) / 2) * (1 - k),
    );
    for (var j = 0; j <= per; j++) {
      final t = j / per, u = 1 - t;
      out.add((
        u * u * a.x + 2 * u * t * c.x + t * t * b.x,
        u * u * a.y + 2 * u * t * c.y + t * t * b.y,
      ));
    }
  }
  final e = verts[verts.length - 1];
  out.add((e.x, e.y));
  return out;
}
