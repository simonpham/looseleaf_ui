import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/chart/chart.dart';

/// What every chart shares: its name and summary, loading and empty
/// states, the reveal, the seed, the point callbacks, and the props it
/// takes when used on its own (without a [ChartContainer] it wraps itself
/// in one, with a tooltip and, when it has several series, a legend).
///
/// Mirrors the `Standalone` props and `useSelfContained` of upstream
/// `src/components/ui/chart.tsx`.
abstract class ChartWidget extends StatelessWidget {
  const ChartWidget({
    super.key,
    this.config,
    this.tooltip = true,
    this.legend,
    this.label,
    this.description,
    this.loading = false,
    this.emptyText,
    this.animate = true,
    this.seed,
    this.onActiveChange,
    this.onSelect,
  });

  /// The config when used on its own; inside a container, the container's.
  final ChartConfig? config;

  /// On its own: whether it shows a tooltip.
  final bool tooltip;

  /// On its own: where the legend goes; by default below when there are
  /// several series.
  final ChartLegendPlacement? legend;

  /// The accessible name and the start of the spoken summary.
  final String? label;

  /// One more sentence for the summary.
  final String? description;

  /// Ghost drawing, busy, not interactive.
  final bool loading;

  /// Text shown when there is nothing to draw.
  final String? emptyText;

  /// Wipes the drawing on once when it first appears.
  final bool animate;

  /// Pins the hand.
  final String? seed;

  /// The data point under the pointer or the keys changed.
  final ValueChanged<ChartPoint?>? onActiveChange;

  /// A tap, Enter or Space on a data point.
  final ValueChanged<ChartPoint>? onSelect;

  /// The config a chart on its own builds from its data.
  ChartConfig autoConfig();

  /// Whether a chart on its own shows a legend by default.
  bool get legendByDefault;

  /// The frame's width over height when on its own.
  double get standaloneAspectRatio => 16 / 9;

  /// The widest the frame gets when on its own.
  double get standaloneMaxWidth => double.infinity;

  /// The series this chart registers with the legend.
  List<ChartLegendEntry> legendEntries(
    ChartConfig config,
    ChartPatterns patterns,
  );

  /// The drawing, inside [scope].
  Widget buildChart(BuildContext context, ChartScope scope);

  /// The container a chart on its own wraps itself in.
  Widget buildStandalone(BuildContext context) {
    final placement =
        legend ??
        switch (legendByDefault) {
          true => ChartLegendPlacement.bottom,
          false => ChartLegendPlacement.none,
        };
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: standaloneMaxWidth),
      child: ChartContainer(
        config: config ?? autoConfig(),
        aspectRatio: standaloneAspectRatio,
        children: [
          if (placement == ChartLegendPlacement.top)
            const ChartLegend(verticalAlign: ChartLegendAlign.top),
          this,
          if (tooltip) const ChartTooltip(),
          if (placement == ChartLegendPlacement.bottom) const ChartLegend(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = ChartScope.maybeOf(context);
    if (scope == null) return buildStandalone(context);
    return buildChart(context, scope);
  }
}
