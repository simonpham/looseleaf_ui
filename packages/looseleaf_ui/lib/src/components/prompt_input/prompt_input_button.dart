import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/button/button.dart';

/// A tool in the footer (attach, voice, …): a small ghost [Button].
///
/// Mirrors `PromptInputButton` in upstream
/// `src/components/ui/prompt-input.tsx`.
class PromptInputButton extends StatelessWidget {
  const PromptInputButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = ButtonVariant.ghost,
    this.size = ButtonSize.sm,
    this.disabled = false,
    this.semanticLabel,
    this.seed,
    this.focusNode,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool disabled;

  /// The accessible name, for icon buttons.
  final String? semanticLabel;
  final String? seed;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) => Button(
    variant: variant,
    size: size,
    disabled: disabled,
    semanticLabel: semanticLabel,
    seed: seed,
    focusNode: focusNode,
    onPressed: onPressed,
    child: child,
  );
}
