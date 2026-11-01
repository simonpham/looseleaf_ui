import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart'
    show
        MarkPen,
        MarkWeight,
        SquiggleKind,
        SquiggleOrientation,
        SquiggleParams,
        squiggleRecipe;
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A hand-drawn rule: wavy, zigzag, loops, scallops, dashes or dots, across
/// the width or, vertical, down the height.
///
/// Decorative by default; with [decorative] false it is announced as a
/// separator.
///
/// ```dart
/// const Squiggle(kind: .zigzag, tone: .red)
/// ```
///
/// Mirrors upstream `src/components/ui/squiggle.tsx`.
class Squiggle extends StatefulWidget {
  const Squiggle({
    super.key,
    this.kind = SquiggleKind.wavy,
    this.orientation = SquiggleOrientation.horizontal,
    this.decorative = true,
    this.tone = MarkPen.ink,
    this.weight = MarkWeight.regular,
    this.animate = false,
    this.show = true,
    this.delay = Duration.zero,
    this.seed,
    this.semanticLabel = 'separator',
  });

  final SquiggleKind kind;

  /// Horizontal fills the width at 16 px tall; vertical is 16 px wide and
  /// at least 32 px tall, filling the height a parent stretches it to.
  final SquiggleOrientation orientation;

  /// Leave it out of semantics, like upstream `role="none"`.
  final bool decorative;

  final MarkPen tone;
  final MarkWeight weight;

  /// Hold the line back and draw it on once shown. Reduced motion just
  /// shows it.
  final bool animate;

  /// Show or hide the line, keeping its room; turning it on with [animate]
  /// replays it.
  final bool show;

  /// The wait before the line draws on.
  final Duration delay;

  /// Pins the hand.
  final String? seed;

  /// The name read when not [decorative] (upstream `role="separator"`).
  final String semanticLabel;

  @override
  State<Squiggle> createState() => _SquiggleState();
}

class _SquiggleState extends State<Squiggle> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final params = SquiggleParams(
      kind: widget.kind,
      orientation: widget.orientation,
      tone: widget.tone,
      weight: widget.weight,
      animate: widget.animate,
    );
    final room = switch (widget.orientation) {
      SquiggleOrientation.horizontal => const SizedBox(
        width: double.infinity,
        height: Spacing.d16,
      ),
      SquiggleOrientation.vertical => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Spacing.d32),
        child: const SizedBox(width: Spacing.d16),
      ),
    };
    final line = switch (widget.show) {
      true => InkMarkSurface(
        source: RecipeInkSource(
          squiggleRecipe,
          params,
          json: params.toJson(),
        ),
        seed: inkSeed(widget.seed),
        animate: widget.animate,
        delay: widget.delay,
        child: room,
      ),
      false => room,
    };
    if (widget.decorative) return ExcludeSemantics(child: line);
    return Semantics(
      container: true,
      label: widget.semanticLabel,
      child: ExcludeSemantics(child: line),
    );
  }
}
