import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/button/button.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A dialog's buttons: in a row at the end from 640 px, stacked full
/// width on phones with the first child at the bottom, 8 px apart.
/// [showCloseButton] adds an outline "Close" button after them.
///
/// Mirrors `DialogFooter` in upstream `src/components/ui/dialog.tsx`.
class DialogFooter extends StatelessWidget {
  const DialogFooter({
    super.key,
    this.children = const [],
    this.showCloseButton = false,
    this.closeLabel = 'Close',
    this.alignment = MainAxisAlignment.end,
  });

  /// The buttons, in reading order.
  final List<Widget> children;

  /// Adds an outline button that closes the dialog.
  final bool showCloseButton;

  /// The close button's text.
  final String closeLabel;

  /// Where the row sits from 640 px: at the end (upstream `sm:justify-end`)
  /// unless changed, like the close-button example's `sm:justify-start`.
  /// Phones always stack the buttons full width.
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final phone =
        DialogContentScope.maybeOf(context)?.phone ??
        DialogMetrics.phone(context);
    final buttons = [
      ...children,
      if (showCloseButton)
        DialogClose(
          builder: (context, close) => Button(
            variant: ButtonVariant.outline,
            onPressed: close,
            child: Text(closeLabel),
          ),
        ),
    ];
    if (phone) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        verticalDirection: VerticalDirection.up,
        spacing: Spacing.d8,
        children: buttons,
      );
    }
    return Row(
      mainAxisAlignment: alignment,
      spacing: Spacing.d8,
      children: buttons,
    );
  }
}
