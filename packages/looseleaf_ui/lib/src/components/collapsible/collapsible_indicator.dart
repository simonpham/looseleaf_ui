import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/collapsible/collapsible_widget.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A chevron that turns over as the panel opens: [Collapsible]'s, or any
/// [open] state given.
///
/// Mirrors `CollapsibleIndicator` in upstream
/// `src/components/ui/collapsible.tsx`; [AccordionTrigger] draws the same.
class CollapsibleIndicator extends StatelessWidget {
  const CollapsibleIndicator({super.key, this.open, this.size = Spacing.d16});

  /// Whether it points up; null reads the nearest [Collapsible].
  final bool? open;

  final double size;

  @override
  Widget build(BuildContext context) {
    final turned = open ?? Collapsible.of(context).open;
    return TweenAnimationBuilder<double>(
      tween: Tween(
        end: switch (turned) {
          true => math.pi,
          false => 0,
        },
      ),
      duration: InkMotion.of(context, InkMotion.sheet),
      curve: InkMotion.settle,
      builder: (context, angle, child) =>
          Transform.rotate(angle: angle, child: child),
      child: InkIcon('chevron-down', size: size),
    );
  }
}
