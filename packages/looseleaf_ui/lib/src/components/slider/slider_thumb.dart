import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/slider/slider_geometry.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// A [Slider]'s handle: a paper disc in an inked ring that grows a little
/// on hover and shrinks while dragged.
///
/// Mirrors `SliderThumb` in upstream `src/components/ui/slider.tsx`.
class SliderThumb extends StatelessWidget {
  const SliderThumb({
    super.key,
    required this.seed,
    required this.states,
    this.disabled = false,
    this.invalid = false,
  });

  final String seed;

  /// `hovered`, `pressed` and `focused` scale and ring it.
  final Set<InkState> states;

  final bool disabled;

  /// A red pencil ring.
  final bool invalid;

  @override
  Widget build(BuildContext context) {
    final params = SliderThumbParams(disabled: disabled, invalid: invalid);
    final scale = switch ((
      states.contains(InkState.pressed),
      states.contains(InkState.hovered),
    )) {
      (true, _) => 0.95,
      (false, true) => 1.05,
      _ => 1.0,
    };
    return AnimatedScale(
      scale: scale,
      duration: InkMotion.of(context, InkMotion.press),
      curve: InkMotion.easeOut,
      child: InkSurface(
        source: RecipeInkSource(
          sliderThumbRecipe,
          params,
          json: params.toJson(),
        ),
        seed: seed,
        states: states,
        still: true,
        child: const SizedBox.square(dimension: SliderGeometry.thumb),
      ),
    );
  }
}
