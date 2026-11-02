import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The signed-in [user] at the foot of the pad; it drops the account
/// menu. [iconOnly] shows just the avatar, for a strip collapsed to icons.
///
/// Mirrors `NavUser` in upstream
/// `src/blocks/sidebar-shared/sidebar-user-menu.tsx`.
class NavUser extends StatelessWidget {
  const NavUser({
    super.key,
    required this.user,
    this.align = OverlayAlign.end,
    this.iconOnly = false,
  });

  final Person user;

  /// How the menu lines up with the row.
  final OverlayAlign align;
  final bool iconOnly;

  static const double _menuMinWidth = 224;

  Widget _button(DropdownMenuController menu) {
    if (iconOnly) {
      return SidebarMenuButton(
        size: SidebarMenuButtonSize.lg,
        tooltip: user.name,
        semanticLabel: user.name,
        onPressed: menu.toggle,
        forcedStates: {if (menu.open) InkState.hovered},
        leading: UserFace(user: user),
        child: const SizedBox.shrink(),
      );
    }
    return SidebarMenuButton(
      size: SidebarMenuButtonSize.lg,
      tooltip: user.name,
      onPressed: menu.toggle,
      forcedStates: {if (menu.open) InkState.hovered},
      leading: UserFace(user: user),
      trailing: const InkIcon('chevrons-up-down'),
      child: UserLines(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = SidebarProvider.maybeOf(context)?.isMobile ?? false;
    return SidebarMenu(
      children: [
        SidebarMenuItem(
          child: LayoutBuilder(
            builder: (context, constraints) => DropdownMenu(
              content: DropdownMenuContent(
                minWidth: constraints.maxWidth.clamp(
                  _menuMinWidth,
                  double.infinity,
                ),
                side: switch (isMobile) {
                  true => OverlaySide.bottom,
                  false => OverlaySide.right,
                },
                align: align,
                sideOffset: Spacing.d4,
                children: [
                  DropdownMenuLabel(
                    child: Row(
                      spacing: Spacing.d8,
                      children: [
                        UserFace(user: user),
                        Expanded(child: UserLines(user: user)),
                      ],
                    ),
                  ),
                  const DropdownMenuSeparator(),
                  const DropdownMenuGroup(
                    children: [
                      DropdownMenuItem(
                        leading: InkIcon('sparkles'),
                        child: Text('Upgrade to Studio'),
                      ),
                    ],
                  ),
                  const DropdownMenuSeparator(),
                  const DropdownMenuGroup(
                    children: [
                      DropdownMenuItem(
                        leading: InkIcon('badge-check'),
                        child: Text('Account'),
                      ),
                      DropdownMenuItem(
                        leading: InkIcon('credit-card'),
                        child: Text('Billing'),
                      ),
                      DropdownMenuItem(
                        leading: InkIcon('bell'),
                        child: Text('Notifications'),
                      ),
                    ],
                  ),
                  const DropdownMenuSeparator(),
                  const DropdownMenuItem(
                    leading: InkIcon('log-out'),
                    child: Text('Log out'),
                  ),
                ],
              ),
              child: DropdownMenuTrigger.builder(
                builder: (context, menu) => _button(menu),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
