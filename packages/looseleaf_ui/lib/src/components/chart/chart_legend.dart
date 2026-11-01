import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/chart/chart.dart';

/// The key of the chart in its [ChartContainer]: put it before the chart
/// with [ChartLegendAlign.top] or after it. It shows the series the chart
/// registered, with the swatches the drawing uses.
///
/// Mirrors `ChartLegend` in upstream `src/components/ui/chart.tsx`.
class ChartLegend extends StatelessWidget {
  const ChartLegend({
    super.key,
    this.content,
    this.hideIcon = false,
    this.verticalAlign = ChartLegendAlign.bottom,
    this.keys,
    this.toggle = true,
  });

  /// Custom legend markup instead of a [ChartLegendContent].
  final Widget? content;

  /// Leaves out the config icon or swatch.
  final bool hideIcon;

  /// Which side of the chart it sits on.
  final ChartLegendAlign verticalAlign;

  /// Only these entries, in this order.
  final List<String>? keys;

  /// Entries switch series off and on.
  final bool toggle;

  @override
  Widget build(BuildContext context) =>
      content ??
      ChartLegendContent(
        hideIcon: hideIcon,
        verticalAlign: verticalAlign,
        keys: keys,
        toggle: toggle,
      );
}
