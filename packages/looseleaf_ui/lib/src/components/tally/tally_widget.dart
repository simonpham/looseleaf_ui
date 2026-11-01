import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart'
    show MarkPen, MarkWeight, TallyParams, tallyBox, tallyRecipe;
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';

/// The tally's glyph height.
enum TallySize {
  sm(14),
  md(22),
  lg(34);

  const TallySize(this.glyphHeight);

  /// The height of one group of five, in px.
  final double glyphHeight;
}

/// A count kept in tally marks: groups of four strokes crossed by a fifth,
/// sized to the count (0 to 99) and read out as the number.
///
/// ```dart
/// const Tally(count: 7)
/// ```
///
/// Mirrors upstream `src/components/ui/tally.tsx`.
class Tally extends StatefulWidget {
  const Tally({
    super.key,
    required this.count,
    this.size = TallySize.md,
    this.glyphHeight,
    this.tone = MarkPen.ink,
    this.weight = MarkWeight.regular,
    this.label,
    this.animate = false,
    this.show = true,
    this.delay = Duration.zero,
    this.seed,
  });

  /// The count, clamped to 0..99.
  final int count;

  final TallySize size;

  /// A custom glyph height overriding [size] (upstream's numeric `size`).
  final double? glyphHeight;

  final MarkPen tone;
  final MarkWeight weight;

  /// The accessible name; the count by default.
  final String? label;

  /// Hold the marks back and wipe them in once shown. Reduced motion just
  /// shows them.
  final bool animate;

  /// Show or hide the marks, keeping their room.
  final bool show;

  /// The wait before the marks draw on.
  final Duration delay;

  /// Pins the hand.
  final String? seed;

  @override
  State<Tally> createState() => _TallyState();
}

class _TallyState extends State<Tally> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final count = math.max(0, math.min(99, widget.count));
    final height = widget.glyphHeight ?? widget.size.glyphHeight;
    final box = tallyBox(count, height);
    final params = TallyParams(
      count: count,
      gh: height,
      tone: widget.tone,
      weight: widget.weight,
      rtl: Directionality.maybeOf(context) == TextDirection.rtl,
    );
    final room = SizedBox(width: math.max(4, box.w).toDouble(), height: box.h);
    return Semantics(
      container: true,
      image: true,
      label: widget.label ?? '$count',
      child: ExcludeSemantics(
        child: switch (widget.show) {
          true => InkMarkSurface(
            source: RecipeInkSource(
              tallyRecipe,
              params,
              json: params.toJson(),
            ),
            seed: inkSeed(widget.seed),
            draw: InkMarkDraw.wipe,
            animate: widget.animate,
            delay: widget.delay,
            child: room,
          ),
          false => room,
        },
      ),
    );
  }
}
