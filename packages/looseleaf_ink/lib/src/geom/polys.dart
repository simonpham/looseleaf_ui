import 'dart:math' as math;

import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';

/// Moves, rotates and scales [pts] about [about] (default: their centroid).
///
/// Mirrors `xform` in `src/lib/ink/geom.ts`.
List<Pt> xform(
  List<Pt> pts, {
  double dx = 0,
  double dy = 0,
  double rot = 0,
  double sx = 1,
  double? sy,
  Pt? about,
}) {
  final scaleY = sy ?? sx;
  final (cx, cy) = about ?? centroid(pts);
  final c = JsMath.cos(rot), s = JsMath.sin(rot);
  return [
    for (final (x, y) in pts)
      (
        cx + (x - cx) * sx * c - (y - cy) * scaleY * s + dx,
        cy + (x - cx) * sx * s + (y - cy) * scaleY * c + dy,
      ),
  ];
}

/// A rounded rectangle as a polygon, [per] segments per corner.
///
/// Mirrors `roundRectPoly` in `src/lib/ink/geom.ts`.
List<Pt> roundRectPoly(
  double x,
  double y,
  double w,
  double h, [
  double r = 0,
  int per = 5,
]) {
  r = math.min(math.min(r, w / 2), h / 2);
  if (r < 0.3) return [(x, y), (x + w, y), (x + w, y + h), (x, y + h)];
  final pts = <Pt>[];
  void arc(double cx, double cy, double a0) {
    for (var i = 0; i <= per; i++) {
      final a = a0 + (i / per) * (JsMath.pi / 2);
      pts.add((cx + JsMath.cos(a) * r, cy + JsMath.sin(a) * r));
    }
  }

  arc(x + w - r, y + r, -JsMath.pi / 2);
  arc(x + w - r, y + h - r, 0);
  arc(x + r, y + h - r, JsMath.pi / 2);
  arc(x + r, y + r, JsMath.pi);
  return pts;
}

/// Same as [roundRectPoly].
///
/// Mirrors `rectPoly` in `src/lib/ink/geom.ts`.
List<Pt> rectPoly(
  double x,
  double y,
  double w,
  double h, [
  double r = 0,
  int per = 5,
]) => roundRectPoly(x, y, w, h, r, per);

/// A pill (fully rounded rectangle) as a polygon.
///
/// Mirrors `pillPoly` in `src/lib/ink/geom.ts`.
List<Pt> pillPoly(double x, double y, double w, double h, [int per = 7]) =>
    roundRectPoly(x, y, w, h, h / 2, per);

/// An ellipse as [cnt] points, rotated by [rot].
///
/// Mirrors `ellipsePoly` in `src/lib/ink/geom.ts`.
List<Pt> ellipsePoly(
  double cx,
  double cy,
  double rx,
  double ry, [
  int cnt = 28,
  double rot = 0,
]) {
  final c = JsMath.cos(rot), s = JsMath.sin(rot);
  final pts = <Pt>[];
  for (var i = 0; i < cnt; i++) {
    final a = (i / cnt) * tau;
    final x = JsMath.cos(a) * rx, y = JsMath.sin(a) * ry;
    pts.add((cx + x * c - y * s, cy + x * s + y * c));
  }
  return pts;
}

/// The closed polygon with points added every [step] pixels or less.
///
/// Mirrors `densifyClosed` in `src/lib/ink/geom.ts`.
List<Pt> densifyClosed(List<Pt> pts, [double step = 4]) {
  final out = <Pt>[];
  for (var i = 0; i < pts.length; i++) {
    final a = pts[i], b = pts[(i + 1) % pts.length];
    final c = math.max(1, (JsMath.hypot(b.x - a.x, b.y - a.y) / step).ceil());
    for (var k = 0; k < c; k++) {
      out.add((a.x + ((b.x - a.x) * k) / c, a.y + ((b.y - a.y) * k) / c));
    }
  }
  return out;
}

/// The closed polygon pushed in and out along its normals by noise.
///
/// Mirrors `wobblePoly` in `src/lib/ink/geom.ts`.
List<Pt> wobblePoly(List<Pt> pts, Rng rng, double amp, [double wl = 24]) {
  final m = pts.length;
  final cum = <double>[0];
  for (var i = 1; i <= m; i++) {
    cum.add(
      cum[i - 1] +
          JsMath.hypot(
            pts[i % m].x - pts[i - 1].x,
            pts[i % m].y - pts[i - 1].y,
          ),
    );
  }
  final f = noise1(rng, cum[m], wl), g = noise1(rng, cum[m], wl * 0.3);
  final sg = switch (area(pts) >= 0) {
    true => 1,
    false => -1,
  };
  return [
    for (var i = 0; i < m; i++) _wobbled(pts, i, cum[i], amp, f, g, sg),
  ];
}

Pt _wobbled(
  List<Pt> pts,
  int i,
  double at,
  double amp,
  double Function(double) f,
  double Function(double) g,
  int sg,
) {
  final m = pts.length;
  final p = pts[i], a = pts[(i + m - 1) % m], b = pts[(i + 1) % m];
  final tx = b.x - a.x, ty = b.y - a.y, l = JsMath.or(JsMath.hypot(tx, ty), 1);
  final off = amp * (f(at) + 0.3 * g(at));
  return (p.x + (ty / l) * off * sg, p.y - (tx / l) * off * sg);
}

/// The closed polygon offset outward by [d] (inward when negative), then moved.
///
/// Mirrors `offsetPoly` in `src/lib/ink/geom.ts`.
List<Pt> offsetPoly(List<Pt> pts, double d, [double dx = 0, double dy = 0]) {
  final m = pts.length;
  final sg = switch (area(pts) > 0) {
    true => 1,
    false => -1,
  };
  final out = <Pt>[];
  for (var i = 0; i < m; i++) {
    final p = pts[i], a = pts[(i + m - 1) % m], b = pts[(i + 1) % m];
    final n1 = _normal(a, p, sg), n2 = _normal(p, b, sg);
    var nx = n1.x + n2.x, ny = n1.y + n2.y;
    final l = JsMath.or(JsMath.hypot(nx, ny), 1);
    nx /= l;
    ny /= l;
    final c = math.max(0.5, nx * n1.x + ny * n1.y);
    out.add((p.x + (nx * d) / c + dx, p.y + (ny * d) / c + dy));
  }
  return out;
}

Pt _normal(Pt a, Pt b, int sg) {
  final tx = b.x - a.x, ty = b.y - a.y, l = JsMath.or(JsMath.hypot(tx, ty), 1);
  return ((ty / l) * sg, (-tx / l) * sg);
}
