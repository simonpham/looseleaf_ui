import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The notebook's pad: three links and a Settings row that opens the
/// settings dialog.
///
/// Mirrors upstream `src/blocks/sidebar-13/components/sidebar-13-app-sidebar.tsx`.
class Sidebar13AppSidebar extends StatelessWidget {
  const Sidebar13AppSidebar({super.key, required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  static const _links = [
    AppNavItem('Notes', icon: 'file-text', isActive: true),
    AppNavItem('Calendar', icon: 'calendar'),
    AppNavItem('Inbox', icon: 'inbox'),
  ];

  @override
  Widget build(BuildContext context) => Sidebar(
    seed: 'sidebar-13',
    rail: const SidebarRail(),
    children: [
      const SidebarHeader(
        children: [
          SidebarBrand(
            title: 'Looseleaf Studio',
            subtitle: 'Notebook',
            icon: 'book-open',
          ),
        ],
      ),
      SidebarContent(
        children: [
          SidebarGroup(
            children: [
              SidebarMenu(
                children: [
                  for (final item in _links)
                    SidebarMenuItem(
                      child: SidebarMenuButton(
                        isActive: item.isActive,
                        onPressed: () {},
                        leading: InkIcon(item.icon),
                        child: Text(item.title),
                      ),
                    ),
                  SidebarMenuItem(
                    child: SidebarMenuButton(
                      onPressed: onOpenSettings,
                      leading: const InkIcon('settings'),
                      child: const Text('Settings'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
