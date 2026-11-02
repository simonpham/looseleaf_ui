import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/dashboard_01/dashboard_01.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The signed-in person at the foot of the pad; it drops the account menu.
///
/// Mirrors `NavUser` in upstream
/// `src/blocks/dashboard-01/components/dashboard-01-app-sidebar.tsx`.
class Dashboard01NavUser extends StatelessWidget {
  const Dashboard01NavUser({super.key});

  static const double _menuMinWidth = 224;

  @override
  Widget build(BuildContext context) {
    final isMobile = SidebarProvider.maybeOf(context)?.isMobile ?? false;
    return SidebarMenu(
      children: [
        SidebarMenuItem(
          child: DropdownMenu(
            content: DropdownMenuContent(
              minWidth: _menuMinWidth,
              side: switch (isMobile) {
                true => OverlaySide.bottom,
                false => OverlaySide.right,
              },
              align: OverlayAlign.end,
              sideOffset: Spacing.d4,
              children: const [
                DropdownMenuLabel(child: Text(dashboard01UserEmail)),
                DropdownMenuGroup(
                  children: [
                    DropdownMenuItem(
                      leading: InkIcon('circle-user'),
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
                DropdownMenuSeparator(),
                DropdownMenuItem(
                  leading: InkIcon('log-out'),
                  child: Text('Log out'),
                ),
              ],
            ),
            child: DropdownMenuTrigger.builder(
              builder: (context, menu) => SidebarMenuButton(
                size: SidebarMenuButtonSize.lg,
                tooltip: dashboard01UserName,
                onPressed: menu.toggle,
                forcedStates: {if (menu.open) InkState.hovered},
                leading: const ExcludeSemantics(
                  child: Avatar(
                    children: [AvatarFallback(name: dashboard01UserName)],
                  ),
                ),
                trailing: const InkIcon('ellipsis-vertical'),
                child: const BrandText(
                  title: dashboard01UserName,
                  subtitle: dashboard01UserEmail,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
