import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';

/// A loop drawn around real words: a circle, a box or a pair of brackets,
/// around the whole phrase even when it wraps.
///
/// ```dart
/// Circled(tone: .red, child: Text('margins'))
/// ```
///
/// Mirrors upstream `src/components/ui/circled.tsx`.
class Circled extends StatefulWidget {
  const Circled({
    super.key,
    required this.child,
    this.shape = CircledShape.circle,
    this.tone = MarkPen.ink,
    this.weight = MarkWeight.regular,
    this.bleed,
    this.animate = false,
    this.show = true,
    this.delay = Duration.zero,
    this.seed,
  });

  /// The circled text, usually a [Text].
  final Widget child;

  final CircledShape shape;
  final MarkPen tone;
  final MarkWeight weight;

  /// How far the loop runs past the words, in px (0 to 16, default 2).
  final double? bleed;

  /// Hold the loop back and draw it on, stroke by stroke, once shown.
  /// Reduced motion just shows it.
  final bool animate;

  /// Show or hide the loop; turning it on with [animate] replays it.
  final bool show;

  /// The wait before the loop draws on.
  final Duration delay;

  /// Pins the hand: the same seed always draws the same loop.
  final String? seed;

  @override
  State<Circled> createState() => _CircledState();
}

class _CircledState extends State<Circled> with InkSeed {
  @override
  Widget build(BuildContext context) => InkMark(
    seed: inkSeed(widget.seed),
    box: true,
    over: true,
    draw: InkMarkDraw.reveal,
    animate: widget.animate,
    show: widget.show,
    delay: widget.delay,
    source: (line) {
      final params = CircledParams(
        line: line,
        shape: widget.shape,
        tone: widget.tone,
        weight: widget.weight,
        bleed: widget.bleed,
      );
      return RecipeInkSource(circledRecipe, params, json: params.toJson());
    },
    child: widget.child,
  );
}
