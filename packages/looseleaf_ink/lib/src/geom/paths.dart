import 'dart:math' as math;
import 'dart:typed_data';

import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';

/// Douglas-Peucker on a closed polygon; returns [pts] itself when short.
///
/// Mirrors `simplifyClosed` in `src/lib/ink/geom.ts`.
List<Pt> simplifyClosed(List<Pt> pts, double tol) {
  final m = pts.length;
  if (m < 12 || tol <= 0) return pts;
  var far = 0;
  var fd = -1.0;
  for (var i = 1; i < m; i++) {
    final d =
        JsMath.pow(pts[i].x - pts[0].x, 2) + JsMath.pow(pts[i].y - pts[0].y, 2);
    if (d > fd) {
      fd = d;
      far = i;
    }
  }
  final keep = Uint8List(m);
  keep[0] = 1;
  keep[far] = 1;
  void rec(int a, int b) {
    final len = (b - a + m) % m;
    if (len < 2) return;
    final ax = pts[a].x, ay = pts[a].y, bx = pts[b].x, by = pts[b].y;
    final dx = bx - ax, dy = by - ay;
    final l2 = JsMath.or(dx * dx + dy * dy, 1e-9);
    var md = -1.0;
    var mi = -1;
    for (var k = 1; k < len; k++) {
      final i = (a + k) % m;
      final t = math.max(
        0.0,
        math.min(1.0, ((pts[i].x - ax) * dx + (pts[i].y - ay) * dy) / l2),
      );
      final d = JsMath.hypot(
        pts[i].x - (ax + t * dx),
        pts[i].y - (ay + t * dy),
      );
      if (d > md) {
        md = d;
        mi = i;
      }
    }
    if (md > tol) {
      keep[mi] = 1;
      rec(a, mi);
      rec(mi, b);
    }
  }

  rec(0, far);
  rec(far, 0);
  return [
    for (var i = 0; i < m; i++)
      if (keep[i] == 1) pts[i],
  ];
}

/// A closed smooth path through the midpoints of the simplified polygon.
///
/// Mirrors `smoothClosed` in `src/lib/ink/geom.ts`.
String smoothClosed(List<Pt> pts, TierCfg cfg) {
  final p = simplifyClosed(pts, cfg.tol);
  final m = p.length;
  if (m < 3) return '';
  final w = PathWriter(cfg.q)
    ..m((p[m - 1].x + p[0].x) / 2, (p[m - 1].y + p[0].y) / 2);
  for (var i = 0; i < m; i++) {
    final a = p[i], b = p[(i + 1) % m];
    w.quad(a.x, a.y, (a.x + b.x) / 2, (a.y + b.y) / 2);
  }
  return w.z().d;
}

/// A closed straight-edged path through the simplified polygon.
///
/// Mirrors `simplePath` in `src/lib/ink/geom.ts`.
String simplePath(List<Pt> pts, TierCfg cfg) {
  final p = simplifyClosed(pts, cfg.tol);
  if (p.length < 3) return '';
  final w = PathWriter(cfg.q)..m(p[0].x, p[0].y);
  for (var i = 1; i < p.length; i++) {
    w.l(p[i].x, p[i].y);
  }
  return w.z().d;
}

/// A closed straight-edged path through every point.
///
/// Mirrors `polyPath` in `src/lib/ink/geom.ts`.
String polyPath(List<Pt> pts, [int q = 20]) {
  if (pts.length < 3) return '';
  final w = PathWriter(q)..m(pts[0].x, pts[0].y);
  for (var i = 1; i < pts.length; i++) {
    w.l(pts[i].x, pts[i].y);
  }
  return w.z().d;
}
