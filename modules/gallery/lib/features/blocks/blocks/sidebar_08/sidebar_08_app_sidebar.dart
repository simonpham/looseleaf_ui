import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The studio's inset pad: the studio's name on top, sections that fold
/// from a chevron, projects, help links and the account at its foot.
///
/// Mirrors upstream `src/blocks/sidebar-08/components/sidebar-08-app-sidebar.tsx`.
class Sidebar08AppSidebar extends StatelessWidget {
  const Sidebar08AppSidebar({super.key});

  @override
  Widget build(BuildContext context) => const Sidebar(
    variant: SidebarVariant.inset,
    seed: 'sidebar-08',
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
