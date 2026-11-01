import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/chart/chart.dart';

/// The active point handed to a tooltip body: what upstream clones into
/// the `content` element as `active`, `payload` and `label`.
class ChartTooltipPayload extends InheritedWidget {
  const ChartTooltipPayload({
    super.key,
    required this.label,
    required this.payload,
    required super.child,
  });

  /// The point's label (a category, a slice name, a day).
  final String label;

  /// One row per series at the point.
  final List<ChartTooltipItem> payload;

  /// The nearest payload, or null outside a chart tooltip.
  static ChartTooltipPayload? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ChartTooltipPayload>();

  @override
  bool updateShouldNotify(ChartTooltipPayload oldWidget) =>
      oldWidget.label != label || !identical(oldWidget.payload, payload);
}
