import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A sheet's [SheetTitle] and [SheetDescription], 6 px apart, with 16 px
/// around them (48 px at the end, clear of the close mark).
///
/// Mirrors `SheetHeader` in upstream `src/components/ui/sheet.tsx`.
class SheetHeader extends StatelessWidget {
  const SheetHeader({super.key, required this.children});

  /// The title and description.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final clear = DialogContentScope.maybeOf(context)?.closeMark ?? false;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        Spacing.d16,
        Spacing.d16,
        switch (clear) {
          true => Spacing.d48,
          false => Spacing.d16,
        },
        Spacing.d16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d6,
        children: children,
      ),
    );
  }
}
