import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_11/sidebar_11.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The files pad: the changed files with their git letters, then the
/// project's tree, folders folding open.
///
/// Mirrors upstream `src/blocks/sidebar-11/components/sidebar-11-app-sidebar.tsx`.
class Sidebar11AppSidebar extends StatelessWidget {
  const Sidebar11AppSidebar({
    super.key,
    required this.active,
    required this.onPick,
  });

  /// The open file's path.
  final String active;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) => Sidebar(
    seed: 'sidebar-11',
    rail: const SidebarRail(),
    children: [
      SidebarContent(
        children: [
          SidebarGroup(
            children: [
              const SidebarGroupLabel(child: Text('Changes')),
              SidebarGroupContent(
                child: SidebarMenu(
                  children: [
                    for (final change in fileChanges)
                      SidebarMenuItem(
                        badge: SidebarMenuBadge(
                          child: Semantics(
                            label: change.stateName,
                            child: ExcludeSemantics(child: Text(change.state)),
                          ),
                        ),
                        child: SidebarMenuButton(
                          isActive: active == change.file,
                          onPressed: () => onPick(change.file),
                          leading: InkIcon(
                            Sidebar11FileTree.fileIcon(change.file),
                          ),
                          child: Text(change.file),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SidebarGroup(
            children: [
              const SidebarGroupLabel(child: Text('Files')),
              SidebarGroupContent(
                child: SidebarMenu(
                  children: [
                    for (final node in fileTree)
                      Sidebar11FileTree(
                        node: node,
                        parent: '',
                        active: active,
                        onPick: onPick,
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
