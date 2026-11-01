import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A dialog's [DialogTitle] and [DialogDescription], 8 px apart: centred
/// on phones, at the start from 640 px, clear of the close mark.
///
/// Mirrors `DialogHeader` in upstream `src/components/ui/dialog.tsx`.
class DialogHeader extends StatelessWidget {
  const DialogHeader({super.key, required this.children});

  /// The title and description.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scope = DialogContentScope.maybeOf(context);
    final phone = scope?.phone ?? DialogMetrics.phone(context);
    final clear = (scope?.closeMark ?? false) && !phone;
    return Padding(
      padding: EdgeInsetsDirectional.only(
        end: switch (clear) {
          true => Spacing.d32,
          false => 0,
        },
      ),
      child: DefaultTextStyle.merge(
        textAlign: switch (phone) {
          true => TextAlign.center,
          false => TextAlign.start,
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: switch (phone) {
            true => CrossAxisAlignment.center,
            false => CrossAxisAlignment.start,
          },
          spacing: Spacing.d8,
          children: children,
        ),
      ),
    );
  }
}
