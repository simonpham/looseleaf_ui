import 'package:looseleaf_ink/src/charts/scale.dart';
import 'package:looseleaf_ink/src/charts/xy_spec.dart';

/// Per series and category, the `(low, high)` span a bar or area covers,
/// stacked or from zero; null for a gap.
///
/// Mirrors `stackRanges` in `src/lib/ink/charts/chart-xy.ts`.
List<List<(double, double)?>> stackRanges(
  List<XYSeries> series,
  bool stacked,
  int n,
) {
  final out = [
    for (final _ in series) List<(double, double)?>.filled(n, null),
  ];
  double? at(XYSeries s, int i) => s.values.elementAtOrNull(i);
  if (!stacked) {
    for (final (k, s) in series.indexed) {
      for (var i = 0; i < n; i++) {
        final v = at(s, i);
        if (v == null || !isNum(v)) continue;
        out[k][i] = switch (v >= 0) {
          true => (0, v),
          false => (v, 0),
        };
      }
    }
    return out;
  }
  for (var i = 0; i < n; i++) {
    var pos = 0.0;
    var neg = 0.0;
    for (final (k, s) in series.indexed) {
      final v = at(s, i);
      if (v == null || !isNum(v)) continue;
      if (v >= 0) {
        out[k][i] = (pos, pos + v);
        pos += v;
        continue;
      }
      out[k][i] = (neg + v, neg);
      neg += v;
    }
  }
  return out;
}
