import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The field guide's pad with an edition switcher and a search box on top;
/// each section's heading folds its pages open and shut.
///
/// Mirrors upstream `src/blocks/sidebar-02/components/sidebar-02-app-sidebar.tsx`.
class Sidebar02AppSidebar extends StatelessWidget {
  const Sidebar02AppSidebar({super.key});

  @override
  Widget build(BuildContext context) => Sidebar(
    seed: 'sidebar-02',
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
            Collapsible(
              defaultOpen: true,
              child: SidebarGroup(
                children: [
                  GroupFoldLabel(title: section.title),
                  CollapsibleContent(
                    child: SidebarGroupContent(
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
                  ),
                ],
              ),
            ),
        ],
      ),
    ],
  );
}
