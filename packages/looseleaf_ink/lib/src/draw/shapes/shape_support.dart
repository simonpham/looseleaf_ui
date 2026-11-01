import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

/// Straight, unwobbled ruler strokes.
///
/// Mirrors `RULER` in `src/lib/ink/shapes.ts`.
const StrokeOpts ruler = StrokeOpts(
  poly: true,
  raw: true,
  start: StrokeStart.soft,
  end: StrokeEnd.soft,
  speed: 1,
  dry: 0,
);

/// The unit direction from [a] to [b].
Pt dirv(Pt a, Pt b) {
  final l = JsMath.or(JsMath.hypot(b.x - a.x, b.y - a.y), 1);
  return ((b.x - a.x) / l, (b.y - a.y) / l);
}

/// Draws the lines [gen] makes from `ink.next(salt)` with the shape's pen.
///
/// Mirrors `put` in `src/lib/ink/shapes.ts`.
void putLines(
  Ink ink,
  String salt,
  List<Line> Function(Rng rng) gen,
  Pen defaultPen,
  Pen? pen,
  StrokeOpts? opts,
) {
  ink.lines(gen(ink.next(salt)), pen ?? defaultPen, opts);
}

/// A polyline through [vs], each edge bowed by [bows], with randomly sized
/// rounded corners of about [rad].
///
/// Mirrors `chain` in `src/lib/ink/shapes.ts`.
List<Pt> chain(
  List<Pt> vs,
  List<double> bows,
  double rad,
  Rng rng, [
  double cnt = 14,
]) {
  final e = vs.length - 1;
  final d = <Pt>[];
  final len = <double>[];
  for (var i = 0; i < e; i++) {
    d.add(dirv(vs[i], vs[i + 1]));
    len.add(JsMath.hypot(vs[i + 1].x - vs[i].x, vs[i + 1].y - vs[i].y));
  }
  final rv = List<double>.filled(e + 1, 0);
  for (var j = 1; j < e; j++) {
    final r = math.min(
      math.min(rad * (0.75 + rng() * 0.5), len[j - 1] * 0.45),
      len[j] * 0.45,
    );
    rv[j] = switch (r < 0.6) {
      true => 0,
      false => r,
    };
  }
  final out = <Pt>[];
  for (var i = 0; i < e; i++) {
    final Pt s = (vs[i].x + d[i].x * rv[i], vs[i].y + d[i].y * rv[i]);
    final Pt end = (
      vs[i + 1].x - d[i].x * rv[i + 1],
      vs[i + 1].y - d[i].y * rv[i + 1],
    );
    final bow = switch (i < bows.length) {
      true => JsMath.or(bows[i], 0),
      false => 0.0,
    };
    final cntI = math.max(
      2,
      (JsMath.hypot(end.x - s.x, end.y - s.y) / cnt).ceil(),
    );
    final pts = seg(s.x, s.y, end.x, end.y, bow, cntI);
    if (i > 0 && rv[i] == 0) pts.removeAt(0);
    out.addAll(pts);
    if (i < e - 1 && rv[i + 1] > 0) {
      final v = vs[i + 1], r = rv[i + 1];
      final a = end;
      final Pt b = (v.x + d[i + 1].x * r, v.y + d[i + 1].y * r);
      final k = 0.9 + rng() * 0.1;
      final Pt c = (
        v.x * k + ((a.x + b.x) / 2) * (1 - k),
        v.y * k + ((a.y + b.y) / 2) * (1 - k),
      );
      for (var j = 1; j < 4; j++) {
        final t = j / 4, u = 1 - t;
        out.add((
          u * u * a.x + 2 * u * t * c.x + t * t * b.x,
          u * u * a.y + 2 * u * t * c.y + t * t * b.y,
        ));
      }
    }
  }
  return out;
}
