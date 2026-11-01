import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/shapes/shapes.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

/// The outline of a [focusRing].
enum FocusShape { rect, ellipse }

const StrokeOpts _tick = StrokeOpts(
  end: StrokeEnd.flick,
  start: StrokeStart.soft,
  wobble: 0.3,
  width: 0.8,
);

/// A ring [gap] outside the box, with optional corner ticks.
///
/// Mirrors `focusRingLines` in `src/lib/ink/shapes.ts`.
List<Line> focusRingLines(
  Rng rng,
  double x,
  double y,
  double w,
  double h, {
  FocusShape? shape,
  double? gap,
  double? r,
  bool ticks = false,
}) {
  final g = gap ?? 4;
  final rect = (shape ?? FocusShape.rect) == FocusShape.rect;
  final bx = x - g, by = y - g, bw = w + g * 2, bh = h + g * 2;
  final out = <Line>[
    ...switch (rect) {
      true => boxLines(rng.fork('ring'), bx, by, bw, bh, corner: (r ?? 4) + g),
      false => loopLines(
        rng.fork('ring'),
        x + w / 2,
        y + h / 2,
        bw / 2,
        bh / 2,
        clean: true,
      ),
    },
  ];
  if (!ticks) return out;
  final tr = rng.fork('ticks');
  if (rect) {
    final corners = <(double, double, double, double)>[
      (bx, by, -1, -1),
      (bx + bw, by, 1, -1),
      (bx + bw, by + bh, 1, 1),
      (bx, by + bh, -1, 1),
    ];
    final inset = ((r ?? 4) + g) * (1 - 0.7071067811865476);
    for (final (cx, cy, sx, sy) in corners) {
      if (tr() < 0.15) continue;
      final a = JsMath.atan2(sy, sx) + tr.gauss(0, 0.15);
      final r0 = 2 + inset, r1 = r0 + 3 + tr() * 2.5;
      out.add(
        Line(
          seg(
            cx + JsMath.cos(a) * r0,
            cy + JsMath.sin(a) * r0,
            cx + JsMath.cos(a) * r1,
            cy + JsMath.sin(a) * r1,
            0.3,
            3,
          ),
          o: _tick,
        ),
      );
    }
    return out;
  }
  final cx = x + w / 2, cy = y + h / 2;
  for (final base in [-0.75 * JsMath.pi, 0.25 * JsMath.pi]) {
    final a = base + tr.gauss(0, 0.2);
    final ex = JsMath.cos(a), ey = JsMath.sin(a);
    final r0 = JsMath.hypot(ex * (bw / 2), ey * (bh / 2)) + 2,
        r1 = r0 + 3 + tr() * 2.5;
    out.add(
      Line(
        seg(cx + ex * r0, cy + ey * r0, cx + ex * r1, cy + ey * r1, 0.3, 3),
        o: _tick,
      ),
    );
  }
  return out;
}

/// Draws a focus ring (focus felt by default).
///
/// Mirrors `focusRing` in `src/lib/ink/shapes.ts`.
void focusRing(
  Ink ink,
  double x,
  double y,
  double w,
  double h, {
  Pen? pen,
  StrokeOpts? opts,
  double? loose,
  FocusShape? shape,
  double? gap,
  double? r,
  bool ticks = false,
}) => putLines(
  ink,
  'focus',
  (rng) => focusRingLines(
    rng,
    x,
    y,
    w,
    h,
    shape: shape,
    gap: gap,
    r: r,
    ticks: ticks,
  ),
  PenName.focus,
  pen,
  opts,
);
