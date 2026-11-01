import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';

/// Words scribbled out, a dense back-and-forth over each line, the way you
/// redact a draft by hand. The text stays text underneath.
///
/// ```dart
/// Scribble(child: Text('the first idea'))
/// ```
///
/// Mirrors upstream `src/components/ui/scribble.tsx`.
class Scribble extends StatefulWidget {
  const Scribble({
    super.key,
    required this.child,
    this.tone = MarkPen.ink,
    this.weight = MarkWeight.regular,
    this.animate = false,
    this.show = true,
    this.delay = Duration.zero,
    this.seed,
  });

  /// The scribbled text, usually a [Text].
  final Widget child;

  final MarkPen tone;
  final MarkWeight weight;

  /// Hold the scribble back and wipe it in once shown. Reduced motion just
  /// shows it.
  final bool animate;

  /// Show or hide the scribble; turning it on with [animate] replays it.
  final bool show;

  /// The wait before the first line draws on; each further line follows a
  /// beat later.
  final Duration delay;

  /// Pins the hand: the same seed always draws the same scribble.
  final String? seed;

  @override
  State<Scribble> createState() => _ScribbleState();
}

class _ScribbleState extends State<Scribble> with InkSeed {
  @override
  Widget build(BuildContext context) => InkMark(
    seed: inkSeed(widget.seed),
    over: true,
    animate: widget.animate,
    show: widget.show,
    delay: widget.delay,
    source: (line) {
      final params = ScribbleParams(
        line: line,
        tone: widget.tone,
        weight: widget.weight,
      );
      return RecipeInkSource(scribbleRecipe, params, json: params.toJson());
    },
    child: widget.child,
  );
}
