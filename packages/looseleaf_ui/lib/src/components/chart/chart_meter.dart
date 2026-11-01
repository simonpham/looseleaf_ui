/// A gauge's reading for screen readers (upstream `role="meter"`).
class ChartMeter {
  const ChartMeter({
    required this.min,
    required this.max,
    required this.now,
    required this.text,
  });

  /// The lowest value.
  final double min;

  /// The highest value.
  final double max;

  /// The reading, clamped to [min] and [max].
  final double now;

  /// The reading as words.
  final String text;
}
