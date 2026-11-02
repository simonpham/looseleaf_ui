import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Rows of links with icons, the current one marked, and optional counts.
///
/// Mirrors `NavLinks` in upstream
/// `src/blocks/sidebar-shared/sidebar-nav-notes.tsx`.
class NavLinks extends StatelessWidget {
  const NavLinks({super.key, required this.items});

  final List<AppNavItem> items;

  @override
  Widget build(BuildContext context) => SidebarMenu(
    children: [
      for (final item in items)
        SidebarMenuItem(
          badge: switch (item.badge) {
            final badge? => SidebarMenuBadge(child: Text(badge)),
            null => null,
          },
          child: SidebarMenuButton(
            isActive: item.isActive,
            leading: InkIcon(item.icon),
            onPressed: () {},
            child: Text(item.title),
          ),
        ),
    ],
  );
}
