import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A table of contents on a pad hung on the right: the page's headings in
/// bold, their subheadings under them.
///
/// Mirrors upstream `src/blocks/sidebar-14/components/sidebar-14-app-sidebar.tsx`.
class Sidebar14AppSidebar extends StatelessWidget {
  const Sidebar14AppSidebar({super.key});

  @override
  Widget build(BuildContext context) => Sidebar(
    side: SidebarSide.right,
    seed: 'sidebar-14',
    rail: const SidebarRail(),
    children: [
      SidebarContent(
        children: [
          SidebarGroup(
            children: [
              const SidebarGroupLabel(child: Text('Table of contents')),
              SidebarGroupContent(
                child: SidebarMenu(
                  children: [
                    for (final heading in pageOutline)
                      SidebarMenuItem(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: Spacing.d4,
                          children: [
                            SidebarMenuButton(
                              onPressed: () {},
                              child: Text(
                                heading.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (heading.items.isNotEmpty)
                              SidebarMenuSub(
                                children: [
                                  for (final item in heading.items)
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
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
