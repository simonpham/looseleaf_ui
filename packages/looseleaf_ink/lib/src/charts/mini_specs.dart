import 'package:looseleaf_ink/src/charts/chart_looks.dart';
import 'package:looseleaf_ink/src/charts/chart_spec.dart';
import 'package:looseleaf_ink/src/charts/heat_layout.dart';
import 'package:looseleaf_ink/src/charts/spark_layout.dart';
import 'package:looseleaf_ink/src/charts/tally_layout.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// How a sparkline is drawn.
enum SparkVariant { line, area, bar }

/// A sparkline.
///
/// Mirrors `SparkSpec` in `src/lib/ink/charts/chart-types.ts`.
final class SparkSpec extends ChartSpec {
  /// A sparkline.
  const SparkSpec({
    required this.variant,
    required this.values,
    required this.min,
    required this.max,
    required this.slot,
    required this.ends,
    required this.extremes,
    required this.state,
  });

  /// How it is drawn.
  final SparkVariant variant;

  /// The values; null for a gap.
  final List<double?> values;

  /// The low end.
  final double min;

  /// The high end.
  final double max;

  /// The colour slot.
  final int slot;

  /// Whether to dot the last point.
  final bool ends;

  /// Whether to mark the low and high points.
  final bool extremes;

  /// Data state.
  final ChartState state;

  @override
  SparkLayout layout(Box box, [bool calm = false]) => layoutSpark(this, box);

  /// The upstream JSON shape (unset optional fields left out).
  Map<String, Object?> toJson() => {
    'type': 'spark',
    'variant': variant.name,
    'values': values,
    'min': min,
    'max': max,
    'slot': slot,
    'ends': ends,
    'extremes': extremes,
    'state': state.name,
  };
}

/// One tally row.
///
/// Mirrors `TallyRow` in `src/lib/ink/charts/chart-types.ts`.
final class TallyRow {
  /// A row.
  const TallyRow({
    required this.key,
    required this.name,
    required this.slot,
    required this.count,
  });

  /// The data key.
  final String key;

  /// The display name.
  final String name;

  /// The colour slot.
  final int slot;

  /// The count.
  final double count;

  /// The upstream JSON shape (unset optional fields left out).
  Map<String, Object?> toJson() => {
    'key': key,
    'name': name,
    'slot': slot,
    'count': count,
  };
}

/// A tally chart: rows of five-bar gates.
///
/// Mirrors `TallySpec` in `src/lib/ink/charts/chart-types.ts`.
final class TallySpec extends ChartSpec {
  /// A tally.
  const TallySpec({
    required this.rows,
    required this.unit,
    required this.totals,
    required this.state,
    this.stateText,
  });

  /// The rows.
  final List<TallyRow> rows;

  /// What one mark counts; 0 picks one that fits.
  final double unit;

  /// The total label per row.
  final List<String> totals;

  /// Data state.
  final ChartState state;

  /// Text for an empty or loading chart.
  final String? stateText;

  @override
  TallyLayout layout(Box box, [bool calm = false]) =>
      layoutTally(this, box, calm);

  /// The upstream JSON shape (unset optional fields left out).
  Map<String, Object?> toJson() => {
    'type': 'tally',
    'rows': [for (final r in rows) r.toJson()],
    'unit': unit,
    'totals': totals,
    'state': state.name,
    'stateText': ?stateText,
  };
}

/// How a heatmap is laid out.
enum HeatVariant { calendar, grid }

/// A row or column label at index [i].
final class HeatLabel {
  /// A label.
  const HeatLabel(this.i, this.text);

  /// Row or column index.
  final int i;

  /// The text.
  final String text;

  /// The upstream JSON shape.
  Map<String, Object?> toJson() => {'i': i, 'text': text};
}

/// A heatmap: a grid of levelled cells.
///
/// Mirrors `HeatSpec` in `src/lib/ink/charts/chart-types.ts`.
final class HeatSpec extends ChartSpec {
  /// A heatmap.
  const HeatSpec({
    required this.cols,
    required this.rows,
    required this.levels,
    required this.levelCount,
    required this.colLabels,
    required this.rowLabels,
    required this.slot,
    required this.variant,
    required this.patterns,
    required this.state,
    this.legend,
    this.stateText,
  });

  /// Columns.
  final int cols;

  /// Rows.
  final int rows;

  /// The level of each cell, row by row; -1 for no cell.
  final List<int> levels;

  /// How many levels.
  final int levelCount;

  /// Column labels.
  final List<HeatLabel> colLabels;

  /// Row labels.
  final List<HeatLabel> rowLabels;

  /// The colour slot.
  final int slot;

  /// Calendar or grid.
  final HeatVariant variant;

  /// The legend's end labels, if shown.
  final ({String less, String more})? legend;

  /// Whether fills use patterns.
  final bool patterns;

  /// Data state.
  final ChartState state;

  /// Text for an empty or loading chart.
  final String? stateText;

  @override
  HeatLayout layout(Box box, [bool calm = false]) =>
      layoutHeat(this, box, calm);

  /// The upstream JSON shape (unset optional fields left out).
  Map<String, Object?> toJson() => {
    'type': 'heat',
    'cols': cols,
    'rows': rows,
    'levels': levels,
    'levelCount': levelCount,
    'colLabels': [for (final l in colLabels) l.toJson()],
    'rowLabels': [for (final l in rowLabels) l.toJson()],
    'slot': slot,
    'variant': variant.name,
    'legend': switch (legend) {
      final l? => {'less': l.less, 'more': l.more},
      null => null,
    },
    'patterns': patterns,
    'state': state.name,
    'stateText': ?stateText,
  };
}
