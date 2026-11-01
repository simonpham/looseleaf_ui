import 'package:flutter/widgets.dart';

/// One sub-row of a [SidebarMenuSub], holding a [SidebarMenuSubButton].
///
/// Mirrors `SidebarMenuSubItem` in upstream `src/components/ui/sidebar.tsx`.
class SidebarMenuSubItem extends StatelessWidget {
  const SidebarMenuSubItem({super.key, required this.child});

  /// The sub-row's button.
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
