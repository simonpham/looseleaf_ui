import 'dart:math' as math;

import 'package:looseleaf_ink/src/charts/chart_label.dart';
import 'package:looseleaf_ink/src/charts/chart_looks.dart';
import 'package:looseleaf_ink/src/charts/chart_targets.dart';
import 'package:looseleaf_ink/src/charts/polar.dart';
import 'package:looseleaf_ink/src/charts/polar_specs.dart';
import 'package:looseleaf_ink/src/charts/scale.dart';
import 'package:looseleaf_ink/src/charts/text_measure.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

List<double>? _pt(Pt? p) => switch (p) {
  (final x, final y) => [x, y],
  null => null,
};

/// A laid out radar.
///
/// Mirrors `RadarLayout` in `src/lib/ink/charts/chart-polar.ts`.
final class RadarLayout extends ChartLayoutBase {
  /// A layout.
  const RadarLayout({
    required super.w,
    required super.h,
    required super.bucket,
    required super.labels,
    required super.targets,
    required super.cursorAt,
    required this.cx,
    required this.cy,
    required this.radius,
    required this.axesAngles,
    required this.rings,
    required this.polys,
  });

  /// Centre x.
  final double cx;

  /// Centre y.
  final double cy;

  /// Rim radius (`R`).
  final double radius;

  /// The angle of each axis.
  final List<double> axesAngles;

  /// Ring radii, inner to outer.
  final List<double> rings;

  /// Per series, the point on each axis (null for a gap).
  final List<List<Pt?>> polys;

  @override
  Map<String, Object?> toJson() => {
    ...super.toJson(),
    'cx': cx,
    'cy': cy,
    'R': radius,
    'axesAngles': axesAngles,
    'rings': rings,
    'polys': [
      for (final poly in polys) [for (final p in poly) _pt(p)],
    ],
  };
}

/// Lays out a radar in [box].
///
/// Mirrors `layoutRadar` in `src/lib/ink/charts/chart-polar.ts`.
RadarLayout layoutRadar(RadarSpec spec, Box box, [bool calm = false]) {
  final w = box.w, h = box.h;
  final bucket = bucketOf(w);
  final m = polarMetrics(bucket, calm);
  final n = spec.axes.length;
  final labels = <ChartLabel>[];
  final widest = spec.axes.fold(
    0.0,
    (best, t) => math.max(best, textWidth(t, m.tick, m.font)),
  );
  final sidePad = math.min(widest, w * 0.22) + 16;
  final radius = math.max(
    14.0,
    math.min((w - 2 * sidePad) / 2, (h - 2 * (m.tick + 12)) / 2),
  );
  final cx = w / 2;
  final cy = h / 2;
  final axesAngles = [
    for (var k = 0; k < n; k++) (k * tau) / math.max(1, n),
  ];
  final levelCount = math
      .min(12.0, math.max(1.0, JsMath.or(JsMath.round(spec.levels), 1)))
      .toInt();
  final rings = [
    for (var l = 0; l < levelCount; l++) (radius * (l + 1)) / levelCount,
  ];
  final top = JsMath.or(spec.max, 1);
  final polys = [
    for (final s in spec.series)
      [
        for (var k = 0; k < n; k++)
          switch (s.values.elementAtOrNull(k)) {
            final double v when isNum(v) => polar(
              cx,
              cy,
              radius * clampN(v / top, 0, 1.02),
              axesAngles[k],
            ),
            _ => null,
          },
      ],
  ];
  if (spec.state == ChartState.ready && n >= 3) {
    for (final (k, a) in axesAngles.indexed) {
      final p = polar(cx, cy, radius + 10, a);
      final s = JsMath.sin(a);
      final c = JsMath.cos(a);
      labels.add(
        ChartLabel(
          id: 'a-$k',
          text: spec.axes[k],
          x: p.x,
          y: p.y,
          anchor: switch (s) {
            > 0.3 => LabelAnchor.start,
            < -0.3 => LabelAnchor.end,
            _ => LabelAnchor.middle,
          },
          valign: switch (c) {
            > 0.5 => LabelValign.bottom,
            < -0.5 => LabelValign.top,
            _ => LabelValign.middle,
          },
          role: LabelRole.cat,
          size: m.tick,
          tone: LabelTone.ink,
          maxW: sidePad,
        ),
      );
    }
    final gapAngle = JsMath.pi / n;
    for (final (l, t) in spec.ringLabels.indexed) {
      if (t.isEmpty || bucket == Bucket.sm) continue;
      final at = levelCount - 1 - l;
      final r = switch (at >= 0 && at < rings.length) {
        true => rings[at],
        false => 0.0,
      };
      final p = polar(cx, cy, r, gapAngle);
      labels.add(
        ChartLabel(
          id: 'r-$l',
          text: t,
          x: p.x + 2,
          y: p.y,
          anchor: LabelAnchor.start,
          valign: LabelValign.middle,
          role: LabelRole.y,
          size: math.max(12.0, m.tick - 2),
          tone: LabelTone.muted,
        ),
      );
    }
  }
  final tips = [for (final a in axesAngles) polar(cx, cy, radius, a)];
  final half = JsMath.pi / math.max(1, n);
  final targets = ChartTargets(
    n: n,
    mode: TargetMode.sector,
    cx: [for (final p in tips) p.x],
    cy: [for (final p in tips) p.y],
    nav: TargetNav.linear,
    sector: SectorTargets(
      cx: cx,
      cy: cy,
      r0: [for (final _ in axesAngles) 0],
      r1: [for (final _ in axesAngles) radius + 30],
      a0: [for (final a in axesAngles) a - half],
      a1: [for (final a in axesAngles) a + half],
    ),
  );
  List<CursorSpec> cursorAt(int i, [int? series]) {
    if (i < 0 || i >= n) return const [];
    final tip = polar(cx, cy, radius, axesAngles[i]);
    final b = boundsAround([(cx, cy), tip], 10);
    return [
      CursorSpec(
        kind: CursorKind.spoke,
        x: b.x,
        y: b.y,
        w: b.w,
        h: b.h,
        x1: cx - b.x,
        y1: cy - b.y,
        x2: tip.x - b.x,
        y2: tip.y - b.y,
      ),
    ];
  }

  if (spec.state != ChartState.ready || n < 3) {
    labels.add(
      ChartLabel(
        id: 'state',
        text: stateTextOf(spec.stateText, spec.state == ChartState.loading),
        x: cx,
        y: cy,
        anchor: LabelAnchor.middle,
        valign: LabelValign.middle,
        role: LabelRole.center,
        size: m.center * 0.6,
        tone: LabelTone.muted,
      ),
    );
  }
  return RadarLayout(
    w: w,
    h: h,
    bucket: bucket,
    labels: labels,
    targets: targets,
    cursorAt: cursorAt,
    cx: cx,
    cy: cy,
    radius: radius,
    axesAngles: axesAngles,
    rings: rings,
    polys: polys,
  );
}
