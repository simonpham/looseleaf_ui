import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The "Workspaces" group: each workspace folds its pages open from a
/// chevron that covers its icon on hover, with a plus at the end to add a
/// page, and a "More" row. Hidden when collapsed to icons.
///
/// Mirrors `NavWorkspaces` in upstream
/// `src/blocks/sidebar-shared/sidebar-nav-notes.tsx`.
class NavWorkspaces extends StatelessWidget {
  const NavWorkspaces({super.key, required this.workspaces});

  final List<NotesWorkspace> workspaces;

  @override
  Widget build(BuildContext context) {
    if (SidebarPanelScope.iconsOf(context)) return const SizedBox.shrink();
    return SidebarGroup(
      children: [
        const SidebarGroupLabel(child: Text('Workspaces')),
        SidebarGroupContent(
          child: SidebarMenu(
            children: [
              for (final workspace in workspaces)
                Collapsible(
                  child: Builder(
                    builder: (context) => SidebarMenuItem(
                      leadingAction: SidebarMenuAction(
                        showOnHover: true,
                        fill: true,
                        semanticLabel: 'Show pages in ${workspace.name}',
                        onPressed: Collapsible.of(context).toggle,
                        child: const FoldChevron(),
                      ),
                      action: SidebarMenuAction(
                        showOnHover: true,
                        semanticLabel: 'Add a page to ${workspace.name}',
                        onPressed: () {},
                        child: const InkIcon('plus'),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: Spacing.d4,
                        children: [
                          SidebarMenuButton(
                            leading: InkIcon(workspace.icon),
                            onPressed: () {},
                            child: Text(workspace.name),
                          ),
                          CollapsibleContent(
                            child: SidebarMenuSub(
                              children: [
                                for (final page in workspace.pages)
                                  SidebarMenuSubItem(
                                    child: SidebarMenuSubButton(
                                      leading: InkIcon(page.icon),
                                      onPressed: () {},
                                      child: Text(page.name),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const NavMoreRow(),
            ],
          ),
        ),
      ],
    );
  }
}
