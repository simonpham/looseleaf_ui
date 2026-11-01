import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/bubble/bubble_metrics.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/message/message.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Which edge of its bubble a [BubbleReactions] chip overlaps.
enum BubbleReactionsSide { top, bottom }

/// A white vinyl chip with a pencil outline pinned to a [Bubble]'s edge,
/// hanging three quarters off it: emoji, counts or small buttons.
///
/// Give it to a [Bubble] among its children; the bubble places it on
/// [side] at the [align] corner, 12 px in.
///
/// ```dart
/// Bubble(children: [
///   BubbleContent(child: Text('Want small chips?')),
///   const BubbleReactions(align: .start, child: Text('+1')),
/// ])
/// ```
///
/// Mirrors `BubbleReactions` in upstream `src/components/ui/bubble.tsx`.
class BubbleReactions extends StatefulWidget {
  const BubbleReactions({
    super.key,
    required this.child,
    this.side = BubbleReactionsSide.bottom,
    this.align = ChatAlign.end,
    this.padding = BubbleMetrics.reactionsPadding,
    this.seed,
  });

  /// The chip's content.
  final Widget child;

  /// The edge it overlaps.
  final BubbleReactionsSide side;

  /// The corner it sits at.
  final ChatAlign align;

  /// `px-2 py-0.5`; pass [EdgeInsets.zero] around buttons
  /// (upstream `has-[button]:p-0`).
  final EdgeInsetsGeometry padding;

  /// Pins the hand.
  final String? seed;

  @override
  State<BubbleReactions> createState() => _BubbleReactionsState();
}

class _BubbleReactionsState extends State<BubbleReactions> with InkSeed {
  static const BubbleReactionsParams _params = BubbleReactionsParams();

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return InkSurface(
      source: RecipeInkSource(
        bubbleReactionsRecipe,
        _params,
        json: _params.toJson(),
      ),
      seed: inkSeed(widget.seed),
      still: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: BubbleMetrics.reactionsMinHeight,
        ),
        child: Padding(
          padding: widget.padding,
          child: InkContent(
            style: BubbleMetrics.reactions(theme).copyWith(
              color: theme.colors.ink,
            ),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
