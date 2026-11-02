import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The app's sections under a [label]: each row a link, with a chevron at
/// its end that folds its pages open and shut.
///
/// Mirrors `NavMainFolds` in upstream
/// `src/blocks/sidebar-shared/sidebar-nav-app.tsx`.
class NavMainFolds extends StatelessWidget {
  const NavMainFolds({super.key, required this.items, this.label = 'Studio'});

  final List<AppNavItem> items;
  final String label;

  @override
  Widget build(BuildContext context) => SidebarGroup(
    children: [
      SidebarGroupLabel(child: Text(label)),
      SidebarMenu(
        children: [
          for (final item in items)
            Collapsible(
              defaultOpen: item.isActive,
              child: Builder(
                builder: (context) => SidebarMenuItem(
                  action: switch (item.items.isEmpty) {
                    true => null,
                    false => SidebarMenuAction(
                      semanticLabel: 'Show pages in ${item.title}',
                      onPressed: Collapsible.of(context).toggle,
                      child: const FoldChevron(),
                    ),
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: Spacing.d4,
                    children: [
                      SidebarMenuButton(
                        tooltip: item.title,
                        isActive: item.isActive,
                        leading: InkIcon(item.icon),
                        onPressed: () {},
                        child: Text(item.title),
                      ),
                      if (item.items.isNotEmpty)
                        CollapsibleContent(
                          child: SidebarMenuSub(
                            children: [
                              for (final page in item.items)
                                SidebarMenuSubItem(
                                  child: SidebarMenuSubButton(
                                    onPressed: () {},
                                    child: Text(page),
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
        ],
      ),
    ],
  );
}
