import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_07/sidebar_07.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The studio's pad that collapses to icons: a team switcher on top, the
/// sections and projects, and the account at its foot.
///
/// Mirrors upstream `src/blocks/sidebar-07/components/sidebar-07-app-sidebar.tsx`.
class Sidebar07AppSidebar extends StatelessWidget {
  const Sidebar07AppSidebar({super.key});

  @override
  Widget build(BuildContext context) => const Sidebar(
    collapsible: SidebarCollapsible.icon,
    seed: 'sidebar-07',
    rail: SidebarRail(),
    children: [
      SidebarHeader(children: [TeamSwitcher(teams: appTeams)]),
      SidebarContent(
        children: [
          Sidebar07NavMain(items: appNav, current: 'Recent'),
          NavProjects(projects: appProjects),
        ],
      ),
      SidebarFooter(children: [NavUser(user: appUser)]),
    ],
  );
}
