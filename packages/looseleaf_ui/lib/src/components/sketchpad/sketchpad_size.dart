import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/sketchpad/sketchpad.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// A width button: an ink dot of [value]'s width, looped when picked.
///
/// Mirrors `SketchpadSize` in upstream `src/components/ui/sketchpad.tsx`.
class SketchpadSize extends StatelessWidget {
  const SketchpadSize({
    super.key,
    required this.value,
    this.semanticLabel,
    this.seed,
    this.focusNode,
    this.forcedStates = const {},
  });

  final SketchSizeName value;

  /// The accessible name; "Fine line", "Bold line" when null.
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
    final params = SketchSizeParams(size: value);
    return Opacity(
      opacity: switch (disabled) {
        true => SketchpadMetrics.disabledOpacity,
        false => 1,
      },
      child: SketchpadChoice(
        source: RecipeInkSource(
          sketchSizeRecipe,
          params,
          json: params.toJson(),
        ),
        checked: SketchSizeLabel.of(controller.size) == value,
        onSelected: () => controller.size = value.size,
        semanticLabel: semanticLabel ?? '${value.label} line',
        disabled: disabled,
        seed: seed,
        focusNode: focusNode,
        forcedStates: forcedStates,
        child: const SizedBox.square(dimension: SketchpadMetrics.pick),
      ),
    );
  }
}
