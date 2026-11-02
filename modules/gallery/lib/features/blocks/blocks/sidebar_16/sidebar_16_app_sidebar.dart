import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The studio's pad under the site header: the studio's name, sections
/// that fold from a chevron, projects, help links and the account.
///
/// Mirrors upstream `src/blocks/sidebar-16/components/sidebar-16-app-sidebar.tsx`.
class Sidebar16AppSidebar extends StatelessWidget {
  const Sidebar16AppSidebar({super.key});

  @override
  Widget build(BuildContext context) => const Sidebar(
    seed: 'sidebar-16',
    children: [
      SidebarHeader(
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
          NavMainFolds(items: appNav),
          NavProjects(projects: appProjects),
        ],
      ),
      NavSecondary(items: appSecondary, small: true),
      SidebarFooter(children: [NavUser(user: appUser)]),
    ],
  );
}
