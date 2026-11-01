import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/bubble/bubble_shape.dart';
import 'package:looseleaf_ui/src/components/message/message.dart';

/// What a [Bubble] tells its [BubbleContent]: the variant, side, shape, pen
/// and whether the tail shows.
///
/// Mirrors `BubbleContext` in upstream `src/components/ui/bubble.tsx`.
class BubbleScope extends InheritedWidget {
  const BubbleScope({
    super.key,
    required this.variant,
    required this.align,
    required this.shape,
    required this.pen,
    required this.tail,
    required super.child,
  });

  final BubbleVariant variant;
  final ChatAlign align;
  final BubbleShape shape;
  final BubblePen pen;

  /// Whether the tail flick is drawn.
  final bool tail;

  /// The enclosing bubble's scope, or null outside one.
  static BubbleScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BubbleScope>();

  @override
  bool updateShouldNotify(BubbleScope oldWidget) =>
      oldWidget.variant != variant ||
      oldWidget.align != align ||
      oldWidget.shape != shape ||
      oldWidget.pen != pen ||
      oldWidget.tail != tail;
}

/// Marks a [Bubble] that is not the last of its [BubbleGroup], so it hides
/// its tail.
class BubbleGroupTailScope extends InheritedWidget {
  const BubbleGroupTailScope({
    super.key,
    required this.hideTail,
    required super.child,
  });

  /// Whether the bubble below loses its tail.
  final bool hideTail;

  /// Whether the enclosing group hides this bubble's tail.
  static bool hidesTail(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<BubbleGroupTailScope>()
          ?.hideTail ??
      false;

  @override
  bool updateShouldNotify(BubbleGroupTailScope oldWidget) =>
      oldWidget.hideTail != hideTail;
}
