import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Each section as a row that drops a menu of its pages, the page being
/// read in bold with a check; the section holding it is marked.
///
/// Mirrors upstream `src/blocks/sidebar-06/components/sidebar-06-nav-main.tsx`.
class Sidebar06NavMain extends StatelessWidget {
  const Sidebar06NavMain({super.key, required this.items});

  final List<NavSection> items;

  static const double _menuMinWidth = 224;

  @override
  Widget build(BuildContext context) {
    final isMobile = SidebarProvider.maybeOf(context)?.isMobile ?? false;
    return SidebarGroup(
      children: [
        SidebarMenu(
          children: [
            for (final section in items)
              SidebarMenuItem(
                child: DropdownMenu(
                  content: DropdownMenuContent(
                    minWidth: _menuMinWidth,
                    side: switch (isMobile) {
                      true => OverlaySide.bottom,
                      false => OverlaySide.right,
                    },
                    align: switch (isMobile) {
                      true => OverlayAlign.end,
                      false => OverlayAlign.start,
                    },
                    children: [
                      for (final item in section.items)
                        DropdownMenuItem(
                          onSelect: () {},
                          trailing: switch (item.isActive) {
                            true => const InkIcon('check'),
                            false => null,
                          },
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: switch (item.isActive) {
                                true => FontWeight.w700,
                                false => FontWeight.w400,
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                  child: DropdownMenuTrigger.builder(
                    builder: (context, menu) => SidebarMenuButton(
                      isActive: section.items.any((item) => item.isActive),
                      onPressed: menu.toggle,
                      forcedStates: {if (menu.open) InkState.hovered},
                      trailing: const InkIcon('ellipsis'),
                      child: Text(section.title),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
