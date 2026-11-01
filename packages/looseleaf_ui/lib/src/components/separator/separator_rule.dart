import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One drawn rule, a pixel thick and as long as its parent allows: the line
/// of a [Separator]. Horizontal rules fill the width, vertical ones the
/// height; the drawing reaches past that pixel by the recipe's pad.
///
/// Mirrors `Rule` in upstream `src/components/ui/separator.tsx`.
class SeparatorRule extends StatefulWidget {
  const SeparatorRule({
    super.key,
    this.variant = SeparatorVariant.pencil,
    this.orientation = SeparatorOrientation.horizontal,
    this.seed,
  });

  /// How the rule is drawn.
  final SeparatorVariant variant;

  /// Which way it runs.
  final SeparatorOrientation orientation;

  /// Pins the drawing.
  final String? seed;

  @override
  State<SeparatorRule> createState() => _SeparatorRuleState();
}

class _SeparatorRuleState extends State<SeparatorRule> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final params = SeparatorParams(
      variant: widget.variant,
      orientation: widget.orientation,
    );
    final rule = InkSurface(
      source: RecipeInkSource(separatorRecipe, params, json: params.toJson()),
      seed: inkSeed(widget.seed),
      still: true,
    );
    return switch (widget.orientation) {
      SeparatorOrientation.horizontal => SizedBox(
        width: double.infinity,
        height: Spacing.d1,
        child: rule,
      ),
      SeparatorOrientation.vertical => SizedBox(
        width: Spacing.d1,
        height: double.infinity,
        child: rule,
      ),
    };
  }
}
