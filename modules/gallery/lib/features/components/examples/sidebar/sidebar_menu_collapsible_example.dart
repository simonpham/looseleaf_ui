import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/sidebar/sidebar.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SidebarMenuCollapsibleExample extends StatelessWidget {
  const SidebarMenuCollapsibleExample({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 420,
    child: SidebarProvider(
      children: [
        Sidebar(
          seed: 'official-menu-collapsible',
          children: [
            SidebarContent(
              children: [
                SidebarGroup(
                  children: [
                    SidebarGroupContent(
                      child: SidebarMenu(
                        children: [
                          for (final (index, item) in sidebarDocsToc.indexed)
                            SidebarMenuItem(
                              child: Collapsible(
                                defaultOpen: index == 0,
                                child: _Section(
                                  title: item.title,
                                  items: item.items,
                                ),
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final collapsible = Collapsible.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d4,
      children: [
        Semantics(
          expanded: collapsible.open,
          child: SidebarMenuButton(
            onPressed: collapsible.toggle,
            trailing: AnimatedRotation(
              turns: switch (collapsible.open) {
                true => 0.25,
                false => 0,
              },
              duration: InkMotion.of(context, InkMotion.hover),
              child: const InkIcon('chevron-right'),
            ),
            child: Text(title),
          ),
        ),
        CollapsibleContent(
          child: SidebarMenuSub(
            children: [
              for (final subItem in items)
                SidebarMenuSubItem(
                  child: SidebarMenuSubButton(
                    isActive: subItem == sidebarDocsActive,
                    onPressed: () {},
                    child: Text(subItem),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
