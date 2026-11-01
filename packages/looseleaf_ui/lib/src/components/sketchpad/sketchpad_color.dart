import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/sketchpad/sketchpad.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// A color swatch: an inked blot of [value] in a loop, a wider loop when
/// picked.
///
/// Mirrors `SketchpadColor` in upstream `src/components/ui/sketchpad.tsx`.
class SketchpadColor extends StatelessWidget {
  const SketchpadColor({
    super.key,
    required this.value,
    this.semanticLabel,
    this.seed,
    this.focusNode,
    this.forcedStates = const {},
  });

  final SketchColor value;

  /// The accessible name; the color's name when null.
  final String? semanticLabel;
  final String? seed;
  final FocusNode? focusNode;

  /// States shown whatever the input, for goldens.
  final Set<InkState> forcedStates;

  @override
  Widget build(BuildContext context) {
    final scope = SketchpadScope.of(context);
    final controller = scope.controller;
    final disabled = !scope.interactive;
    final params = SketchSwatchParams(color: value);
    return Opacity(
      opacity: switch (disabled) {
        true => SketchpadMetrics.disabledOpacity,
        false => 1,
      },
      child: SketchpadChoice(
        source: RecipeInkSource(
          sketchSwatchRecipe,
          params,
          json: params.toJson(),
        ),
        checked: controller.color == value,
        onSelected: () => controller.color = value,
        semanticLabel: semanticLabel ?? value.label,
        disabled: disabled,
        seed: seed,
        focusNode: focusNode,
        forcedStates: forcedStates,
        child: const SizedBox.square(dimension: SketchpadMetrics.pick),
      ),
    );
  }
}
