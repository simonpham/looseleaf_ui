import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Tally marks for a count, in gates of five, to show beside a [Stepper]:
/// `||||` and a strike for each five, at most [max]. Decorative.
///
/// Mirrors `StepperTally` in upstream `src/components/ui/stepper.tsx`.
class StepperTally extends StatefulWidget {
  const StepperTally({
    super.key,
    required this.value,
    this.max = 20,
    this.seed,
  });

  /// The count; fractions are dropped, negatives show nothing.
  final double? value;

  /// The most marks drawn.
  final int max;

  /// Pins the hand.
  final String? seed;

  @override
  State<StepperTally> createState() => _StepperTallyState();
}

class _StepperTallyState extends State<StepperTally> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final shown = widget.value ?? 0;
    final count = switch (shown.isFinite) {
      true => math.max(0, math.min(shown.floor(), widget.max)),
      false => 0,
    };
    final width = tallyWidth(math.max(count, 1));
    final box = SizedBox(width: width, height: Spacing.d20);
    if (count == 0) return box;
    final params = StepperTallyParams(count: count);
    return ExcludeSemantics(
      child: InkSurface(
        source: RecipeInkSource(
          stepperTallyRecipe,
          params,
          json: params.toJson(),
        ),
        seed: inkSeed(widget.seed),
        still: true,
        currentColor: LooseleafTheme.of(context).colors.ink,
        child: box,
      ),
    );
  }
}
