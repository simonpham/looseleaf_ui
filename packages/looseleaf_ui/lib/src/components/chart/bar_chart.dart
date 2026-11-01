import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/chart/chart.dart';

/// Bars: single, grouped, stacked or sideways ([horizontal]), with negative
/// values hanging below the line. Bars are colored in with a marker inside
/// a steady felt outline; numbers sit on top when they fit.
///
/// ```dart
/// BarChart(
///   data: const [{'day': 'Mon', 'sales': 12}, {'day': 'Tue', 'sales': 19}],
///   xKey: 'day',
///   annotations: const [ChartAnnotation(at: 'max', text: 'best day!')],
/// )
/// ```
///
/// Mirrors `BarChart` in upstream `src/components/ui/chart.tsx`.
class BarChart extends XYChart {
  const BarChart({
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
    this.horizontal = false,
  });

  /// Bars run sideways, categories down the left (upstream `horizontal`,
  /// or recharts' `layout="vertical"`).
  @override
  final bool horizontal;

  @override
  XYKind get kind => XYKind.bar;
}
