import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The field guide's pad: an edition switcher and a search box on top,
/// then every section's pages as plain rows.
///
/// Mirrors upstream `src/blocks/sidebar-01/components/sidebar-01-app-sidebar.tsx`.
class Sidebar01AppSidebar extends StatelessWidget {
  const Sidebar01AppSidebar({super.key});

  @override
  Widget build(BuildContext context) => Sidebar(
    seed: 'sidebar-01',
    rail: const SidebarRail(),
    children: [
      SidebarHeader(
        children: [
          VersionSwitcher(
            versions: docsVersions,
            defaultVersion: docsVersions.first,
          ),
          const SearchForm(),
        ],
      ),
      SidebarContent(
        children: [
          for (final section in docsNav)
            SidebarGroup(
              children: [
                SidebarGroupLabel(child: Text(section.title)),
                SidebarGroupContent(
                  child: SidebarMenu(
                    children: [
                      for (final item in section.items)
                        SidebarMenuItem(
                          child: SidebarMenuButton(
                            isActive: item.isActive,
                            onPressed: () {},
                            child: Text(item.title),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    ],
  );
}
