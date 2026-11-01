import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';
import 'package:looseleaf_ui/src/components/drawer/drawer.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A drawer's [DrawerTitle] and [DrawerDescription] with 16 px around
/// them (24 above in a bottom drawer, clear of the tape): centred and
/// 2 px apart in top and bottom drawers under 768 px, at the start and
/// 6 px apart otherwise.
///
/// Mirrors `DrawerHeader` in upstream `src/components/ui/drawer.tsx`.
class DrawerHeader extends StatelessWidget {
  const DrawerHeader({super.key, required this.children});

  /// The title and description.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final direction = DrawerScope.directionOf(context);
    final wide =
        (MediaQuery.maybeSizeOf(context)?.width ?? 0) >=
        DialogMetrics.tabletBreakpoint;
    final centred = direction.vertical && !wide;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.d16,
        switch (direction) {
          OverlaySide.bottom => Spacing.d24,
          _ => Spacing.d16,
        },
        Spacing.d16,
        Spacing.d16,
      ),
      child: DefaultTextStyle.merge(
        textAlign: switch (centred) {
          true => TextAlign.center,
          false => TextAlign.start,
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: switch (centred) {
            true => CrossAxisAlignment.center,
            false => CrossAxisAlignment.start,
          },
          spacing: switch (wide) {
            true => Spacing.d6,
            false => Spacing.d2,
          },
          children: children,
        ),
      ),
    );
  }
}
