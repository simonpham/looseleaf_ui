import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/bubble/bubble_metrics.dart';
import 'package:looseleaf_ui/src/components/bubble/bubble_reactions.dart';
import 'package:looseleaf_ui/src/components/bubble/bubble_scope.dart';
import 'package:looseleaf_ui/src/components/bubble/bubble_shape.dart';
import 'package:looseleaf_ui/src/components/message/message.dart';

/// One message body in a chat: a [BubbleContent] drawn as a felt-tip
/// cloud with a tail on the sender's side, a folded note or a sticky note,
/// plus optional [BubbleReactions] on its edge.
///
/// It sits on the [align] side of its row (the enclosing [Message]'s side
/// when null) and takes at most 80 % of it; a [BubbleVariant.ghost] bubble
/// may take the whole row. [variant], [shape] and [pen] reach the content
/// below. Inside a [BubbleGroup] only the last bubble keeps its tail.
///
/// ```dart
/// Bubble(
///   variant: .muted,
///   children: [BubbleContent(seed: 'a1', child: Text('Tags first?'))],
/// )
/// ```
///
/// Mirrors `Bubble` in upstream `src/components/ui/bubble.tsx`.
class Bubble extends StatelessWidget {
  const Bubble({
    super.key,
    required this.children,
    this.variant = BubbleVariant.primary,
    this.align,
    this.shape = BubbleShape.cloud,
    this.pen = BubblePen.ink,
    this.tail = true,
  });

  /// The [BubbleContent], then anything under it; [BubbleReactions] are
  /// pinned to the bubble's edge instead of stacked.
  final List<Widget> children;

  /// The ink: marker, highlighter, paper shade, a marker wash, paper and a
  /// line, nothing at all, or red pencil hatching.
  final BubbleVariant variant;

  /// Which end of the row it sits on; the tail follows and flips in
  /// right-to-left. The enclosing message's side, else start, when null.
  final ChatAlign? align;

  /// A cloud, a folded note or a sticky note.
  final BubbleShape shape;

  /// [BubblePen.you] writes the outline in blue felt and the words in the
  /// script font.
  final BubblePen pen;

  /// Draws the tail flick.
  final bool tail;

  @override
  Widget build(BuildContext context) {
    final side = align ?? ChatAlignScope.maybeOf(context) ?? ChatAlign.start;
    final showTail = tail && !BubbleGroupTailScope.hidesTail(context);
    final reactions = [
      for (final child in children)
        if (child is BubbleReactions) child,
    ];
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: switch (side) {
        ChatAlign.start => CrossAxisAlignment.start,
        ChatAlign.end => CrossAxisAlignment.end,
      },
      spacing: BubbleMetrics.gap,
      children: [
        for (final child in children)
          if (child is! BubbleReactions) child,
      ],
    );
    final bubble = switch (reactions) {
      [] => body,
      _ => Stack(
        clipBehavior: Clip.none,
        children: [
          body,
          for (final chip in reactions) _place(chip),
        ],
      ),
    };
    final fullWidth = variant == BubbleVariant.ghost;
    return BubbleScope(
      variant: variant,
      align: side,
      shape: shape,
      pen: pen,
      tail: showTail,
      child: BubbleGroupTailScope(
        hideTail: false,
        child: Align(
          alignment: switch (side) {
            ChatAlign.start => AlignmentDirectional.centerStart,
            ChatAlign.end => AlignmentDirectional.centerEnd,
          },
          child: LayoutBuilder(
            builder: (context, constraints) => ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: switch (fullWidth) {
                  true => constraints.maxWidth,
                  false => constraints.maxWidth * BubbleMetrics.maxWidthFactor,
                },
              ),
              child: bubble,
            ),
          ),
        ),
      ),
    );
  }

  Widget _place(BubbleReactions chip) {
    const inset = BubbleMetrics.reactionsInset;
    const overhang = BubbleMetrics.reactionsOverhang;
    final start = switch (chip.align) {
      ChatAlign.start => inset,
      ChatAlign.end => null,
    };
    final end = switch (chip.align) {
      ChatAlign.start => null,
      ChatAlign.end => inset,
    };
    return switch (chip.side) {
      BubbleReactionsSide.top => PositionedDirectional(
        top: 0,
        start: start,
        end: end,
        child: FractionalTranslation(
          translation: const Offset(0, -overhang),
          child: chip,
        ),
      ),
      BubbleReactionsSide.bottom => PositionedDirectional(
        bottom: 0,
        start: start,
        end: end,
        child: FractionalTranslation(
          translation: const Offset(0, overhang),
          child: chip,
        ),
      ),
    };
  }
}
