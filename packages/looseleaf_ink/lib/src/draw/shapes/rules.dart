import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/shapes/shapes.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

/// A ruler line.
///
/// Mirrors `lineLines` in `src/lib/ink/shapes.ts`.
List<Line> lineLines(double x1, double y1, double x2, double y2) => [
  Line([(x1, y1), (x2, y2)], o: ruler),
];

/// Draws a ruler line (pencil by default).
///
/// Mirrors `line` in `src/lib/ink/shapes.ts`.
void line(
  Ink ink,
  double x1,
  double y1,
  double x2,
  double y2, {
  Pen? pen,
  StrokeOpts? opts,
  double? loose,
}) => putLines(
  ink,
  'line',
  (_) => lineLines(x1, y1, x2, y2),
  PenName.pencil,
  pen,
  opts,
);

/// A wavy line along `y` from `x` to `x + w`; two strokes when wider than 300.
///
/// Mirrors `squiggleLines` in `src/lib/ink/shapes.ts`.
List<Line> squiggleLines(
  Rng rng,
  double x,
  double y,
  double w, {
  double? h,
  double? amp,
  double? wl,
}) {
  final height = h ?? 12;
  final amplitude = clamp(height * 0.2, 1.4, 3.2) * (amp ?? 1);
  final wavelength = clamp(height * 1.1, 10, 18) * (wl ?? 1);
  final p1 = rng.range(0, tau), p2 = rng.range(0, tau), p3 = rng.range(0, tau);
  final drift = rng.gauss(0, 0.6);
  List<Pt> build(double xa, double xb) {
    final pts = <Pt>[];
    var ph = rng.range(0, tau);
    for (var xx = xa; xx <= xb; xx += 1.8) {
      ph +=
          (1.8 / wavelength) *
          tau *
          (1 +
              0.22 * JsMath.sin(xx / 37 + p1) +
              0.1 * JsMath.sin(xx / 11 + p2));
      final a =
          amplitude *
          (0.72 +
              0.28 * JsMath.sin(xx / 53 + p3) +
              0.12 * JsMath.sin(xx / 17 + p1));
      pts.add((
        xx,
        y + JsMath.sin(ph) * a + drift * JsMath.sin(((xx - x) / w) * JsMath.pi),
      ));
    }
    return [
      for (var i = 0; i < pts.length; i += 2) pts[i],
    ];
  }

  if (w > 300) {
    final m = x + w * rng.range(0.46, 0.6);
    final first = build(x, m + 3);
    final second = build(m - 3, x + w);
    return [
      Line(
        first,
        o: const StrokeOpts(
          start: StrokeStart.soft,
          end: StrokeEnd.soft,
          wobble: 0.5,
          speed: 1.1,
        ),
      ),
      Line(
        second,
        o: const StrokeOpts(
          start: StrokeStart.soft,
          end: StrokeEnd.flick,
          wobble: 0.5,
          speed: 1.1,
        ),
      ),
    ];
  }
  return [
    Line(
      build(x, x + w),
      o: const StrokeOpts(end: StrokeEnd.flick, wobble: 0.5, speed: 1.1),
    ),
  ];
}

/// Draws a squiggle (ink by default).
///
/// Mirrors `squiggle` in `src/lib/ink/shapes.ts`.
void squiggle(
  Ink ink,
  double x,
  double y,
  double w, {
  Pen? pen,
  StrokeOpts? opts,
  double? loose,
  double? h,
  double? amp,
  double? wl,
}) => putLines(
  ink,
  'sq',
  (r) => squiggleLines(r, x, y, w, h: h, amp: amp, wl: wl),
  PenName.ink,
  pen,
  opts,
);

/// The kind of [underline].
enum UnderlineKind { single, double, wavy }

/// An underline: single, double or wavy.
///
/// Mirrors `underlineLines` in `src/lib/ink/shapes.ts`.
List<Line> underlineLines(
  Rng rng,
  double x,
  double y,
  double w, {
  UnderlineKind? kind,
}) {
  if (kind == UnderlineKind.wavy) {
    return squiggleLines(rng, x, y, w, h: 7, amp: 0.85);
  }
  return [
    Line([(x, y), (x + w, y)], o: ruler),
    if (kind == UnderlineKind.double)
      Line([(x, y + 3.6), (x + w, y + 3.6)], o: ruler),
  ];
}

/// Draws an underline (ink by default).
///
/// Mirrors `underline` in `src/lib/ink/shapes.ts`.
void underline(
  Ink ink,
  double x,
  double y,
  double w, {
  Pen? pen,
  StrokeOpts? opts,
  double? loose,
  UnderlineKind? kind,
}) => putLines(
  ink,
  'ul',
  (r) => underlineLines(r, x, y, w, kind: kind),
  PenName.ink,
  pen,
  opts,
);

/// A strike-through, optionally doubled.
///
/// Mirrors `strikeLines` in `src/lib/ink/shapes.ts`.
List<Line> strikeLines(
  Rng rng,
  double x,
  double y,
  double w, {
  bool doubled = false,
}) {
  final tilt = rng.gauss(0, 0.012) * w;
  final x1 = x - rng.range(1, 3), x2 = x + w + rng.range(0, 3);
  const so = StrokeOpts(
    start: StrokeStart.soft,
    end: StrokeEnd.flick,
    speed: 1.25,
    wobble: 0.6,
  );
  final steps = (w / 16).ceil();
  final out = [
    Line(
      seg(
        x1,
        y + tilt / 2,
        x2,
        y - tilt / 2,
        rng.gauss(0, 0.003) * w,
        switch (steps < 3) {
          true => 3,
          false => steps,
        },
      ),
      o: so,
    ),
  ];
  if (doubled) {
    out.add(Line(seg(x1 + 2, y + 2.5, x2 - 1, y + 1.5 - tilt, 0, 6), o: so));
  }
  return out;
}

/// Draws a strike-through (red pencil by default).
///
/// Mirrors `strike` in `src/lib/ink/shapes.ts`.
void strike(
  Ink ink,
  double x,
  double y,
  double w, {
  Pen? pen,
  StrokeOpts? opts,
  double? loose,
  bool doubled = false,
}) => putLines(
  ink,
  'st',
  (r) => strikeLines(r, x, y, w, doubled: doubled),
  PenName.red,
  pen,
  opts,
);
