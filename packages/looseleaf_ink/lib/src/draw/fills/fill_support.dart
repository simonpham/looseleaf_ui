import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';

/// [poly] knocked slightly off register: moved, rotated and scaled a little.
///
/// Mirrors `misreg` in `src/lib/ink/fills.ts`.
List<Pt> misreg(
  List<Pt> poly,
  Rng rng, {
  double amt = 3,
  double? bias,
  double? tilt,
  double? grow,
}) {
  final ang = (bias ?? 0.75) + rng.gauss(0, 0.5);
  final k = amt * rng.range(0.7, 1.15);
  final b = bboxOf(poly);
  final bw = b.x1 - b.x0, bh = b.y1 - b.y0;
  final keep = math.min(1, 120 / math.max(math.max(bw, bh), 1));
  final sc =
      1 +
      rng.gauss(0, 0.012) * keep +
      (grow ?? 0) / math.max(10, math.min(bw, bh));
  return xform(
    poly,
    dx: JsMath.cos(ang) * k,
    dy: JsMath.sin(ang) * k,
    rot:
        clamp(rng.gauss(0, 0.014), -0.03, 0.03) *
        (tilt ?? 1) *
        math.min(1, 40 / math.max(20, math.max(bw, bh))),
    sx: sc,
    sy: sc + rng.gauss(0, 0.01) * keep,
  );
}

/// The default misregistration for a polygon's size.
///
/// Mirrors `defaultMis` in `src/lib/ink/fills.ts`.
double defaultMis(List<Pt> poly) {
  final b = bboxOf(poly);
  return clamp(math.min(b.x1 - b.x0, b.y1 - b.y0) * 0.11, 1.6, 6);
}

/// The centroid shift from [from] to [to].
InkOffset shiftOf(List<Pt> from, List<Pt> to) {
  final a = centroid(from), b = centroid(to);
  return InkOffset(b.x - a.x, b.y - a.y);
}

/// The closed polygon densified and roughened along its normals.
///
/// Mirrors `rough` in `src/lib/ink/fills.ts`.
List<Pt> rough(List<Pt> poly, Rng rng, [double amt = 0.8, double step = 4]) {
  final pts = densifyClosed(poly, step);
  final m = pts.length;
  var per = 0.0;
  for (var i = 0; i < m; i++) {
    per += JsMath.hypot(
      pts[(i + 1) % m].x - pts[i].x,
      pts[(i + 1) % m].y - pts[i].y,
    );
  }
  final nz = noise1(rng, per + 60, 22), nz2 = noise1(rng, per + 60, 6);
  final sgn = switch (area(pts) >= 0) {
    true => 1,
    false => -1,
  };
  var s = 0.0;
  final out = <Pt>[];
  for (var i = 0; i < m; i++) {
    final p = pts[i], q = pts[(i + 1) % m], r = pts[(i - 1 + m) % m];
    final tx = q.x - r.x, ty = q.y - r.y;
    final l = JsMath.or(JsMath.hypot(tx, ty), 1);
    if (i != 0) s += JsMath.hypot(p.x - pts[i - 1].x, p.y - pts[i - 1].y);
    final off = amt * (nz(s) * 0.8 + nz2(s) * 0.5);
    out.add((p.x + (ty / l) * sgn * off, p.y - (tx / l) * sgn * off));
  }
  return out;
}
