import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart'
    show
        BracketKind,
        BracketParams,
        BracketSide,
        MarkPen,
        MarkWeight,
        bracketRecipe;
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A hand-drawn bracket down the side of a block: square, curly or round,
/// at the start or the end, the way you mark a passage in the margin.
///
/// ```dart
/// Bracket(kind: .curly, child: Text('this whole passage'))
/// ```
///
/// Mirrors upstream `src/components/ui/bracket.tsx`.
class Bracket extends StatefulWidget {
  const Bracket({
    super.key,
    required this.child,
    this.kind = BracketKind.square,
    this.side = BracketSide.start,
    this.tone = MarkPen.ink,
    this.weight = MarkWeight.regular,
    this.inset = Spacing.d8,
    this.animate = false,
    this.show = true,
    this.delay = Duration.zero,
    this.seed,
  });

  /// The bracketed block.
  final Widget child;

  final BracketKind kind;

  /// The reading side the bracket stands on; the block is padded 28 px on
  /// that side.
  final BracketSide side;
  final MarkPen tone;
  final MarkWeight weight;

  /// The bracket's distance from its edge.
  final double inset;

  /// Hold the bracket back and draw it on once shown. Reduced motion just
  /// shows it.
  final bool animate;

  /// Show or hide the bracket; turning it on with [animate] replays it.
  final bool show;

  /// The wait before the bracket draws on.
  final Duration delay;

  /// Pins the hand.
  final String? seed;

  @override
  State<Bracket> createState() => _BracketState();
}

class _BracketState extends State<Bracket> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final params = BracketParams(
      kind: widget.kind,
      side: widget.side,
      tone: widget.tone,
      weight: widget.weight,
      inset: widget.inset,
      animate: widget.animate,
    );
    final padded = Padding(
      padding: switch (widget.side) {
        BracketSide.start => const EdgeInsetsDirectional.only(
          start: Spacing.d28,
        ),
        BracketSide.end => const EdgeInsetsDirectional.only(end: Spacing.d28),
      },
      child: widget.child,
    );
    if (!widget.show) return padded;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: InkMarkSurface(
                source: RecipeInkSource(
                  bracketRecipe,
                  params,
                  json: params.toJson(),
                ),
                seed: inkSeed(widget.seed),
                animate: widget.animate,
                delay: widget.delay,
              ),
            ),
          ),
        ),
        padded,
      ],
    );
  }
}
