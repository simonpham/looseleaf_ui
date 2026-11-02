import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/sidebar/sidebar.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SidebarMenuSubExample extends StatelessWidget {
  const SidebarMenuSubExample({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 420,
    child: SidebarProvider(
      children: [
        Sidebar(
          seed: 'official-menu-sub',
          children: [
            SidebarContent(
              children: [
                SidebarGroup(
                  children: [
                    SidebarGroupContent(
                      child: SidebarMenu(
                        children: [
                          for (final item in sidebarDocsToc)
                            SidebarMenuItem(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                spacing: Spacing.d4,
                                children: [
                                  SidebarMenuButton(
                                    onPressed: () {},
                                    child: Text(item.title),
                                  ),
                                  SidebarMenuSub(
                                    children: [
                                      for (final subItem in item.items)
                                        SidebarMenuSubItem(
                                          child: SidebarMenuSubButton(
                                            isActive:
                                                subItem == sidebarDocsActive,
                                            onPressed: () {},
                                            child: Text(subItem),
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
        ),
        const SidebarInset(child: SizedBox.shrink()),
      ],
    ),
  );
}
