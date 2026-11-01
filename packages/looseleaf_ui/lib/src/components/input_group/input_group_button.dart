import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/button/button.dart';
import 'package:looseleaf_ui/src/components/input_group/input_group_scope.dart';

/// [InputGroupButton] sizes, the `size` variants of upstream
/// `inputGroupButtonVariants`.
enum InputGroupButtonSize {
  /// `h-6 px-2`.
  xs(ButtonSize.xs),

  /// `h-8 px-2.5`.
  sm(ButtonSize.sm),

  /// A 24 px square for one icon.
  iconXs(ButtonSize.iconXs),

  /// A 32 px square for one icon.
  iconSm(ButtonSize.iconSm);

  const InputGroupButtonSize(this.button);

  /// The [Button] size it draws with.
  final ButtonSize button;
}

/// A small [Button] that sits in an [InputGroupAddon]: ghost and extra
/// small by default, disabled with its group.
///
/// Mirrors `InputGroupButton` in upstream
/// `src/components/ui/input-group.tsx`.
class InputGroupButton extends StatelessWidget {
  const InputGroupButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = ButtonVariant.ghost,
    this.size = InputGroupButtonSize.xs,
    this.disabled = false,
    this.leading,
    this.seed,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final InputGroupButtonSize size;

  /// Disabled on its own; a disabled group disables it too.
  final bool disabled;

  /// An icon before the label.
  final Widget? leading;

  /// Pins the hand.
  final String? seed;

  /// The accessible name, for icon buttons.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Button(
    onPressed: onPressed,
    variant: variant,
    size: size.button,
    disabled: disabled || (InputGroupScope.maybeOf(context)?.disabled ?? false),
    leading: leading,
    seed: seed,
    semanticLabel: semanticLabel,
    child: child,
  );
}
