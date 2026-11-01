import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/shapes/shapes.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

/// The head of an [arrow].
enum ArrowHead { v, two, open, solid, none }

/// A bowed arrow, optionally with a curl, and its head.
///
/// Mirrors `arrowLines` in `src/lib/ink/shapes.ts`.
List<Line> arrowLines(
  Rng rng,
  double x1,
  double y1,
  double x2,
  double y2, {
  ArrowHead? head,
  bool curl = false,
  double? curve,
  double? headLen,
}) {
  final len = JsMath.hypot(x2 - x1, y2 - y1);
  final bow = (curve ?? rng.range(-0.1, 0.1)) * len;
  var shaft = seg(x1, y1, x2, y2, bow, math.max(6, (len / 8).ceil()));
  if (curl) {
    final m = (shaft.length * 0.5).floor(), pm = shaft[m];
    final pn = switch (m + 1 < shaft.length) {
      true => shaft[m + 1],
      false => pm,
    };
    final d0 = dirv(pm, pn), r0 = math.min(9.0, len * 0.09);
    final loopPts = <Pt>[];
    for (var i = 0; i <= 14; i++) {
      final a = -JsMath.pi / 2 + (i / 14) * tau;
      final lx = JsMath.cos(a) * r0, ly = JsMath.sin(a) * r0 * 1.15 + r0 * 1.15;
      loopPts.add((
        pm.x + d0.x * lx * 1.1 + d0.y * (ly - r0 * 1.15),
        pm.y + d0.y * lx * 1.1 - d0.x * (ly - r0 * 1.15),
      ));
    }
    shaft = [...shaft.sublist(0, m), ...loopPts, ...shaft.sublist(m + 1)];
  }
  final out = [
    Line(
      shaft,
      o: const StrokeOpts(end: StrokeEnd.flick, start: StrokeStart.pool),
    ),
  ];
  final style = head ?? ArrowHead.v;
  if (style == ArrowHead.none) return out;
  final p = shaft[shaft.length - 1];
  final q = switch (shaft.length >= 3) {
    true => shaft[shaft.length - 3],
    false => shaft[0],
  };
  final d = dirv(q, p);
  final hl = headLen ?? clamp(len * 0.2, 6, 12);
  final s1 = rng.range(0.42, 0.6), s2 = rng.range(0.42, 0.6);
  final Pt tip = (p.x + rng.gauss(0, 0.3), p.y + rng.gauss(0, 0.3));
  Pt rot(double a, double l) => (
    tip.x - (d.x * JsMath.cos(a) - d.y * JsMath.sin(a)) * l,
    tip.y - (d.x * JsMath.sin(a) + d.y * JsMath.cos(a)) * l,
  );
  final b1 = rot(s1, hl), b2 = rot(-s2, hl * rng.range(0.85, 1.1));
  switch (style) {
    case ArrowHead.v:
      final into = seg(b1.x, b1.y, tip.x, tip.y, rng.gauss(0, 0.3), 3)[1];
      final outOf = seg(tip.x, tip.y, b2.x, b2.y, rng.gauss(0, 0.3), 3)[1];
      out.add(
        Line(
          [b1, into, tip, outOf, b2],
          o: const StrokeOpts(
            end: StrokeEnd.flick,
            start: StrokeStart.soft,
            wobble: 0.5,
          ),
        ),
      );
    case ArrowHead.two:
      out
        ..add(
          Line(
            seg(b1.x, b1.y, tip.x, tip.y, 0.3, 4),
            o: const StrokeOpts(
              end: StrokeEnd.pool,
              start: StrokeStart.soft,
              wobble: 0.5,
            ),
          ),
        )
        ..add(
          Line(
            seg(tip.x, tip.y, b2.x, b2.y, -0.3, 4),
            o: const StrokeOpts(
              end: StrokeEnd.flick,
              start: StrokeStart.soft,
              wobble: 0.5,
            ),
          ),
        );
    case ArrowHead.open:
      out.add(
        Line(
          [b1, tip, b2],
          o: const StrokeOpts(
            end: StrokeEnd.soft,
            start: StrokeStart.soft,
            wobble: 0.4,
            poly: true,
          ),
        ),
      );
    case ArrowHead.solid || ArrowHead.none:
      Pt toward(Pt a, Pt b, double t) =>
          (a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t);
      out.add(
        Line([
          b1,
          tip,
          b2,
          toward(b1, tip, 0.12),
        ], o: const StrokeOpts(end: StrokeEnd.pool, wobble: 0.3, width: 1.1)),
      );
      final Pt c = ((b1.x + b2.x + tip.x) / 3, (b1.y + b2.y + tip.y) / 3);
      out.add(
        Line(
          [toward(b1, c, 0.35), toward(b2, c, 0.3), toward(tip, c, 0.3), c],
          o: const StrokeOpts(end: StrokeEnd.pool, wobble: 0.2, width: 1.3),
        ),
      );
  }
  return out;
}

/// Draws an arrow (ink by default).
///
/// Mirrors `arrow` in `src/lib/ink/shapes.ts`.
void arrow(
  Ink ink,
  double x1,
  double y1,
  double x2,
  double y2, {
  Pen? pen,
  StrokeOpts? opts,
  double? loose,
  ArrowHead? head,
  bool curl = false,
  double? curve,
  double? headLen,
}) => putLines(
  ink,
  'arrow',
  (r) => arrowLines(
    r,
    x1,
    y1,
    x2,
    y2,
    head: head,
    curl: curl,
    curve: curve,
    headLen: headLen,
  ),
  PenName.ink,
  pen,
  opts,
);
