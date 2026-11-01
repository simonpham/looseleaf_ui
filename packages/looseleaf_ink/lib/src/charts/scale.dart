import 'dart:math' as math;

import 'package:looseleaf_ink/src/charts/js_log10.dart';
import 'package:looseleaf_ink/src/core/core.dart';

/// A chart width class: small, medium or large.
///
/// Mirrors `Bucket` in `src/lib/ink/charts/chart-scale.ts`.
enum Bucket { sm, md, lg }

/// The bucket of a chart [w] px wide.
///
/// Mirrors `bucketOf` in `src/lib/ink/charts/chart-scale.ts`.
Bucket bucketOf(double w) {
  if (w < 280) return Bucket.sm;
  if (w < 560) return Bucket.md;
  return Bucket.lg;
}

/// [v] limited to `[a, b]`; NaN passes through.
///
/// Mirrors `clampN` in `src/lib/ink/charts/chart-scale.ts`.
double clampN(double v, double a, double b) {
  if (v < a) return a;
  if (v > b) return b;
  return v;
}

/// [v] rounded to [d] decimals, with `-0` turned into `0`.
///
/// Mirrors `round` in `src/lib/ink/charts/chart-scale.ts`.
double roundTo(double v, [int d = 2]) {
  final k = jsPow10(d.toDouble());
  final r = JsMath.round(v * k) / k;
  if (r == 0) return 0;
  return r;
}

/// Whether [v] is a finite number.
///
/// Mirrors `isNum` in `src/lib/ink/charts/chart-scale.ts`.
bool isNum(Object? v) => v is num && v.isFinite;

double _niceNum(double range, bool roundIt) {
  final exp = jsLog10(range).floorToDouble();
  final f = range / jsPow10(exp);
  final double nf;
  if (roundIt) {
    nf = switch (f) {
      < 1.5 => 1,
      < 3 => 2,
      < 7 => 5,
      _ => 10,
    };
    return nf * jsPow10(exp);
  }
  nf = switch (f) {
    <= 1 => 1,
    <= 2 => 2,
    <= 5 => 5,
    _ => 10,
  };
  return nf * jsPow10(exp);
}

/// A rounded axis range: its ends, step and ticks.
///
/// Mirrors `NiceScale` in `src/lib/ink/charts/chart-scale.ts`.
final class NiceScale {
  /// A scale.
  const NiceScale(this.min, this.max, this.step, this.ticks);

  /// The low end.
  final double min;

  /// The high end.
  final double max;

  /// The tick step.
  final double step;

  /// The ticks, low to high.
  final List<double> ticks;
}

/// A nice scale over `[min, max]` with about [count] ticks.
///
/// Mirrors `niceScale` in `src/lib/ink/charts/chart-scale.ts`.
NiceScale niceScale(double min, double max, [int count = 5]) {
  var lo = math.min(min, max);
  var hi = math.max(min, max);
  if (!lo.isFinite || !hi.isFinite) {
    lo = 0;
    hi = 1;
  }
  if (lo == hi) {
    final pad = switch (lo.abs() > 0) {
      true => lo.abs() * 0.5,
      false => 1.0,
    };
    lo -= switch (lo == 0) {
      true => 0,
      false => pad * 0.5,
    };
    hi += pad;
    if (lo > 0 && min >= 0) lo = 0;
  }
  final step = _niceNum(
    _niceNum(hi - lo, false) / math.max(1, count - 1),
    true,
  );
  final nmin = (lo / step + 1e-9).floorToDouble() * step;
  final nmax = (hi / step - 1e-9).ceilToDouble() * step;
  final ticks = <double>[];
  var i = 0;
  for (var v = nmin; v <= nmax + step * 0.5 && i < 60; v += step, i++) {
    ticks.add(roundTo(v, 10));
  }
  return NiceScale(roundTo(nmin, 10), roundTo(nmax, 10), step, ticks);
}

/// Nice ticks inside `[min, max]`.
///
/// Mirrors `ticksIn` in `src/lib/ink/charts/chart-scale.ts`.
List<double> ticksIn(double min, double max, [int count = 5]) {
  if (!(max > min)) return [min];
  final step = _niceNum((max - min) / math.max(1, count - 1), true);
  final out = <double>[];
  var i = 0;
  for (
    var v = (min / step - 1e-9).ceilToDouble() * step;
    v <= max + step * 1e-6 && i < 60;
    v += step, i++
  ) {
    out.add(roundTo(v, 10));
  }
  return out;
}

String _key(List<double> t) => t.map(JsMath.numberToString).join(',');

/// Sparser tick sets (4, 3, 2 ticks) differing from [dense].
///
/// Mirrors `coarserTicks` in `src/lib/ink/charts/chart-scale.ts`.
List<List<double>> coarserTicks(double min, double max, List<double> dense) {
  final seen = <String>{_key(dense)};
  final out = <List<double>>[];
  for (final count in const [4, 3, 2]) {
    final t = ticksIn(min, max, count);
    final key = _key(t);
    if (t.length < 2 || seen.contains(key)) continue;
    seen.add(key);
    out.add(t);
  }
  return out;
}

/// Percent shares of [values] (largest remainder, summing to 100%).
///
/// Mirrors `shares` in `src/lib/ink/charts/chart-scale.ts`.
List<String> shares(List<double> values, [int decimals = 0]) {
  final k = jsPow10(decimals.toDouble());
  final pos = [
    for (final v in values)
      switch (isNum(v) && v > 0) {
        true => v,
        false => 0.0,
      },
  ];
  final total = pos.fold(0.0, (n, v) => n + v);
  if (total == 0 || total.isNaN) return [for (final _ in values) '0%'];
  final raw = [for (final v in pos) (v / total) * 100 * k];
  final floor = [for (final r in raw) r.floorToDouble()];
  var left = JsMath.round(100 * k) - floor.fold(0.0, (n, v) => n + v);
  final order = [for (var i = 0; i < raw.length; i++) (raw[i] - floor[i], i)]
    ..sort((a, b) {
      final byFrac = b.$1 - a.$1;
      if (byFrac > 0) return 1;
      if (byFrac < 0) return -1;
      return a.$2 - b.$2;
    });
  for (final (_, i) in order) {
    if (left <= 0) break;
    if (pos[i] > 0) {
      floor[i]++;
      left--;
    }
  }
  return [
    for (final f in floor)
      '${JsMath.numberToString(roundTo(f / k, decimals))}%',
  ];
}

/// The outer ring value of a radar whose data tops out at [top]: a nice
/// per-level step times [levels].
///
/// Mirrors `radarRim` in `src/lib/ink/charts/chart-scale.ts`.
double radarRim(double top, [double levels = 4]) {
  final lv = math.max(1.0, JsMath.or(JsMath.round(levels), 1));
  if (!isNum(top) || top <= 0) return lv;
  final per = top / lv;
  final exp = jsLog10(per).floorToDouble();
  final f = per / jsPow10(exp);
  const steps = [1, 1.5, 2, 2.5, 3, 4, 5, 6, 7.5, 10];
  final nice = steps.firstWhere((s) => s >= f - 1e-9, orElse: () => 10);
  return roundTo(nice * jsPow10(exp) * lv, 6);
}
