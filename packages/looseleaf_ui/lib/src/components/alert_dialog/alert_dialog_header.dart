import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/alert_dialog/alert_dialog.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// An alert dialog's [AlertDialogMedia], [AlertDialogTitle] and
/// [AlertDialogDescription], 6 px apart.
///
/// Centred on phones and in the small size; from 640 px the regular size
/// lines them up at the start, with the media beside the title and
/// description, 24 px from them.
///
/// Mirrors `AlertDialogHeader` in upstream
/// `src/components/ui/alert-dialog.tsx`.
class AlertDialogHeader extends StatelessWidget {
  const AlertDialogHeader({super.key, required this.children});

  /// The media, title and description.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final phone =
        DialogContentScope.maybeOf(context)?.phone ??
        DialogMetrics.phone(context);
    final beside =
        !phone &&
        AlertDialogContentScope.sizeOf(context) == AlertDialogSize.regular;
    if (!beside) {
      return DefaultTextStyle.merge(
        textAlign: TextAlign.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: Spacing.d6,
          children: children,
        ),
      );
    }
    final media = children.whereType<AlertDialogMedia>();
    final text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d6,
      children: [
        for (final child in children)
          if (child is! AlertDialogMedia) child,
      ],
    );
    return DefaultTextStyle.merge(
      textAlign: TextAlign.start,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d24,
        children: [
          ...media,
          Expanded(child: text),
        ],
      ),
    );
  }
}
