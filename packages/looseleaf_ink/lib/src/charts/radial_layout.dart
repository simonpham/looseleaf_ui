import 'dart:math' as math;

import 'package:looseleaf_ink/src/charts/chart_label.dart';
import 'package:looseleaf_ink/src/charts/chart_looks.dart';
import 'package:looseleaf_ink/src/charts/chart_targets.dart';
import 'package:looseleaf_ink/src/charts/polar.dart';
import 'package:looseleaf_ink/src/charts/polar_specs.dart';
import 'package:looseleaf_ink/src/charts/scale.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// One radial bar: ring [index] at radius [r], [t] thick, filled from
/// [a0] to [a1] of a track ending at [aEnd].
///
/// Mirrors `RadialArc` in `src/lib/ink/charts/chart-polar.ts`.
final class RadialArc {
  /// An arc.
  const RadialArc({
    required this.index,
    required this.r,
    required this.t,
    required this.a0,
    required this.a1,
    required this.aEnd,
  });

  /// The ring index.
  final int index;

  /// Centre-line radius.
  final double r;

  /// Thickness.
  final double t;

  /// Start angle.
  final double a0;

  /// Value angle.
  final double a1;

  /// Track end angle.
  final double aEnd;

  /// The upstream JSON shape.
  Map<String, Object?> toJson() => {
    'index': index,
    'r': r,
    't': t,
    'a0': a0,
    'a1': a1,
    'aEnd': aEnd,
  };
}

/// A laid out radial bar chart.
///
/// Mirrors `RadialLayout` in `src/lib/ink/charts/chart-polar.ts`.
final class RadialLayout extends ChartLayoutBase {
  /// A layout.
  const RadialLayout({
    required super.w,
    required super.h,
    required super.bucket,
    required super.labels,
    required super.targets,
    required super.cursorAt,
    required this.cx,
    required this.cy,
    required this.radius,
    required this.hole,
    required this.arcs,
  });

  /// Centre x.
  final double cx;

  /// Centre y.
  final double cy;

  /// Outer radius (`R`).
  final double radius;

  /// Hole radius.
  final double hole;

  /// The arcs, outermost first.
  final List<RadialArc> arcs;

  @override
  Map<String, Object?> toJson() => {
    ...super.toJson(),
    'cx': cx,
    'cy': cy,
    'R': radius,
    'hole': hole,
    'arcs': [for (final a in arcs) a.toJson()],
  };
}

/// Lays out a radial bar chart in [box].
///
/// Mirrors `layoutRadial` in `src/lib/ink/charts/chart-polar.ts`.
RadialLayout layoutRadial(RadialSpec spec, Box box, [bool calm = false]) {
  final w = box.w, h = box.h;
  final bucket = bucketOf(w);
  final m = polarMetrics(bucket, calm);
  final labels = <ChartLabel>[];
  final cx = w / 2;
  final cy = h / 2;
  final radius = math.max(20.0, math.min(w, h) / 2 - 8);
  final count = math.max(1, spec.rings.length);
  final hole =
      radius *
      switch (count > 4) {
        true => 0.22,
        false => 0.3,
      };
  final band = (radius - hole) / count;
  final t = clampN(band * 0.7, 6, 28);
  final a0 = deg(spec.start);
  final aEnd = deg(spec.end);
  final arcs = [
    for (final (k, ring) in spec.rings.indexed)
      RadialArc(
        index: k,
        r: radius - band * (k + 0.5),
        t: t,
        a0: a0,
        a1:
            a0 +
            (aEnd - a0) *
                clampN(
                  switch (isNum(ring.value)) {
                    true => ring.value / JsMath.or(ring.max, 1),
                    false => 0,
                  },
                  0,
                  1,
                ),
        aEnd: aEnd,
      ),
  ];
  if (spec.state == ChartState.ready &&
      (spec.end - spec.start).abs() < 330 &&
      bucket != Bucket.sm) {
    final left = spec.start == 0;
    for (final (k, a) in arcs.indexed) {
      labels.add(
        ChartLabel(
          id: 'n-$k',
          text: spec.rings[k].name,
          x:
              cx +
              switch (left) {
                true => -6,
                false => 6,
              },
          y: cy - a.r,
          anchor: switch (left) {
            true => LabelAnchor.end,
            false => LabelAnchor.start,
          },
          valign: LabelValign.middle,
          role: LabelRole.cat,
          size: math.max(12.0, m.tick - 1),
          tone: LabelTone.ink,
          maxW: cx - 10,
        ),
      );
    }
  }
  final mids = [
    for (final a in arcs) polar(cx, cy, a.r, (a.a0 + a.a1) / 2),
  ];
  final targets = ChartTargets(
    n: spec.rings.length,
    mode: TargetMode.sector,
    cx: [for (final p in mids) p.$1],
    cy: [for (final p in mids) p.$2],
    nav: TargetNav.linear,
    sector: SectorTargets(
      cx: cx,
      cy: cy,
      r0: [for (final a in arcs) a.r - band / 2],
      r1: [for (final a in arcs) a.r + band / 2],
      a0: [for (final a in arcs) a.a0],
      a1: [for (final a in arcs) a.aEnd],
    ),
  );
  List<CursorSpec> cursorAt(int i, [int? series]) {
    if (i < 0 || i >= arcs.length) return const [];
    final a = arcs[i];
    final inner = a.r - a.t / 2 - 2;
    final outer = a.r + a.t / 2 + 2;
    final b = boundsAround(
      sectorPoly(cx, cy, inner, outer, a.a0, a.aEnd, 6),
      6,
    );
    return [
      CursorSpec(
        kind: CursorKind.slice,
        x: b.x,
        y: b.y,
        w: b.w,
        h: b.h,
        cx: cx - b.x,
        cy: cy - b.y,
        r0: inner,
        r1: outer,
        a0: a.a0,
        a1: a.aEnd,
      ),
    ];
  }

  if (spec.state != ChartState.ready || spec.rings.isEmpty) {
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
  return RadialLayout(
    w: w,
    h: h,
    bucket: bucket,
    labels: labels,
    targets: targets,
    cursorAt: cursorAt,
    cx: cx,
    cy: cy,
    radius: radius,
    hole: hole,
    arcs: arcs,
  );
}
