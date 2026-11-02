import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The "Favorites" group: a row per page with a menu of actions, and a
/// "More" row. Hidden when collapsed to icons.
///
/// Mirrors `NavFavorites` in upstream
/// `src/blocks/sidebar-shared/sidebar-nav-notes.tsx`.
class NavFavorites extends StatelessWidget {
  const NavFavorites({super.key, required this.favorites});

  final List<NotesPage> favorites;

  static const double _menuWidth = 224;

  @override
  Widget build(BuildContext context) {
    if (SidebarPanelScope.iconsOf(context)) return const SizedBox.shrink();
    return SidebarGroup(
      children: [
        const SidebarGroupLabel(child: Text('Favorites')),
        SidebarMenu(
          children: [
            for (final page in favorites)
              SidebarMenuItem(
                action: NavRowActions(
                  name: page.name,
                  width: _menuWidth,
                  items: const [
                    DropdownMenuItem(
                      leading: InkIcon('star'),
                      child: Text('Remove from favorites'),
                    ),
                    DropdownMenuSeparator(),
                    DropdownMenuItem(
                      leading: InkIcon('link'),
                      child: Text('Copy link'),
                    ),
                    DropdownMenuItem(
                      leading: InkIcon('arrow-up-right'),
                      child: Text('Open in new tab'),
                    ),
                    DropdownMenuSeparator(),
                    DropdownMenuItem(
                      variant: InkMenuItemVariant.destructive,
                      leading: InkIcon('trash'),
                      child: Text('Delete'),
                    ),
                  ],
                ),
                child: SidebarMenuButton(
                  leading: InkIcon(page.icon),
                  onPressed: () {},
                  child: Text(page.name),
                ),
              ),
            const NavMoreRow(),
          ],
        ),
      ],
    );
  }
}
