import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';

/// Words struck through by hand: one stroke, two, or a cross over the whole
/// phrase. Drawn over the text, red by default.
///
/// ```dart
/// Strike(child: Text("writer's"))
/// ```
///
/// Mirrors upstream `src/components/ui/strike.tsx`.
class Strike extends StatefulWidget {
  const Strike({
    super.key,
    required this.child,
    this.kind = StrikeKind.single,
    this.tone = MarkPen.red,
    this.weight = MarkWeight.regular,
    this.animate = false,
    this.show = true,
    this.delay = Duration.zero,
    this.seed,
  });

  /// The struck text, usually a [Text].
  final Widget child;

  /// `cross` draws one cross around every line.
  final StrikeKind kind;
  final MarkPen tone;
  final MarkWeight weight;

  /// Hold the stroke back and wipe it in once shown. Reduced motion just
  /// shows it.
  final bool animate;

  /// Show or hide the stroke; turning it on with [animate] replays it.
  final bool show;

  /// The wait before the first line draws on; each further line follows a
  /// beat later.
  final Duration delay;

  /// Pins the hand: the same seed always draws the same stroke.
  final String? seed;

  @override
  State<Strike> createState() => _StrikeState();
}

class _StrikeState extends State<Strike> with InkSeed {
  @override
  Widget build(BuildContext context) => InkMark(
    seed: inkSeed(widget.seed),
    box: widget.kind == StrikeKind.cross,
    over: true,
    animate: widget.animate,
    show: widget.show,
    delay: widget.delay,
    source: (line) {
      final params = StrikeParams(
        line: line,
        kind: widget.kind,
        tone: widget.tone,
        weight: widget.weight,
      );
      return RecipeInkSource(strikeRecipe, params, json: params.toJson());
    },
    child: widget.child,
  );
}
