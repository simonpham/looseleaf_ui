import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The list of rows: [SidebarMenuItem]s 4 px apart. Each row knows its
/// place, so the pad's ruling under odd and even rows varies like a
/// printed pad.
///
/// Mirrors `SidebarMenu` in upstream `src/components/ui/sidebar.tsx`.
class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key, required this.children});

  /// The rows.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: Spacing.d4,
    children: [
      for (final (index, child) in children.indexed)
        SidebarMenuItemIndex(index: index, child: child),
    ],
  );
}
