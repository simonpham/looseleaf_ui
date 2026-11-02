import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/dashboard_01/dashboard_01.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The proposal desk's inset pad: the studio's name, Quick create and the
/// main links, the documents with their menus, help links and the account.
///
/// Mirrors `AppSidebar` in upstream
/// `src/blocks/dashboard-01/components/dashboard-01-app-sidebar.tsx`.
class Dashboard01AppSidebar extends StatelessWidget {
  const Dashboard01AppSidebar({super.key});

  static const double _documentMenuWidth = 160;

  static const _main = [
    AppNavItem('Dashboard', icon: 'layout-dashboard', isActive: true),
    AppNavItem('Lifecycle', icon: 'list'),
    AppNavItem('Analytics', icon: 'chart-column'),
    AppNavItem('Projects', icon: 'folder'),
    AppNavItem('Team', icon: 'users'),
  ];

  static const _documents = [
    AppNavItem('Data library', icon: 'archive'),
    AppNavItem('Reports', icon: 'file-text'),
    AppNavItem('Writing helper', icon: 'bot'),
  ];

  static const _secondary = [
    AppNavItem('Settings', icon: 'settings'),
    AppNavItem('Get help', icon: 'life-buoy'),
    AppNavItem('Search', icon: 'search'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Sidebar(
      variant: SidebarVariant.inset,
      seed: 'dashboard-01',
      children: [
        SidebarHeader(
          children: [
            SidebarMenu(
              children: [
                SidebarMenuItem(
                  child: SidebarMenuButton(
                    size: SidebarMenuButtonSize.lg,
                    leading: const BrandTile(icon: 'pencil'),
                    onPressed: () {},
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inkwell & Co.',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.face(
                            KevinSansFace.script,
                            cssSize: 20,
                            cssLineHeight: 1.25,
                            fontWeight: FontWeight.w600,
                            color: theme.colors.ink,
                          ),
                        ),
                        Text(
                          'Proposal desk',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.face(
                            KevinSansFace.hand,
                            cssSize: 14,
                            cssLineHeight: 1.25,
                            color: theme.colors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SidebarContent(
          children: [
            SidebarGroup(
              children: [
                SidebarGroupContent(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: Spacing.d8,
                    children: [
                      SidebarMenu(
                        children: [
                          SidebarMenuItem(
                            child: Row(
                              spacing: Spacing.d8,
                              children: [
                                Expanded(
                                  child: Button(
                                    onPressed: () {},
                                    leading: const InkIcon('circle-plus'),
                                    child: const Text('Quick create'),
                                  ),
                                ),
                                Button(
                                  size: ButtonSize.icon,
                                  variant: ButtonVariant.outline,
                                  semanticLabel: 'Inbox',
                                  onPressed: () {},
                                  child: const InkIcon('mail'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Semantics(
                        container: true,
                        label: 'Main',
                        child: SidebarMenu(
                          children: [
                            for (final item in _main)
                              SidebarMenuItem(
                                child: SidebarMenuButton(
                                  isActive: item.isActive,
                                  tooltip: item.title,
                                  leading: InkIcon(item.icon),
                                  onPressed: () {},
                                  child: Text(item.title),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SidebarGroup(
              children: [
                const SidebarGroupLabel(child: Text('Documents')),
                SidebarMenu(
                  children: [
                    for (final item in _documents)
                      SidebarMenuItem(
                        action: NavRowActions(
                          name: item.title,
                          width: _documentMenuWidth,
                          items: const [
                            DropdownMenuItem(
                              leading: InkIcon('folder-open'),
                              child: Text('Open'),
                            ),
                            DropdownMenuItem(
                              leading: InkIcon('share'),
                              child: Text('Share'),
                            ),
                            DropdownMenuSeparator(),
                            DropdownMenuItem(
                              variant: InkMenuItemVariant.destructive,
                              leading: InkIcon('trash'),
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                        child: SidebarMenuButton(
                          leading: InkIcon(item.icon),
                          onPressed: () {},
                          child: Text(item.title),
                        ),
                      ),
                    const NavMoreRow(),
                  ],
                ),
              ],
            ),
          ],
        ),
        const NavSecondary(items: _secondary),
        const SidebarFooter(children: [Dashboard01NavUser()]),
      ],
    );
  }
}
