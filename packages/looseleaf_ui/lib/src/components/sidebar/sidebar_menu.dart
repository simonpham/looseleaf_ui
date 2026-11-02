import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The list of rows: [SidebarMenuItem]s [gap] apart. Each row knows its
/// place, so the pad's ruling under odd and even rows varies like a
/// printed pad.
///
/// Mirrors `SidebarMenu` in upstream `src/components/ui/sidebar.tsx`.
class SidebarMenu extends StatelessWidget {
  const SidebarMenu({
    super.key,
    required this.children,
    this.gap = Spacing.d4,
  });

  /// The rows.
  final List<Widget> children;

  /// The space between rows, 4 px like upstream's `gap-1`.
  final double gap;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: gap,
    children: [
      for (final (index, child) in children.indexed)
        SidebarMenuItemIndex(index: index, child: child),
    ],
  );
}
