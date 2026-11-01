import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The 24 px push pin holding a corkboard note: a coloured head with a cast
/// shadow, an ink ring and a shine. [lifted] raises it 6 px and grows it a
/// little, as when its note is picked up. Decorative.
///
/// Mirrors `Pin` in upstream `src/components/ui/corkboard.tsx`.
class CorkboardPin extends StatelessWidget {
  const CorkboardPin({
    super.key,
    required this.color,
    this.lifted = false,
    this.seed = 'pin',
  });

  /// Upstream's `size-6`.
  static const double size = Spacing.d24;

  /// The head's paint.
  final PaintKey color;

  /// Raised, while its note is dragged.
  final bool lifted;

  /// Pins the hand.
  final String seed;

  @override
  Widget build(BuildContext context) {
    final params = CorkPinParams(color: color);
    final duration = InkMotion.of(context, InkMotion.hover);
    return ExcludeSemantics(
      child: IgnorePointer(
        child: AnimatedSlide(
          offset: switch (lifted) {
            true => const Offset(0, -Spacing.d6 / size),
            false => Offset.zero,
          },
          duration: duration,
          curve: InkMotion.settle,
          child: AnimatedScale(
            scale: switch (lifted) {
              true => 1.1,
              false => 1.0,
            },
            duration: duration,
            curve: InkMotion.settle,
            child: InkSurface(
              source: RecipeInkSource(
                corkPinRecipe,
                params,
                json: params.toJson(),
              ),
              seed: seed,
              child: const SizedBox.square(dimension: size),
            ),
          ),
        ),
      ),
    );
  }
}
