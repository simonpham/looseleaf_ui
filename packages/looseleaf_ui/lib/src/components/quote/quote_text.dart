import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart'
    show MarkPen, MarkWeight, QuoteParams, quoteRecipe;
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/quote/quote.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The quoted words in the script face, with hand-drawn quote marks in the
/// gutters: an opening mark at the start, a closing one at the end, and,
/// with [rule], a rule down the start.
///
/// Mirrors upstream `QuoteText` (`src/components/ui/quote.tsx`).
class QuoteText extends StatefulWidget {
  const QuoteText({
    super.key,
    required this.child,
    this.size = QuoteSize.md,
    this.tone = MarkPen.marker,
    this.weight = MarkWeight.regular,
    this.rule = false,
    this.animate = false,
    this.show = true,
    this.delay = Duration.zero,
    this.seed,
  });

  /// The quoted words, usually a [Text].
  final Widget child;

  /// The marks' size and the gutters they sit in.
  final QuoteSize size;
  final MarkPen tone;
  final MarkWeight weight;

  /// Draw a rule down the start gutter.
  final bool rule;

  /// Hold the marks back and draw them on once shown. Reduced motion just
  /// shows them.
  final bool animate;

  /// Show or hide the marks.
  final bool show;

  /// The wait before the marks draw on.
  final Duration delay;

  /// Pins the hand.
  final String? seed;

  @override
  State<QuoteText> createState() => _QuoteTextState();
}

class _QuoteTextState extends State<QuoteText> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final params = QuoteParams(
      tone: widget.tone,
      weight: widget.weight,
      size: widget.size.markSize,
      rule: widget.rule,
      animate: widget.animate,
    );
    final words = Padding(
      padding: widget.size.padding,
      child: DefaultTextStyle.merge(
        style: theme.typography.face(
          KevinSansFace.script,
          cssSize: 26,
          cssLineHeight: 1.3,
          color: theme.colors.ink,
        ),
        child: widget.child,
      ),
    );
    if (!widget.show) return words;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: InkMarkSurface(
                source: RecipeInkSource(
                  quoteRecipe,
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
        words,
      ],
    );
  }
}
