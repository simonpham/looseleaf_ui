import 'package:looseleaf_ui/src/components/chart/chart.dart';

/// A [PieChart] with a hole ([innerRadius] 0.58) for a number in the
/// middle: give it a [centerLabel].
///
/// Mirrors `DonutChart` in upstream `src/components/ui/chart.tsx`.
class DonutChart extends PieChart {
  const DonutChart({
    super.key,
    required super.data,
    super.nameKey,
    super.valueKey,
    super.innerRadius = 0.58,
    super.startAngle,
    super.showLabels,
    super.valueFormatter,
    super.centerLabel,
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
}
