import 'package:looseleaf_ink/src/charts/curves.dart';
import 'package:looseleaf_ink/src/charts/js_log10.dart';
import 'package:looseleaf_ink/src/charts/xy_spec.dart';

/// The plot's top and right margins (`XY_MARGINS`).
const ({double top, double right}) xyMargins = (top: 12, right: 12);

/// Whether [spec] draws sideways bars (every series a bar).
///
/// Mirrors `isHorizontal` in `src/lib/ink/charts/chart-xy.ts`.
bool isHorizontal(XYSpec spec) =>
    spec.horizontal &&
    spec.series.isNotEmpty &&
    spec.series.every((s) => s.kind == XYKind.bar);

bool _isNiceStep(List<AxisTick> t) {
  if (t.length < 2) return true;
  final st = (t[1].v - t[0].v).abs();
  if (!(st > 0)) return true;
  final m = st / jsPow10(jsLog10(st).floorToDouble());
  return const [1, 2, 5, 10].any((x) => (m - x).abs() < 1e-6);
}

List<AxisTick>? _most(Iterable<List<AxisTick>> sets) {
  List<AxisTick>? best;
  for (final t in sets) {
    if (best == null || t.length > best.length) best = t;
  }
  return best;
}

/// At most [max] ticks from [dense], preferring a sparser set from [alt]
/// that still reaches both ends of [span].
///
/// Mirrors `pickTicks` in `src/lib/ink/charts/chart-xy.ts`.
List<AxisTick> pickTicks(
  List<AxisTick> dense,
  List<List<AxisTick>>? alt,
  int max,
  (double, double) span,
) {
  if (dense.length <= max) return [...dense];
  final eps = (span.$2 - span.$1).abs() * 1e-6;
  final fits = [
    for (final t in alt ?? const <List<AxisTick>>[])
      if (t.length >= 2 && t.length <= max) t,
  ];
  bool reaches(List<AxisTick> t) =>
      (t.first.v - span.$1).abs() <= eps && (t.last.v - span.$2).abs() <= eps;
  if (_most(fits.where(reaches)) case final ends?) return [...ends];
  final stride = [
    for (final i in strideIndices(dense.length, max)) dense[i],
  ];
  if (_isNiceStep(stride)) return stride;
  if (_most(fits) case final other?) return [...other];
  return stride;
}
