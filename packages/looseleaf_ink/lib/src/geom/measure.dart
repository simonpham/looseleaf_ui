import 'dart:math' as math;
import 'dart:typed_data';

import 'package:looseleaf_ink/src/core/core.dart';

/// The length of a polyline.
///
/// Mirrors `pathLength` in `src/lib/ink/geom.ts`.
double pathLength(List<Pt> pts) {
  var length = 0.0;
  for (var i = 1; i < pts.length; i++) {
    length += JsMath.hypot(pts[i].x - pts[i - 1].x, pts[i].y - pts[i - 1].y);
  }
  return length;
}

/// A polyline resampled at even arc length: coordinates `x`, `y`, arc
/// positions `s` and total length `length`.
///
/// Mirrors `Resampled` in `src/lib/ink/geom.ts`.
final class Resampled {
  /// A resampled polyline.
  const Resampled(this.x, this.y, this.s, this.length);

  /// X per sample.
  final Float64List x;

  /// Y per sample.
  final Float64List y;

  /// Arc position per sample.
  final Float64List s;

  /// Total length.
  final double length;
}

/// Resamples [p] at roughly [step] pixels.
///
/// Mirrors `resample` in `src/lib/ink/geom.ts`.
Resampled resample(List<Pt> p, double step) {
  final cum = <double>[0];
  for (var i = 1; i < p.length; i++) {
    cum.add(
      cum[i - 1] + JsMath.hypot(p[i].x - p[i - 1].x, p[i].y - p[i - 1].y),
    );
  }
  final length = cum[cum.length - 1];
  final cnt = math.max(2, JsMath.roundInt(length / step) + 1);
  final x = Float64List(cnt), y = Float64List(cnt), s = Float64List(cnt);
  var j = 0;
  for (var i = 0; i < cnt; i++) {
    final at = (length * i) / (cnt - 1);
    while (j < p.length - 2 && cum[j + 1] < at) {
      j++;
    }
    final segLen = JsMath.or(cum[j + 1] - cum[j], 1);
    final t = clamp((at - cum[j]) / segLen, 0, 1);
    final a = p[j], b = p[math.min(j + 1, p.length - 1)];
    x[i] = a.x + (b.x - a.x) * t;
    y[i] = a.y + (b.y - a.y) * t;
    s[i] = at;
  }
  return Resampled(x, y, s, length);
}

/// The signed area of a closed polygon (positive when clockwise on screen).
///
/// Mirrors `area` in `src/lib/ink/geom.ts`.
double area(List<Pt> pts) {
  var a = 0.0;
  for (var i = 0; i < pts.length; i++) {
    final p = pts[i], q = pts[(i + 1) % pts.length];
    a += p.x * q.y - q.x * p.y;
  }
  return a / 2;
}

/// The bounding box of [pts].
///
/// Mirrors `bboxOf` in `src/lib/ink/geom.ts`.
BBox bboxOf(List<Pt> pts) {
  final box = BBox.empty();
  for (final p in pts) {
    if (p.x < box.x0) box.x0 = p.x;
    if (p.x > box.x1) box.x1 = p.x;
    if (p.y < box.y0) box.y0 = p.y;
    if (p.y > box.y1) box.y1 = p.y;
  }
  return box;
}

/// The area centroid of a polygon, or its box center when degenerate.
///
/// Mirrors `centroid` in `src/lib/ink/geom.ts`.
Pt centroid(List<Pt> poly) {
  var a = 0.0, cx = 0.0, cy = 0.0;
  for (var i = 0; i < poly.length; i++) {
    final (x0, y0) = poly[i];
    final (x1, y1) = poly[(i + 1) % poly.length];
    final c = x0 * y1 - x1 * y0;
    a += c;
    cx += (x0 + x1) * c;
    cy += (y0 + y1) * c;
  }
  if (a.abs() < 1e-6) {
    final b = bboxOf(poly);
    return ((b.x0 + b.x1) / 2, (b.y0 + b.y1) / 2);
  }
  return (cx / (3 * a), cy / (3 * a));
}

/// Whether `(x, y)` is inside the polygon (even-odd).
///
/// Mirrors `inside` in `src/lib/ink/geom.ts`.
bool inside(List<Pt> pts, double x, double y) {
  var c = false;
  for (var i = 0, j = pts.length - 1; i < pts.length; j = i++) {
    final a = pts[i], b = pts[j];
    if ((a.y > y) != (b.y > y) &&
        x < ((b.x - a.x) * (y - a.y)) / (b.y - a.y) + a.x) {
      c = !c;
    }
  }
  return c;
}
