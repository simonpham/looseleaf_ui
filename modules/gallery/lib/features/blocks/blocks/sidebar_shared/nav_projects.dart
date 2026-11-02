import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The "Projects" group: a row per project with a menu of actions, and a
/// "More" row. Hidden when collapsed to icons.
///
/// Mirrors `NavProjects` in upstream
/// `src/blocks/sidebar-shared/sidebar-nav-app.tsx`.
class NavProjects extends StatelessWidget {
  const NavProjects({super.key, required this.projects});

  final List<Project> projects;

  static const double _menuWidth = 192;

  @override
  Widget build(BuildContext context) {
    if (SidebarPanelScope.iconsOf(context)) return const SizedBox.shrink();
    return SidebarGroup(
      children: [
        const SidebarGroupLabel(child: Text('Projects')),
        SidebarMenu(
          children: [
            for (final project in projects)
              SidebarMenuItem(
                action: NavRowActions(
                  name: project.name,
                  width: _menuWidth,
                  items: const [
                    DropdownMenuItem(
                      leading: InkIcon('folder'),
                      child: Text('View project'),
                    ),
                    DropdownMenuItem(
                      leading: InkIcon('share'),
                      child: Text('Share project'),
                    ),
                    DropdownMenuSeparator(),
                    DropdownMenuItem(
                      variant: InkMenuItemVariant.destructive,
                      leading: InkIcon('trash'),
                      child: Text('Delete project'),
                    ),
                  ],
                ),
                child: SidebarMenuButton(
                  leading: InkIcon(project.icon),
                  onPressed: () {},
                  child: Text(project.name),
                ),
              ),
            const NavMoreRow(),
          ],
        ),
      ],
    );
  }
}
