import 'package:flutter/widgets.dart';

/// Switches a [ChartContainer]'s tooltip on. It draws nothing itself: the
/// chart puts the tooltip inside its own box, at the point, and keeps it
/// in view; hover, touch and the arrow keys all move it.
///
/// Mirrors `ChartTooltip` in upstream `src/components/ui/chart.tsx`.
class ChartTooltip extends StatelessWidget {
  const ChartTooltip({
    super.key,
    this.content,
    this.cursor = true,
    this.defaultIndex,
  });

  /// The tooltip body; a `ChartTooltipContent` by default. It reads the
  /// active point through `ChartTooltipPayload.of`.
  final Widget? content;

  /// Whether the drawing highlights the active column, point or slice.
  final bool cursor;

  /// The data point shown when nothing is hovered or focused.
  final int? defaultIndex;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
