import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';

/// How fat the highlighter is held.
enum HighlightWeight {
  light(0.82),
  regular(1),
  heavy(1.22);

  const HighlightWeight(this.fat);

  /// The band thickness factor.
  final double fat;
}

/// A highlighter swipe behind real words, one swipe per line when the text
/// wraps, in yellow or any stationery color.
///
/// ```dart
/// Highlight(child: Text('a swipe of yellow'))
/// ```
///
/// Mirrors upstream `src/components/ui/highlight.tsx`.
class Highlight extends StatefulWidget {
  const Highlight({
    super.key,
    required this.child,
    this.tone = HighlightTone.yellow,
    this.weight = HighlightWeight.regular,
    this.cover = HighlightCover.full,
    this.animate = false,
    this.show = true,
    this.delay = Duration.zero,
    this.seed,
  });

  /// The highlighted text, usually a [Text].
  final Widget child;

  final HighlightTone tone;
  final HighlightWeight weight;

  /// `full` covers the letters; `under` runs along the lower half of the
  /// line.
  final HighlightCover cover;

  /// Hold the swipe back and wipe it in once shown. Reduced motion just
  /// shows it.
  final bool animate;

  /// Show or hide the swipe; turning it on with [animate] replays it.
  final bool show;

  /// The wait before the first line draws on; each further line follows a
  /// beat later.
  final Duration delay;

  /// Pins the hand: the same seed always draws the same swipe.
  final String? seed;

  @override
  State<Highlight> createState() => _HighlightState();
}

class _HighlightState extends State<Highlight> with InkSeed {
  @override
  Widget build(BuildContext context) => InkMark(
    seed: inkSeed(widget.seed),
    animate: widget.animate,
    show: widget.show,
    delay: widget.delay,
    source: (line) {
      final params = HighlightParams(
        line: line,
        tone: widget.tone,
        fat: widget.weight.fat,
        cover: widget.cover,
      );
      return RecipeInkSource(highlightRecipe, params, json: params.toJson());
    },
    child: widget.child,
  );
}
