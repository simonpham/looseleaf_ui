import 'dart:ui' show SemanticsRole;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One tick of [CarouselDots]: a pencil tally mark that turns blue for the
/// slide on show, every fifth a slash across the four before it.
///
/// Mirrors `Tick` in upstream `src/components/ui/carousel.tsx`.
class CarouselTick extends StatelessWidget {
  const CarouselTick({
    super.key,
    required this.index,
    required this.selected,
    required this.seed,
    required this.onSelect,
    this.focusNode,
    this.forcedStates = const {},
  });

  final int index;
  final bool selected;

  /// The carousel's seed; the tick draws with `seed|tick<index>`.
  final String seed;
  final VoidCallback onSelect;
  final FocusNode? focusNode;
  final Set<InkState> forcedStates;

  /// The distance between ticks (`PITCH`).
  static const double pitch = Spacing.d24;

  bool get slash => index % 5 == 4;

  @override
  Widget build(BuildContext context) {
    final params = CarouselTickParams(slash: slash, pitch: pitch);
    final theme = LooseleafTheme.of(context);
    return Semantics(
      container: true,
      role: SemanticsRole.tab,
      selected: selected,
      label: 'Go to slide ${index + 1}',
      child: InkInteraction(
        onActivate: onSelect,
        focusNode: focusNode,
        states: {...forcedStates, if (selected) InkState.checked},
        builder: (context, states) => InkSurface(
          source: RecipeInkSource(
            carouselTickRecipe,
            params,
            json: params.toJson(),
          ),
          seed: '$seed|tick$index',
          states: states,
          still: true,
          currentColor: theme.colors.ink,
          pad: switch (slash) {
            true => carouselTickPad,
            false => carouselTickPadPlain,
          },
          child: const SizedBox(width: pitch, height: Spacing.d32),
        ),
      ),
    );
  }
}
