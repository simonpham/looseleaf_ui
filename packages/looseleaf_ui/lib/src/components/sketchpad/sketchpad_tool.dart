import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/sketchpad/sketchpad.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A pen button: a sample stroke of [value] in the current color over its
/// name, underlined on hover, highlighted and boxed when picked.
///
/// Mirrors `SketchpadTool` in upstream `src/components/ui/sketchpad.tsx`.
class SketchpadTool extends StatelessWidget {
  const SketchpadTool({
    super.key,
    required this.value,
    this.child,
    this.seed,
    this.focusNode,
    this.forcedStates = const {},
  });

  final SketchTool value;

  /// The name under the sample; the tool's label when null.
  final Widget? child;
  final String? seed;
  final FocusNode? focusNode;

  /// States shown whatever the input, for goldens.
  final Set<InkState> forcedStates;

  @override
  Widget build(BuildContext context) {
    final scope = SketchpadScope.of(context);
    final controller = scope.controller;
    final disabled = !scope.interactive;
    final params = SketchToolParams(tool: value, color: controller.color);
    final theme = LooseleafTheme.of(context);
    return SketchpadChoice(
      source: RecipeInkSource(sketchToolRecipe, params, json: params.toJson()),
      checked: controller.tool == value,
      onSelected: () => controller.selectTool(value),
      semanticLabel: value.label,
      disabled: disabled,
      seed: seed,
      focusNode: focusNode,
      forcedStates: forcedStates,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: Spacing.d64,
          minHeight: Spacing.d52,
          maxHeight: Spacing.d52,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.d8,
            0,
            Spacing.d8,
            SketchpadMetrics.toolLabelBottom,
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            widthFactor: 1,
            child: InkContent(
              style: SketchpadMetrics.toolLabel(theme, disabled: disabled),
              child: child ?? Text(value.label, maxLines: 1, softWrap: false),
            ),
          ),
        ),
      ),
    );
  }
}
