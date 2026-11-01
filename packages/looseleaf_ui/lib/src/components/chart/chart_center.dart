import 'package:flutter/widgets.dart';

/// The slice under the cursor, for a center label.
typedef ChartCenterSlice = ({String name, double value, double percent});

/// What a center label can show: the [total] and the [active] slice.
typedef ChartCenterInfo = ({double total, ChartCenterSlice? active});

/// Builds the words in the hole of a donut or radial chart, usually a
/// `ChartCenterLabel`.
typedef ChartCenterBuilder = Widget Function(ChartCenterInfo info);

/// Centres [child] on the point ([x], [y]) of a chart layout.
///
/// Mirrors `AtPoint` in upstream `src/components/ui/chart.tsx`.
class ChartAtPoint extends StatelessWidget {
  const ChartAtPoint({
    super.key,
    required this.x,
    required this.y,
    required this.child,
  });

  /// The point, in the chart's pixels.
  final double x;

  /// The point, in the chart's pixels.
  final double y;

  /// What sits there.
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      Positioned(
        left: x,
        top: y,
        child: FractionalTranslation(
          translation: const Offset(-0.5, -0.5),
          child: child,
        ),
      ),
    ],
  );
}
