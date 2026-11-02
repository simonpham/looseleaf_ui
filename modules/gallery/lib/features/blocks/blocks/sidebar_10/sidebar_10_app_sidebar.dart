import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The notes pad: a small team switcher and the main links on top, then
/// favorites, workspaces that fold open, and the everyday links at its
/// foot.
///
/// Mirrors upstream `src/blocks/sidebar-10/components/sidebar-10-app-sidebar.tsx`.
class Sidebar10AppSidebar extends StatelessWidget {
  const Sidebar10AppSidebar({super.key});

  @override
  Widget build(BuildContext context) => const Sidebar(
    seed: 'sidebar-10',
    rail: SidebarRail(),
    children: [
      SidebarHeader(
        children: [
          TeamSwitcher(teams: appTeams, compact: true),
          NavLinks(items: notesNav),
        ],
      ),
      SidebarContent(
        children: [
          NavFavorites(favorites: notesFavorites),
          NavWorkspaces(workspaces: notesWorkspaces),
        ],
      ),
      NavSecondary(items: notesSecondary),
    ],
  );
}
