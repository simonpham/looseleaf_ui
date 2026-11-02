import 'dart:ui' show SemanticsRole;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/tabs/tabs_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The row of [TabsTrigger]s of a [Tabs]: folder tabs on a pencil
/// baseline, or a line under the active one ([TabsVariant.line]). One Tab
/// stop; the arrows (mirrored right to left), Home and End move between
/// the tabs. A row wider than its parent scrolls sideways, unless its
/// triggers are [Expanded] to share its width (upstream `flex-1`).
///
/// Mirrors `TabsList` in upstream `src/components/ui/tabs.tsx`.
class TabsList extends StatelessWidget {
  const TabsList({
    super.key,
    required this.children,
    this.variant = TabsVariant.folder,
  });

  final List<Widget> children;
  final TabsVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final vertical =
        TabsScope.maybeOf(context)?.orientation == TabsOrientation.vertical;
    final row = InkRovingFocus(
      axis: switch (vertical) {
        true => Axis.vertical,
        false => Axis.horizontal,
      },
      child: Semantics(
        container: true,
        role: SemanticsRole.tabBar,
        child: DefaultTextStyle.merge(
          style: TextStyle(color: theme.colors.inkMuted),
          child: switch (vertical) {
            true => IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d4,
                children: children,
              ),
            ),
            false => SizedBox(
              height: Spacing.d40,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: Spacing.d4,
                children: children,
              ),
            ),
          },
        ),
      ),
    );
    final stretches = children.any((child) => child is Flexible);
    return TabsListScope(
      variant: variant,
      child: switch (vertical || stretches) {
        true => row,
        false => InkOverflowScroll(child: row),
      },
    );
  }
}
