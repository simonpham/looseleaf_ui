import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The studio's sections under a [label]: each row folds its pages open
/// and shut, with [current] marked among them.
///
/// Mirrors upstream `src/blocks/sidebar-07/components/sidebar-07-nav-main.tsx`.
class Sidebar07NavMain extends StatelessWidget {
  const Sidebar07NavMain({
    super.key,
    required this.items,
    required this.current,
    this.label = 'Studio',
  });

  final List<AppNavItem> items;

  /// The page being read.
  final String current;
  final String label;

  @override
  Widget build(BuildContext context) => SidebarGroup(
    children: [
      SidebarGroupLabel(child: Text(label)),
      SidebarMenu(
        children: [
          for (final item in items)
            SidebarMenuItem(
              child: Collapsible(
                defaultOpen: item.isActive,
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
                            tooltip: item.title,
                            onPressed: fold.toggle,
                            leading: InkIcon(item.icon),
                            trailing: const CollapsibleIndicator(),
                            child: Text(item.title),
                          ),
                        ),
                        CollapsibleContent(
                          child: SidebarMenuSub(
                            children: [
                              for (final page in item.items)
                                SidebarMenuSubItem(
                                  child: SidebarMenuSubButton(
                                    isActive: page == current,
                                    onPressed: () {},
                                    child: Text(page),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    ],
  );
}
