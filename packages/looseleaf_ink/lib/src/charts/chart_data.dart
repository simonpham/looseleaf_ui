import 'dart:math' as math;

import 'package:looseleaf_ink/src/charts/format.dart';
import 'package:looseleaf_ink/src/charts/scale.dart';
import 'package:looseleaf_ink/src/charts/xy_spec.dart';
import 'package:looseleaf_ink/src/charts/xy_stack.dart';

/// A pinned axis domain: each end a number, or null for auto.
///
/// Mirrors `[DomainEnd, DomainEnd]` in `src/lib/ink/charts/chart-data.ts`.
typedef AxisDomain = (double?, double?);

/// A resolved axis: its ends, ticks and sparser tick sets.
final class AxisScale {
  /// An axis.
  const AxisScale(this.min, this.max, this.ticks, this.ticksAlt);

  /// The low end.
  final double min;

  /// The high end.
  final double max;

  /// Ticks.
  final List<AxisTick> ticks;

  /// Sparser tick sets.
  final List<List<AxisTick>> ticksAlt;
}

AxisScale _axis(
  double lo,
  double hi,
  AxisDomain? domain,
  int ticks,
  ValueFormat fmt,
) {
  final pinLo = domain?.$1;
  final pinHi = domain?.$2;
  final sc = niceScale(pinLo ?? lo, pinHi ?? hi, ticks);
  final min = pinLo ?? sc.min;
  final max = pinHi ?? sc.max;
  final values = switch (pinLo != null || pinHi != null) {
    true => ticksIn(min, max, ticks),
    false => sc.ticks,
  };
  List<AxisTick> label(List<double> vs) => [
    for (final v in vs) AxisTick(v, fmt(v)),
  ];
  return AxisScale(min, max, label(values), [
    for (final t in coarserTicks(min, max, values)) label(t),
  ]);
}

/// The value axis of [series] over [n] categories: zero-based for bars and
/// areas (or when [zero]), padded otherwise, pinned by [domain], with
/// [include] values kept in view.
///
/// Mirrors `yScaleFor` in `src/lib/ink/charts/chart-data.ts`.
AxisScale yScaleFor(
  List<XYSeries> series, {
  required int n,
  required bool stacked,
  required bool zero,
  AxisDomain? domain,
  int? ticks,
  ValueFormat? format,
  List<double> include = const [],
}) {
  var lo = double.infinity;
  var hi = double.negativeInfinity;
  void take(double v) {
    if (v < lo) lo = v;
    if (v > hi) hi = v;
  }

  for (final k in const [XYKind.bar, XYKind.area]) {
    final group = [
      for (final s in series)
        if (s.kind == k) s,
    ];
    if (group.isEmpty) continue;
    for (final row in stackRanges(group, stacked, n)) {
      for (final r in row) {
        if (r case (final a, final b)) {
          take(a);
          take(b);
        }
      }
    }
    take(0);
  }
  for (final s in series) {
    if (s.kind != XYKind.line && s.kind != XYKind.scatter) continue;
    for (final v in s.values) {
      if (v != null && isNum(v)) take(v);
    }
  }
  for (final v in include) {
    if (isNum(v)) take(v);
  }
  if (!lo.isFinite || !hi.isFinite) {
    lo = 0;
    hi = 1;
  }
  if (zero) {
    lo = math.min(lo, 0);
    hi = math.max(hi, 0);
  }
  if (!zero && hi > lo) {
    final pad = (hi - lo) * 0.06;
    lo -= pad;
    hi += pad;
  }
  return _axis(lo, hi, domain, ticks ?? 5, format ?? formatCompact);
}

/// The scatter x axis over [values].
///
/// Mirrors `xScaleFor` in `src/lib/ink/charts/chart-data.ts`.
AxisScale xScaleFor(
  List<double> values, {
  AxisDomain? domain,
  int? ticks,
  ValueFormat? format,
  List<double> include = const [],
}) {
  final all = [...values.where(isNum), ...include];
  final lo = switch (all.isEmpty) {
    true => 0.0,
    false => all.reduce(math.min),
  };
  final hi = switch (all.isEmpty) {
    true => 1.0,
    false => all.reduce(math.max),
  };
  return _axis(lo, hi, domain, ticks ?? 6, format ?? formatCompact);
}
