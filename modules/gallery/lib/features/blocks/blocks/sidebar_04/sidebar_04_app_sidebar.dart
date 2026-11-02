import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The field guide's pad set down on the desk, as an outline: each
/// section in bold with its pages indented under it.
///
/// Mirrors upstream `src/blocks/sidebar-04/components/sidebar-04-app-sidebar.tsx`.
class Sidebar04AppSidebar extends StatelessWidget {
  const Sidebar04AppSidebar({super.key});

  @override
  Widget build(BuildContext context) => Sidebar(
    variant: SidebarVariant.floating,
    seed: 'sidebar-04',
    children: [
      const SidebarHeader(
        children: [
          SidebarBrand(
            title: 'Field guide',
            subtitle: 'v1.0.0',
            icon: 'book-open',
          ),
        ],
      ),
      SidebarContent(
        children: [
          SidebarGroup(
            children: [
              SidebarMenu(
                gap: Spacing.d8,
                children: [
                  for (final section in docsNav)
                    SidebarMenuItem(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: Spacing.d4,
                        children: [
                          SidebarMenuButton(
                            onPressed: () {},
                            child: Text(
                              section.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (section.items.isNotEmpty)
                            SidebarMenuSub(
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
                        ],
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
