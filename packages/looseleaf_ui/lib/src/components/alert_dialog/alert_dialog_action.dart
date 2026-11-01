import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/button/button.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';

/// The answer that goes ahead: a [Button] (filled by default, `destructive`
/// for a risky one) that calls [onPressed] and closes the alert dialog.
/// Set [closeOnPress] false to keep it open while the work runs and close
/// it yourself.
///
/// Mirrors `AlertDialogAction` in upstream
/// `src/components/ui/alert-dialog.tsx`.
class AlertDialogAction extends StatelessWidget {
  const AlertDialogAction({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.regular,
    this.disabled = false,
    this.closeOnPress = true,
    this.leading,
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

  /// Whether pressing it closes the dialog.
  final bool closeOnPress;

  /// An icon before the label (a spinner while busy).
  final Widget? leading;

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
      leading: leading,
      seed: seed,
      focusNode: focusNode,
      onPressed: () {
        onPressed?.call();
        if (closeOnPress) dialog?.close();
      },
      child: child,
    );
  }
}
