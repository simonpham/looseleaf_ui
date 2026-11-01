import 'package:looseleaf_ink/looseleaf_ink.dart';

/// One series (or slice) a chart registers with its legend: its key, slot
/// and the look the drawing gives it.
///
/// Mirrors `LegendEntry` in upstream `src/components/ui/chart.tsx`.
class ChartLegendEntry {
  const ChartLegendEntry({
    required this.key,
    required this.slot,
    this.pattern = FillPattern.solid,
    this.marker = MarkerShape.circle,
    this.dash = Dash.solid,
    this.kind,
  });

  /// The data key.
  final String key;

  /// The palette slot.
  final int slot;

  /// The fill pattern.
  final FillPattern pattern;

  /// The point marker.
  final MarkerShape marker;

  /// The line dash.
  final Dash dash;

  /// How the series is drawn; null for a slice of a pie, a ring or a row.
  final XYKind? kind;
}
