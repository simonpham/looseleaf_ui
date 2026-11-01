import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/chart/chart.dart';

/// Points on two number lines, one marker shape per series; a [sizeKey]
/// turns them into bubbles. The tooltip finds the nearest point.
///
/// Mirrors `ScatterChart` in upstream `src/components/ui/chart.tsx`.
class ScatterChart extends XYChart {
  const ScatterChart({
    super.key,
    required super.data,
    super.xKey,
    super.series,
    super.kinds,
    super.stacked,
    super.curve,
    super.yDomain,
    super.xDomain,
    super.zero,
    super.xFormatter,
    super.yFormatter,
    super.valueFormatter,
    super.dots,
    super.showValues,
    super.sizeKey,
    super.showGrid,
    super.showXAxis,
    super.showYAxis,
    super.annotations,
    super.references,
    super.highlights,
    super.xLabel,
    super.config,
    super.tooltip,
    super.legend,
    super.label,
    super.description,
    super.loading,
    super.emptyText,
    super.animate,
    super.seed,
    super.onActiveChange,
    super.onSelect,
  });

  @override
  XYKind get kind => XYKind.scatter;
}
