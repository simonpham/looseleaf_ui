import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/prompt_input/prompt_input.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The line the message is written on: a pencil rule that turns into a
/// blue brush stroke while the textarea has focus, dashed when disabled.
///
/// Mirrors `PromptInputBody` in upstream
/// `src/components/ui/prompt-input.tsx`.
class PromptInputBody extends StatefulWidget {
  const PromptInputBody({super.key, required this.child, this.seed});

  /// The [PromptInputTextarea].
  final Widget child;

  /// Pins the line's hand.
  final String? seed;

  @override
  State<PromptInputBody> createState() => _PromptInputBodyState();
}

class _PromptInputBodyState extends State<PromptInputBody> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final model = PromptInputModel.of(context);
    final params = PromptInputBodyParams(disabled: model.disabled);
    return ListenableBuilder(
      listenable: model.focusNode,
      builder: (context, child) => InkSurface(
        source: RecipeInkSource(
          promptInputBodyRecipe,
          params,
          json: params.toJson(),
        ),
        seed: inkSeed(widget.seed),
        still: true,
        states: {
          if (model.focusNode.hasFocus) InkState.focused,
          if (model.disabled) InkState.disabled,
        },
        child: child,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Spacing.d48),
        child: Padding(
          padding: const EdgeInsets.only(bottom: Spacing.d8),
          child: widget.child,
        ),
      ),
    );
  }
}
