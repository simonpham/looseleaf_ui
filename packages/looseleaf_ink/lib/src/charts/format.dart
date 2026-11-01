import 'package:looseleaf_ink/src/charts/scale.dart';
import 'package:looseleaf_ink/src/core/core.dart';

/// Formats a number for a chart label.
typedef ValueFormat = String Function(double v);

final RegExp _thousands = RegExp(r'\B(?=(\d{3})+(?!\d))');

/// [v] with thousands separators and at most [maxDecimals] decimals.
///
/// Mirrors `formatNumber` in `src/lib/ink/charts/chart-scale.ts`.
String formatNumber(double v, [int maxDecimals = 2]) {
  if (!v.isFinite) return '';
  final s = JsMath.numberToString(roundTo(v.abs(), maxDecimals));
  final dot = s.indexOf('.');
  final whole = switch (dot) {
    -1 => s,
    _ => s.substring(0, dot),
  };
  final dec = switch (dot) {
    -1 => '',
    _ => '.${s.substring(dot + 1)}',
  };
  final sign = switch (v < 0) {
    true => '-',
    false => '',
  };
  return '$sign${whole.replaceAll(_thousands, ',')}$dec';
}

const List<(double, String)> _suffix = [
  (1e12, 'T'),
  (1e9, 'B'),
  (1e6, 'M'),
  (1e3, 'k'),
];

/// [v] in compact form: `1.2k`, `34M`, `0.25`.
///
/// Mirrors `formatCompact` in `src/lib/ink/charts/chart-scale.ts`.
String formatCompact(double v) {
  if (!v.isFinite) return '';
  final a = v.abs();
  final sign = switch (v < 0) {
    true => '-',
    false => '',
  };
  for (final (k, s) in _suffix) {
    if (a >= k) {
      final digits = switch (a / k >= 100) {
        true => 0,
        false => 1,
      };
      return '$sign${JsMath.numberToString(roundTo(a / k, digits))}$s';
    }
  }
  final digits = switch (a) {
    < 1 => 2,
    < 10 => 1,
    _ => 0,
  };
  return '$sign${JsMath.numberToString(roundTo(a, digits))}';
}

/// [fraction] as a percentage with [decimals] decimals.
///
/// Mirrors `formatPercent` in `src/lib/ink/charts/chart-scale.ts`.
String formatPercent(double fraction, [int decimals = 0]) =>
    '${JsMath.numberToString(roundTo(fraction * 100, decimals))}%';
