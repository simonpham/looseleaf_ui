import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

/// Dashes around a rounded rectangle, as straight simple strokes.
///
/// Mirrors `dashedBoxLines` in `src/lib/ink/shapes.ts`.
List<Line> dashedBoxLines(
  Rng rng,
  double x,
  double y,
  double w,
  double h, {
  double? r,
  double? dash,
  double? gap,
}) {
  final radius = math.min(math.min(r ?? 4, w / 2), h / 2);
  final cornerPts = _corners(x, y, w, h, radius);
  final closed = [...cornerPts, cornerPts[0]];
  final cum = <double>[0];
  for (var i = 1; i < closed.length; i++) {
    cum.add(
      cum[i - 1] +
          JsMath.hypot(
            closed[i].x - closed[i - 1].x,
            closed[i].y - closed[i - 1].y,
          ),
    );
  }
  final perimeter = cum[cum.length - 1];
  Pt at(double d) {
    d = (d.remainder(perimeter) + perimeter).remainder(perimeter);
    var i = 1;
    while (i < cum.length - 1 && cum[i] < d) {
      i++;
    }
    final t = (d - cum[i - 1]) / JsMath.or(cum[i] - cum[i - 1], 1);
    return (
      closed[i - 1].x + (closed[i].x - closed[i - 1].x) * t,
      closed[i - 1].y + (closed[i].y - closed[i - 1].y) * t,
    );
  }

  final dashLen = dash ?? clamp(math.min(w, h) * 0.3, 5, 9);
  final gapLen = gap ?? dashLen * 0.55;
  final count = math.max(4, JsMath.roundInt(perimeter / (dashLen + gapLen)));
  final step = perimeter / count;
  final len = step * (dashLen / (dashLen + gapLen));
  final d0 = rng() * step;
  const o = StrokeOpts(
    poly: true,
    raw: true,
    start: StrokeStart.soft,
    end: StrokeEnd.soft,
    speed: 1,
    dry: 0,
    simple: true,
  );
  return [
    for (var i = 0; i < count; i++)
      Line([
        for (var k = 0; k <= 4; k++) at(d0 + i * step + (len * k) / 4),
      ], o: o),
  ];
}

List<Pt> _corners(double x, double y, double w, double h, double r) {
  if (r < 0.5) return [(x, y), (x + w, y), (x + w, y + h), (x, y + h)];
  const per = 5;
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

/// Draws a dashed rounded box as one stroked path (pencil by default).
///
/// Mirrors `dashedBox` in `src/lib/ink/shapes.ts`.
void dashedBox(
  Ink ink,
  double x,
  double y,
  double w,
  double h, {
  Pen? pen,
  StrokeOpts? opts,
  double? loose,
  double? r,
  double? dash,
  double? gap,
}) {
  final p = (pen ?? PenName.pencil).spec;
  final color = opts?.color ?? p.color;
  final sw = p.w * 0.85 * (opts?.width ?? 1) * ink.knobs.width;
  final d = StringBuffer();
  for (final l in dashedBoxLines(
    ink.next('dash'),
    x,
    y,
    w,
    h,
    r: r,
    dash: dash,
    gap: gap,
  )) {
    d.write(
      'M${l.pts.map((pt) => '${n(pt.x, 100)} ${n(pt.y, 100)}').join('L')}',
    );
  }
  final material = switch (p.kind) {
    PenKind.pencil => Material.pencil,
    _ => Material.felt,
  };
  ink.flat(
    material,
    d.toString(),
    color,
    op: p.alpha * (opts?.alpha ?? 1),
    stroke: color,
    sw: sw,
    bbox: BBox(x - sw, y - sw, x + w + sw, y + h + sw),
  );
}
