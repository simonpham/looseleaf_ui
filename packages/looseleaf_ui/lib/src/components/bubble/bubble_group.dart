import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/bubble/bubble_metrics.dart';
import 'package:looseleaf_ui/src/components/bubble/bubble_scope.dart';

/// A run of [Bubble]s from one sender, 8 px apart. Only the last bubble
/// keeps its tail.
///
/// ```dart
/// BubbleGroup(children: [
///   Bubble(variant: .muted, children: [BubbleContent(child: Text('Hi'))]),
///   Bubble(variant: .muted, children: [BubbleContent(child: Text('there'))]),
/// ])
/// ```
///
/// Mirrors `BubbleGroup` in upstream `src/components/ui/bubble.tsx`.
class BubbleGroup extends StatelessWidget {
  const BubbleGroup({
    super.key,
    required this.children,
    this.gap = BubbleMetrics.groupGap,
  });

  /// Usually [Bubble]s.
  final List<Widget> children;

  /// The space between bubbles.
  final double gap;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: gap,
    children: [
      for (final (index, child) in children.indexed)
        BubbleGroupTailScope(
          hideTail: index < children.length - 1,
          child: child,
        ),
    ],
  );
}
