import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/alert_dialog/alert_dialog.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// An alert dialog's answers: like a [DialogFooter] (a row at the end, or
/// stacked on phones), but the small size sets them side by side in two
/// equal columns.
///
/// Mirrors `AlertDialogFooter` in upstream
/// `src/components/ui/alert-dialog.tsx`.
class AlertDialogFooter extends StatelessWidget {
  const AlertDialogFooter({super.key, required this.children});

  /// [AlertDialogCancel] and [AlertDialogAction], in reading order.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (AlertDialogContentScope.sizeOf(context) == AlertDialogSize.regular) {
      return DialogFooter(children: children);
    }
    return Row(
      spacing: Spacing.d8,
      children: [
        for (final child in children) Expanded(child: child),
      ],
    );
  }
}
