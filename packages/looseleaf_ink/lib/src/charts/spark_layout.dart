import 'dart:math' as math;

import 'package:looseleaf_ink/src/charts/chart_targets.dart';
import 'package:looseleaf_ink/src/charts/curves.dart';
import 'package:looseleaf_ink/src/charts/mini_specs.dart';
import 'package:looseleaf_ink/src/charts/scale.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// A bar rectangle.
typedef BarRect = ({double x, double y, double w, double h});

List<double>? _pt(Pt? p) => switch (p) {
  (final x, final y) => [x, y],
  null => null,
};

/// A laid out sparkline.
///
/// Mirrors `SparkLayout` in `src/lib/ink/charts/chart-mini.ts`.
final class SparkLayout extends ChartLayoutBase {
  /// A layout.
  const SparkLayout({
    required super.w,
    required super.h,
    required super.bucket,
    required super.labels,
    required super.targets,
    required super.cursorAt,
    required this.pts,
    required this.segs,
    required this.bars,
    required this.baseY,
    required this.last,
    required this.minPt,
    required this.maxPt,
  });

  /// One point per value (null for a gap).
  final List<Pt?> pts;

  /// The drawn runs, smoothed.
  final List<List<Pt>> segs;

  /// Bars, for the bar variant.
  final List<BarRect> bars;

  /// The baseline.
  final double baseY;

  /// The last point.
  final Pt? last;

  /// The lowest point.
  final Pt? minPt;

  /// The highest point.
  final Pt? maxPt;

  @override
  Map<String, Object?> toJson() => {
    ...super.toJson(),
    'pts': [for (final p in pts) _pt(p)],
    'segs': [
      for (final s in segs) [for (final p in s) _pt(p)],
    ],
    'bars': [
      for (final b in bars) {'x': b.x, 'y': b.y, 'w': b.w, 'h': b.h},
    ],
    'baseY': baseY,
    'last': _pt(last),
    'minPt': _pt(minPt),
    'maxPt': _pt(maxPt),
  };
}

/// Lays out a sparkline in [box].
///
/// Mirrors `layoutSpark` in `src/lib/ink/charts/chart-mini.ts`.
SparkLayout layoutSpark(SparkSpec spec, Box box) {
  final w = box.w, h = box.h;
  final n = spec.values.length;
  final isBar = spec.variant == SparkVariant.bar;
  final padX = switch (isBar) {
    true => 1.5,
    false => 4.0,
  };
  const padY = 5.0;
  final x0 = padX;
  final x1 =
      w -
      padX -
      switch (spec.ends && !isBar) {
        true => 3,
        false => 0,
      };
  const y0 = padY;
  final y1 = h - padY;
  final span = JsMath.or(spec.max - spec.min, 1);
  double yOf(double v) =>
      clampN(y1 - ((v - spec.min) / span) * (y1 - y0), y0 - 4, y1 + 4);
  final slot = switch (n > 0) {
    true => (x1 - x0) / n,
    false => 0.0,
  };
  double xOf(int i) {
    if (isBar) return x0 + slot * (i + 0.5);
    if (n < 2) return (x0 + x1) / 2;
    return x0 + ((x1 - x0) * i) / (n - 1);
  }

  final pts = <Pt?>[
    for (final (i, v) in spec.values.indexed)
      switch (v) {
        final double value when isNum(value) => (xOf(i), yOf(value)),
        _ => null,
      },
  ];
  final runs = <List<Pt>>[];
  var cur = <Pt>[];
  for (final p in pts) {
    if (p != null) {
      cur.add(p);
      continue;
    }
    if (cur.isNotEmpty) {
      runs.add(cur);
      cur = [];
    }
  }
  if (cur.isNotEmpty) runs.add(cur);
  final segs = [
    for (final r in runs)
      switch (r.length > 2) {
        true => monotoneCurve(r, 3),
        false => r,
      },
  ];
  final bw = clampN(slot * 0.62, 1.6, 14);
  final bars = <BarRect>[
    if (isBar)
      for (final p in pts)
        if (p case (final px, final py))
          (x: px - bw / 2, y: py, w: bw, h: math.max(1.2, y1 - py)),
  ];
  final real = [for (final p in pts) ?p];
  Pt? minPt;
  Pt? maxPt;
  for (final p in real) {
    if (minPt == null || p.$2 > minPt.$2) minPt = p;
    if (maxPt == null || p.$2 < maxPt.$2) maxPt = p;
  }
  final xs = [
    for (final (i, p) in pts.indexed) p?.$1 ?? xOf(i),
  ];
  final targets = ChartTargets(
    n: n,
    mode: TargetMode.x,
    pos: xs,
    cx: xs,
    cy: [for (final p in pts) p?.$2 ?? y1],
    nav: TargetNav.linear,
  );
  List<CursorSpec> cursorAt(int i, [int? series]) {
    if (i < 0 || i >= n) return const [];
    final p = pts[i];
    if (p == null) return const [];
    return [
      CursorSpec(
        kind: CursorKind.ring,
        x: p.$1 - 7,
        y: p.$2 - 7,
        w: 14,
        h: 14,
        slot: spec.slot,
      ),
    ];
  }

  return SparkLayout(
    w: w,
    h: h,
    bucket: bucketOf(w),
    labels: const [],
    targets: targets,
    cursorAt: cursorAt,
    pts: pts,
    segs: segs,
    bars: bars,
    baseY: y1,
    last: real.lastOrNull,
    minPt: minPt,
    maxPt: maxPt,
  );
}
