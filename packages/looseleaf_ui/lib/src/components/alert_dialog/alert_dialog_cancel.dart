import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/button/button.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';

/// The answer that backs out: an outline [Button] that takes focus when the
/// alert dialog opens, calls [onPressed] and closes it.
///
/// Mirrors `AlertDialogCancel` in upstream
/// `src/components/ui/alert-dialog.tsx`.
class AlertDialogCancel extends StatelessWidget {
  const AlertDialogCancel({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = ButtonVariant.outline,
    this.size = ButtonSize.regular,
    this.disabled = false,
    this.seed,
    this.focusNode,
  });

  /// The label.
  final Widget child;

  /// Called on press, before the dialog closes.
  final VoidCallback? onPressed;

  /// The button's look.
  final ButtonVariant variant;

  /// The button's size.
  final ButtonSize size;

  /// Greys it out.
  final bool disabled;

  /// Pins the button's ink.
  final String? seed;

  /// The button's focus node.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final dialog = DialogScope.maybeOf(context);
    return Button(
      variant: variant,
      size: size,
      disabled: disabled,
      seed: seed,
      focusNode: focusNode,
      autofocus: true,
      onPressed: () {
        onPressed?.call();
        dialog?.close();
      },
      child: child,
    );
  }
}
