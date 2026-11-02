import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The field guide's pad with a search box; each section is a row that
/// opens its pages with a plus and shuts them with a minus. Only the
/// second section starts open.
///
/// Mirrors upstream `src/blocks/sidebar-05/components/sidebar-05-app-sidebar.tsx`.
class Sidebar05AppSidebar extends StatelessWidget {
  const Sidebar05AppSidebar({super.key});

  @override
  Widget build(BuildContext context) => Sidebar(
    seed: 'sidebar-05',
    rail: const SidebarRail(),
    children: [
      const SidebarHeader(
        children: [
          SidebarBrand(
            title: 'Field guide',
            subtitle: 'v1.0.0',
            icon: 'book-open',
          ),
          SearchForm(),
        ],
      ),
      SidebarContent(
        children: [
          SidebarGroup(
            children: [
              SidebarMenu(
                children: [
                  for (final (index, section) in docsNav.indexed)
                    SidebarMenuItem(
                      child: Collapsible(
                        defaultOpen: index == 1,
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
                                    trailing: InkIcon(switch (fold.open) {
                                      true => 'minus',
                                      false => 'plus',
                                    }),
                                    child: Text(section.title),
                                  ),
                                ),
                                if (section.items.isNotEmpty)
                                  CollapsibleContent(
                                    child: SidebarMenuSub(
                                      children: [
                                        for (final item in section.items)
                                          SidebarMenuSubItem(
                                            child: SidebarMenuSubButton(
                                              isActive: item.isActive,
                                              onPressed: () {},
                                              child: Text(item.title),
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
          ),
        ],
      ),
    ],
  );
}
