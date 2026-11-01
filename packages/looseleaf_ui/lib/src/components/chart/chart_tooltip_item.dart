import 'dart:ui';

import 'package:looseleaf_ink/looseleaf_ink.dart';

/// One row of a chart tooltip: a series at the active point.
///
/// Mirrors `ChartTooltipItem` in upstream `src/components/ui/chart.tsx`,
/// recharts-shaped so formatters read the same fields.
class ChartTooltipItem {
  const ChartTooltipItem({
    this.dataKey,
    this.name,
    this.value,
    this.color,
    this.payload,
    this.slot,
    this.pattern,
    this.marker,
    this.kind,
    this.unit,
  });

  /// The series key.
  final String? dataKey;

  /// The series name.
  final String? name;

  /// The value: a number, text, or null.
  final Object? value;

  /// An indicator color for rows without a [slot].
  final Color? color;

  /// The data row.
  final ChartRow? payload;

  /// The palette slot; the indicator is a [ChartSwatch] when set.
  final int? slot;

  /// The series' pattern.
  final FillPattern? pattern;

  /// The series' marker.
  final MarkerShape? marker;

  /// How the series is drawn.
  final XYKind? kind;

  /// Text after the value, like ` (24%)`.
  final String? unit;
}
