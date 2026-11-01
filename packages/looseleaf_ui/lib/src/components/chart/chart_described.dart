import 'package:looseleaf_ui/src/components/chart/chart.dart';

/// What a chart says about one data point: the tooltip [label] and rows,
/// and the line the live region announces.
///
/// Mirrors `Described` in upstream `src/components/ui/chart.tsx`.
class ChartDescribed {
  const ChartDescribed({
    required this.label,
    required this.payload,
    required this.announce,
  });

  /// The tooltip label.
  final String label;

  /// The tooltip rows.
  final List<ChartTooltipItem> payload;

  /// The live-region text.
  final String announce;
}
