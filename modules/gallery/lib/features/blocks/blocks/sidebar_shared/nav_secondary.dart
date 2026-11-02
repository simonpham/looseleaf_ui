import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A plain group of links with icons and optional counts, usually set at
/// the foot of the pad; [small] makes the rows 28 px.
///
/// Upstream pushes it down inside the scrolling content with `mt-auto`;
/// here it goes between the [SidebarContent] and the [SidebarFooter].
///
/// Mirrors `NavSecondary` in upstream
/// `src/blocks/sidebar-shared/sidebar-nav-app.tsx`.
class NavSecondary extends StatelessWidget {
  const NavSecondary({super.key, required this.items, this.small = false});

  final List<AppNavItem> items;
  final bool small;

  @override
  Widget build(BuildContext context) => SidebarGroup(
    children: [
      SidebarGroupContent(
        child: SidebarMenu(
          children: [
            for (final item in items)
              SidebarMenuItem(
                badge: switch (item.badge) {
                  final badge? => SidebarMenuBadge(child: Text(badge)),
                  null => null,
                },
                child: SidebarMenuButton(
                  size: switch (small) {
                    true => SidebarMenuButtonSize.sm,
                    false => SidebarMenuButtonSize.regular,
                  },
                  tooltip: item.title,
                  leading: InkIcon(item.icon),
                  onPressed: () {},
                  child: Text(item.title),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}
