import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// One [node] of the file tree under [parent]: a file is a row you can
/// open; a folder folds its children open under a chevron.
///
/// Mirrors `Tree` in upstream
/// `src/blocks/sidebar-11/components/sidebar-11-app-sidebar.tsx`.
class Sidebar11FileTree extends StatelessWidget {
  const Sidebar11FileTree({
    super.key,
    required this.node,
    required this.parent,
    required this.active,
    required this.onPick,
  });

  final FileNode node;
  final String parent;

  /// The open file's path.
  final String active;
  final ValueChanged<String> onPick;

  static const _openByDefault = {'components', 'components/ui'};

  /// The icon for a file [name].
  static String fileIcon(String name) {
    if (RegExp(r'\.(tsx?|jsx?|json)$').hasMatch(name) || name.startsWith('.')) {
      return 'file-code';
    }
    if (RegExp(r'\.(md|txt)$').hasMatch(name)) return 'file-text';
    return 'file';
  }

  @override
  Widget build(BuildContext context) {
    final path = switch (parent.isEmpty) {
      true => node.name,
      false => '$parent/${node.name}',
    };
    final children = node.children;
    if (children == null) {
      return SidebarMenuItem(
        child: SidebarMenuButton(
          isActive: active == path,
          onPressed: () => onPick(path),
          leading: InkIcon(fileIcon(node.name)),
          child: Text(node.name),
        ),
      );
    }
    return SidebarMenuItem(
      child: Collapsible(
        defaultOpen: _openByDefault.contains(path),
        child: Builder(
          builder: (context) {
            final fold = Collapsible.of(context);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d4,
              children: [
                Semantics(
                  expanded: fold.open,
                  child: SidebarMenuButton(
                    onPressed: fold.toggle,
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: Spacing.d8,
                      children: [
                        const FoldChevron(),
                        InkIcon(switch (fold.open) {
                          true => 'folder-open',
                          false => 'folder',
                        }),
                      ],
                    ),
                    child: Text(node.name),
                  ),
                ),
                CollapsibleContent(
                  child: SidebarMenuSub(
                    children: [
                      for (final child in children)
                        Sidebar11FileTree(
                          node: child,
                          parent: path,
                          active: active,
                          onPick: onPick,
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
