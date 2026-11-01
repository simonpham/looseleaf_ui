import 'dart:math' as math;

import 'package:looseleaf_ink/src/charts/chart_label.dart';
import 'package:looseleaf_ink/src/charts/chart_looks.dart';
import 'package:looseleaf_ink/src/charts/chart_targets.dart';
import 'package:looseleaf_ink/src/charts/polar.dart';
import 'package:looseleaf_ink/src/charts/polar_specs.dart';
import 'package:looseleaf_ink/src/charts/scale.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// A gauge zone's angles.
///
/// Mirrors `GaugeZoneGeom` in `src/lib/ink/charts/chart-polar.ts`.
final class GaugeZoneGeom {
  /// A zone.
  const GaugeZoneGeom(this.a0, this.a1, this.slot, this.pattern);

  /// Start angle.
  final double a0;

  /// End angle.
  final double a1;

  /// The colour slot.
  final int slot;

  /// The fill pattern.
  final FillPattern pattern;

  /// The upstream JSON shape.
  Map<String, Object?> toJson() => {
    'a0': a0,
    'a1': a1,
    'slot': slot,
    'pattern': pattern.name,
  };
}

/// A laid out gauge.
///
/// Mirrors `GaugeLayout` in `src/lib/ink/charts/chart-polar.ts`.
final class GaugeLayout extends ChartLayoutBase {
  /// A layout.
  const GaugeLayout({
    required super.w,
    required super.h,
    required super.bucket,
    required super.labels,
    required super.targets,
    required super.cursorAt,
    required this.cx,
    required this.cy,
    required this.radius,
    required this.t,
    required this.a0,
    required this.a1,
    required this.av,
    required this.zones,
    required this.tickAngles,
  });

  /// Centre x.
  final double cx;

  /// Centre y.
  final double cy;

  /// Outer radius (`R`).
  final double radius;

  /// Track thickness.
  final double t;

  /// Start angle.
  final double a0;

  /// End angle.
  final double a1;

  /// Needle angle.
  final double av;

  /// The zones.
  final List<GaugeZoneGeom> zones;

  /// Tick angles.
  final List<double> tickAngles;

  @override
  Map<String, Object?> toJson() => {
    ...super.toJson(),
    'cx': cx,
    'cy': cy,
    'R': radius,
    't': t,
    'a0': a0,
    'a1': a1,
    'av': av,
    'zones': [for (final z in zones) z.toJson()],
    'tickAngles': tickAngles,
  };
}

List<CursorSpec> _noCursor(int i, [int? series]) => const [];

/// Lays out a gauge in [box].
///
/// Mirrors `layoutGauge` in `src/lib/ink/charts/chart-polar.ts`.
GaugeLayout layoutGauge(GaugeSpec spec, Box box, [bool calm = false]) {
  final w = box.w, h = box.h;
  final bucket = bucketOf(w);
  final m = polarMetrics(bucket, calm);
  final labels = <ChartLabel>[];
  final half = deg(spec.sweep) / 2;
  final below = m.center + 6;
  final down = math.max(0.0, -JsMath.cos(half));
  final belowK = switch (spec.sweep <= 180) {
    true => 1.0,
    false => 0.6,
  };
  final radius = math.max(
    20.0,
    math.min(w / 2 - 14, (h - 16 - below * belowK) / (1 + down)),
  );
  final used = radius * (1 + down) + below * belowK;
  final cx = w / 2;
  final cy = math.max(radius + 6, (h - used) / 2 + radius);
  final t = clampN(radius * 0.2, 9, 30);
  final span = math.max(1e-6, spec.max - spec.min);
  final f = clampN((spec.value - spec.min) / span, 0, 1);
  final a0 = -half;
  final a1 = half;
  final av = a0 + (a1 - a0) * f;
  final zones = <GaugeZoneGeom>[];
  var prev = spec.min;
  for (final z in spec.zones) {
    final to = clampN(z.to, spec.min, spec.max);
    if (to > prev) {
      zones.add(
        GaugeZoneGeom(
          a0 + ((prev - spec.min) / span) * (a1 - a0),
          a0 + ((to - spec.min) / span) * (a1 - a0),
          z.slot,
          z.pattern,
        ),
      );
    }
    prev = to;
  }
  final tickCount = math
      .min(60.0, math.max(0.0, JsMath.or(JsMath.round(spec.ticks), 0)))
      .toInt();
  final tickAngles = [
    for (var k = 0; k <= tickCount; k++)
      a0 + ((a1 - a0) * k) / math.max(1, tickCount),
  ];
  if (spec.state == ChartState.ready) {
    final pa = polar(cx, cy, radius - t / 2, a0);
    final pb = polar(cx, cy, radius - t / 2, a1);
    labels
      ..add(
        ChartLabel(
          id: 'min',
          text: spec.minLabel,
          x: pa.$1,
          y: pa.$2 + t / 2 + 6,
          anchor: LabelAnchor.middle,
          valign: LabelValign.top,
          role: LabelRole.x,
          size: m.tick,
          tone: LabelTone.muted,
        ),
      )
      ..add(
        ChartLabel(
          id: 'max',
          text: spec.maxLabel,
          x: pb.$1,
          y: pb.$2 + t / 2 + 6,
          anchor: LabelAnchor.middle,
          valign: LabelValign.top,
          role: LabelRole.x,
          size: m.tick,
          tone: LabelTone.muted,
        ),
      );
  }
  if (spec.state != ChartState.ready) {
    labels.add(
      ChartLabel(
        id: 'state',
        text: stateTextOf(spec.stateText, spec.state == ChartState.loading),
        x: cx,
        y: cy - radius * 0.35,
        anchor: LabelAnchor.middle,
        valign: LabelValign.middle,
        role: LabelRole.center,
        size: m.center * 0.6,
        tone: LabelTone.muted,
      ),
    );
  }
  return GaugeLayout(
    w: w,
    h: h,
    bucket: bucket,
    labels: labels,
    targets: const ChartTargets(
      n: 0,
      mode: TargetMode.point,
      cx: [],
      cy: [],
      nav: TargetNav.linear,
    ),
    cursorAt: _noCursor,
    cx: cx,
    cy: cy,
    radius: radius,
    t: t,
    a0: a0,
    a1: a1,
    av: av,
    zones: zones,
    tickAngles: tickAngles,
  );
}
