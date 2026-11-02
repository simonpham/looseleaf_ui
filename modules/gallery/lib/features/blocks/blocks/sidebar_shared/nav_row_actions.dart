import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// An ellipsis at the end of a row, shown on hover, that drops a menu of
/// [items]: to the right of the pad, or below it on a phone.
///
/// Mirrors the `SidebarMenuAction` menus in upstream
/// `src/blocks/sidebar-shared/sidebar-nav-app.tsx`.
class NavRowActions extends StatelessWidget {
  const NavRowActions({
    super.key,
    required this.name,
    required this.width,
    required this.items,
  });

  /// The row's title, for the button's name.
  final String name;

  /// The menu's width.
  final double width;

  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    final isMobile = SidebarProvider.maybeOf(context)?.isMobile ?? false;
    return DropdownMenu(
      content: DropdownMenuContent(
        width: width,
        side: switch (isMobile) {
          true => OverlaySide.bottom,
          false => OverlaySide.right,
        },
        align: switch (isMobile) {
          true => OverlayAlign.end,
          false => OverlayAlign.start,
        },
        children: items,
      ),
      child: DropdownMenuTrigger.builder(
        builder: (context, menu) => SidebarMenuAction(
          showOnHover: true,
          semanticLabel: 'Actions for $name',
          onPressed: menu.toggle,
          forcedStates: {if (menu.open) InkState.hovered},
          child: const InkIcon('ellipsis'),
        ),
      ),
    );
  }
}
