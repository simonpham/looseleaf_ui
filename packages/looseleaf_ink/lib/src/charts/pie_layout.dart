import 'dart:math' as math;

import 'package:looseleaf_ink/src/charts/chart_label.dart';
import 'package:looseleaf_ink/src/charts/chart_looks.dart';
import 'package:looseleaf_ink/src/charts/chart_targets.dart';
import 'package:looseleaf_ink/src/charts/polar.dart';
import 'package:looseleaf_ink/src/charts/polar_specs.dart';
import 'package:looseleaf_ink/src/charts/scale.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// One pie sector: slice [index], its angles and share.
///
/// Mirrors `PieSector` in `src/lib/ink/charts/chart-polar.ts`.
final class PieSector {
  /// A sector.
  const PieSector(this.index, this.a0, this.a1, this.fraction);

  /// The slice index.
  final int index;

  /// Start angle.
  final double a0;

  /// End angle.
  final double a1;

  /// Share of the total.
  final double fraction;

  /// The upstream JSON shape.
  Map<String, Object?> toJson() => {
    'index': index,
    'a0': a0,
    'a1': a1,
    'fraction': fraction,
  };
}

/// A laid out pie.
///
/// Mirrors `PieLayout` in `src/lib/ink/charts/chart-polar.ts`.
final class PieLayout extends ChartLayoutBase {
  /// A layout.
  const PieLayout({
    required super.w,
    required super.h,
    required super.bucket,
    required super.labels,
    required super.targets,
    required super.cursorAt,
    required this.cx,
    required this.cy,
    required this.radius,
    required this.r0,
    required this.sectors,
    required this.sliceOf,
    required this.total,
  });

  /// Centre x.
  final double cx;

  /// Centre y.
  final double cy;

  /// Outer radius (`R`).
  final double radius;

  /// Hole radius.
  final double r0;

  /// The drawn sectors.
  final List<PieSector> sectors;

  /// The slice index of each sector.
  final List<int> sliceOf;

  /// The sum of positive values.
  final double total;

  @override
  Map<String, Object?> toJson() => {
    ...super.toJson(),
    'cx': cx,
    'cy': cy,
    'R': radius,
    'r0': r0,
    'sectors': [for (final s in sectors) s.toJson()],
    'sliceOf': sliceOf,
    'total': total,
  };
}

double _positive(double v) => switch (isNum(v) && v > 0) {
  true => v,
  false => 0,
};

/// Lays out a pie in [box].
///
/// Mirrors `layoutPie` in `src/lib/ink/charts/chart-polar.ts`.
PieLayout layoutPie(PieSpec spec, Box box, [bool calm = false]) {
  final w = box.w, h = box.h;
  final bucket = bucketOf(w);
  final m = polarMetrics(bucket, calm);
  final labels = <ChartLabel>[];
  final total = spec.slices.fold(0.0, (n, s) => n + _positive(s.value));
  final wantsLabels =
      spec.labels && spec.state == ChartState.ready && total > 0;
  final pad = switch (wantsLabels) {
    true => m.tick + 20,
    false => 8.0,
  };
  final radius = math.max(12.0, math.min(w, h) / 2 - pad);
  final cx = w / 2;
  final cy = h / 2;
  final r0 = radius * clampN(spec.inner, 0, 0.9);
  final sectors = <PieSector>[];
  final sliceOf = <int>[];
  var a = deg(spec.start);
  for (final (i, s) in spec.slices.indexed) {
    final v = _positive(s.value);
    if (v == 0 || total == 0) continue;
    final f = v / total;
    sectors.add(PieSector(i, a, a + f * tau, f));
    sliceOf.add(i);
    a += f * tau;
  }
  if (wantsLabels) {
    final pct = shares([for (final s in spec.slices) s.value]);
    for (final sc in sectors) {
      if (sc.fraction < 0.045) continue;
      final mid = (sc.a0 + sc.a1) / 2;
      final p = polar(cx, cy, radius + 12, mid);
      final s = JsMath.sin(mid);
      final c = JsMath.cos(mid);
      labels.add(
        ChartLabel(
          id: 'l-${sc.index}',
          text: spec.slices[sc.index].label ?? pct[sc.index],
          x: p.x,
          y: p.y,
          anchor: switch (s) {
            > 0.25 => LabelAnchor.start,
            < -0.25 => LabelAnchor.end,
            _ => LabelAnchor.middle,
          },
          valign: switch (c) {
            > 0.3 => LabelValign.bottom,
            < -0.3 => LabelValign.top,
            _ => LabelValign.middle,
          },
          role: LabelRole.value,
          size: m.value,
          tone: LabelTone.ink,
        ),
      );
    }
  }
  final mids = [
    for (final s in sectors)
      polar(cx, cy, (radius + r0) / 2, (s.a0 + s.a1) / 2),
  ];
  final targets = ChartTargets(
    n: sectors.length,
    mode: TargetMode.sector,
    cx: [for (final p in mids) p.x],
    cy: [for (final p in mids) p.y],
    nav: TargetNav.linear,
    sector: SectorTargets(
      cx: cx,
      cy: cy,
      r0: [for (final _ in sectors) r0],
      r1: [for (final _ in sectors) radius + 4],
      a0: [for (final s in sectors) s.a0],
      a1: [for (final s in sectors) s.a1],
    ),
  );
  List<CursorSpec> cursorAt(int i, [int? series]) {
    if (i < 0 || i >= sectors.length) return const [];
    final s = sectors[i];
    final b = boundsAround(
      sectorPoly(cx, cy, r0, radius + 3, s.a0, s.a1, 6),
      8,
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
        r0: r0,
        r1: radius + 3,
        a0: s.a0,
        a1: s.a1,
      ),
    ];
  }

  if (spec.state != ChartState.ready || total == 0) {
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
  return PieLayout(
    w: w,
    h: h,
    bucket: bucket,
    labels: labels,
    targets: targets,
    cursorAt: cursorAt,
    cx: cx,
    cy: cy,
    radius: radius,
    r0: r0,
    sectors: sectors,
    sliceOf: sliceOf,
    total: total,
  );
}
