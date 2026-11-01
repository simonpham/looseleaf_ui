import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';

/// A hand underline under real words: single, double, wavy or scribbled,
/// one stroke per line when the text wraps.
///
/// ```dart
/// Underline(tone: .red, child: Text('red pencil'))
/// ```
///
/// Mirrors upstream `src/components/ui/underline.tsx`.
class Underline extends StatefulWidget {
  const Underline({
    super.key,
    required this.child,
    this.kind = UnderlineMarkKind.single,
    this.tone = MarkPen.ink,
    this.weight = MarkWeight.regular,
    this.animate = false,
    this.show = true,
    this.delay = Duration.zero,
    this.seed,
  });

  /// The underlined text, usually a [Text].
  final Widget child;

  final UnderlineMarkKind kind;
  final MarkPen tone;
  final MarkWeight weight;

  /// Hold the line back and wipe it in once shown. Reduced motion just
  /// shows it.
  final bool animate;

  /// Show or hide the line; turning it on with [animate] replays it.
  final bool show;

  /// The wait before the first line draws on; each further line follows a
  /// beat later.
  final Duration delay;

  /// Pins the hand: the same seed always draws the same line.
  final String? seed;

  @override
  State<Underline> createState() => _UnderlineState();
}

class _UnderlineState extends State<Underline> with InkSeed {
  @override
  Widget build(BuildContext context) => InkMark(
    seed: inkSeed(widget.seed),
    animate: widget.animate,
    show: widget.show,
    delay: widget.delay,
    source: (line) {
      final params = UnderlineParams(
        line: line,
        kind: widget.kind,
        tone: widget.tone,
        weight: widget.weight,
      );
      return RecipeInkSource(underlineRecipe, params, json: params.toJson());
    },
    child: widget.child,
  );
}
