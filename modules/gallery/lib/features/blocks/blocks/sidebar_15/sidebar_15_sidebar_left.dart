import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The notes pad on the left: a small team switcher and the main links on
/// top, then favorites, workspaces and the everyday links.
///
/// Mirrors upstream `src/blocks/sidebar-15/components/sidebar-15-sidebar-left.tsx`.
class Sidebar15SidebarLeft extends StatelessWidget {
  const Sidebar15SidebarLeft({super.key});

  @override
  Widget build(BuildContext context) => const Sidebar(
    seed: 'sidebar-15-left',
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
