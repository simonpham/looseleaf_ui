import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/chart/chart.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The tooltip inside a chart's box: centred over [anchor], above it when
/// there is room and below it otherwise, kept 4 px inside the box.
///
/// Mirrors `TooltipLayer` and `TooltipPositioner` in upstream
/// `src/components/ui/chart.tsx`.
class ChartTooltipLayer extends StatelessWidget {
  const ChartTooltipLayer({
    super.key,
    required this.anchor,
    required this.described,
    this.content,
  });

  /// The point, in the chart's pixels.
  final Offset anchor;

  /// What the tooltip shows.
  final ChartDescribed described;

  /// The body; a [ChartTooltipContent] by default.
  final Widget? content;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: CustomSingleChildLayout(
        delegate: _TooltipPlacement(anchor),
        child: ChartTooltipPayload(
          label: described.label,
          payload: described.payload,
          child: content ?? const ChartTooltipContent(),
        ),
      ),
    ),
  );
}

class _TooltipPlacement extends SingleChildLayoutDelegate {
  const _TooltipPlacement(this.anchor);

  final Offset anchor;

  static const double _inset = Spacing.d4;
  static const double _gapAbove = Spacing.d14;
  static const double _gapBelow = Spacing.d18;
  static const double _maxWidth = 352;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints(
        maxWidth: math.max(
          0,
          math.min(_maxWidth, constraints.maxWidth - 2 * _inset),
        ),
      );

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final left = math.max(
      _inset,
      math.min(
        size.width - childSize.width - _inset,
        anchor.dx - childSize.width / 2,
      ),
    );
    final above = anchor.dy - childSize.height - _gapAbove;
    final top = switch (above < Spacing.d2) {
      true => anchor.dy + _gapBelow,
      false => above,
    };
    return Offset(left, top);
  }

  @override
  bool shouldRelayout(_TooltipPlacement oldDelegate) =>
      oldDelegate.anchor != anchor;
}
