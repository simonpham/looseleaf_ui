import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _platform = [
  (title: 'Playground', icon: 'square-terminal', items: <String>[]),
  (title: 'Models', icon: 'bot', items: <String>[]),
  (
    title: 'Documentation',
    icon: 'book-open',
    items: ['Introduction', 'Get started', 'Tutorials'],
  ),
  (title: 'Settings', icon: 'settings', items: <String>[]),
];

const _projects = [
  (name: 'Design engineering', icon: 'frame', count: null),
  (name: 'Sales & marketing', icon: 'chart-pie', count: '12'),
  (name: 'Travel', icon: 'map', count: null),
];

class SidebarAppSidebarExample extends StatelessWidget {
  const SidebarAppSidebarExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return SizedBox(
      height: 600,
      child: SidebarProvider(
        children: [
          Sidebar(
            seed: 'app',
            children: [
              SidebarHeader(
                children: [
                  SidebarMenu(
                    children: [
                      SidebarMenuItem(
                        child: DropdownMenu(
                          content: const DropdownMenuContent(
                            width: 224,
                            align: OverlayAlign.start,
                            children: [
                              DropdownMenuLabel(child: Text('Notebooks')),
                              DropdownMenuItem(
                                trailing: DropdownMenuShortcut('⌘1'),
                                child: Text('Looseleaf'),
                              ),
                              DropdownMenuItem(
                                trailing: DropdownMenuShortcut('⌘2'),
                                child: Text('Field notes'),
                              ),
                              DropdownMenuSeparator(),
                              DropdownMenuItem(
                                leading: InkIcon('plus'),
                                child: Text('Add notebook'),
                              ),
                            ],
                          ),
                          child: DropdownMenuTrigger.builder(
                            builder: (context, menu) => SidebarMenuButton(
                              size: SidebarMenuButtonSize.lg,
                              onPressed: menu.toggle,
                              forcedStates: {if (menu.open) InkState.hovered},
                              leading: SizedBox.square(
                                dimension: Spacing.d32,
                                child: ColoredBox(
                                  color: theme.colors.marker.withValues(
                                    alpha: 0.8,
                                  ),
                                  child: const Center(
                                    child: InkIcon('book-open'),
                                  ),
                                ),
                              ),
                              trailing: const InkIcon('chevrons-up-down'),
                              child: const _TwoLines(
                                title: 'Looseleaf',
                                subtitle: 'Notebook',
                              ),
                            ),
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
                      const SidebarGroupLabel(child: Text('Platform')),
                      SidebarGroupContent(
                        child: SidebarMenu(
                          children: [
                            for (final item in _platform)
                              SidebarMenuItem(
                                child: switch (item.items.isEmpty) {
                                  true => SidebarMenuButton(
                                    tooltip: item.title,
                                    leading: InkIcon(item.icon),
                                    onPressed: () {},
                                    child: Text(item.title),
                                  ),
                                  false => _CollapsibleRow(
                                    title: item.title,
                                    icon: item.icon,
                                    items: item.items,
                                    current: 'Get started',
                                  ),
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SidebarGroup(
                    children: [
                      const SidebarGroupLabel(child: Text('Projects')),
                      SidebarGroupContent(
                        child: SidebarMenu(
                          children: [
                            for (final project in _projects)
                              SidebarMenuItem(
                                badge: switch (project.count) {
                                  final count? => SidebarMenuBadge(
                                    child: Text(count),
                                  ),
                                  null => null,
                                },
                                action: switch (project.count) {
                                  null => _ProjectActions(name: project.name),
                                  _ => null,
                                },
                                child: SidebarMenuButton(
                                  tooltip: project.name,
                                  leading: InkIcon(project.icon),
                                  onPressed: () {},
                                  child: Text(project.name),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SidebarFooter(
                children: [
                  SidebarMenu(
                    children: [
                      SidebarMenuItem(
                        child: DropdownMenu(
                          content: const DropdownMenuContent(
                            width: 224,
                            side: OverlaySide.right,
                            align: OverlayAlign.end,
                            children: [
                              DropdownMenuItem(
                                leading: InkIcon('credit-card'),
                                child: Text('Billing'),
                              ),
                              DropdownMenuItem(
                                leading: InkIcon('bell'),
                                child: Text('Notifications'),
                              ),
                              DropdownMenuSeparator(),
                              DropdownMenuItem(
                                variant: InkMenuItemVariant.destructive,
                                leading: InkIcon('log-out'),
                                child: Text('Log out'),
                              ),
                            ],
                          ),
                          child: DropdownMenuTrigger.builder(
                            builder: (context, menu) => SidebarMenuButton(
                              size: SidebarMenuButtonSize.lg,
                              tooltip: 'Account',
                              onPressed: menu.toggle,
                              forcedStates: {if (menu.open) InkState.hovered},
                              leading: const Avatar(
                                children: [AvatarFallback(child: Text('JD'))],
                              ),
                              trailing: const InkIcon('chevrons-up-down'),
                              child: const _TwoLines(
                                title: 'Jo Delacroix',
                                subtitle: 'jo@looseleaf.example',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SidebarInset(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.d16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: Spacing.d8,
                    children: [
                      const SidebarTrigger(),
                      Text(
                        'Get started',
                        style: theme.typography.title(cssSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.d12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 448),
                    child: Text(
                      'The page beside the pad. Collapse it with the button, '
                      'with Ctrl/Cmd+B, or by clicking the strip on its edge.',
                      style: theme.typography.interface(
                        cssSize: 14,
                        color: theme.colors.inkMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.d16),
                  Button(
                    variant: ButtonVariant.secondary,
                    size: ButtonSize.sm,
                    leading: const InkIcon('sparkles'),
                    onPressed: () {},
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TwoLines extends StatelessWidget {
  const _TwoLines({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700, height: 1.1),
        ),
        Text(
          subtitle,
          overflow: TextOverflow.ellipsis,
          style: theme.typography
              .interface(cssSize: 12, color: theme.colors.inkMuted)
              .copyWith(height: 1.1),
        ),
      ],
    );
  }
}

class _CollapsibleRow extends StatelessWidget {
  const _CollapsibleRow({
    required this.title,
    required this.icon,
    required this.items,
    required this.current,
  });

  final String title;
  final String icon;
  final List<String> items;
  final String current;

  @override
  Widget build(BuildContext context) => Collapsible(
    defaultOpen: true,
    child: Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d4,
        children: [
          SidebarMenuButton(
            isActive: true,
            tooltip: title,
            leading: InkIcon(icon),
            trailing: const CollapsibleIndicator(),
            onPressed: Collapsible.of(context).toggle,
            child: Text(title),
          ),
          CollapsibleContent(
            child: SidebarMenuSub(
              children: [
                for (final sub in items)
                  SidebarMenuSubItem(
                    child: SidebarMenuSubButton(
                      isActive: sub == current,
                      onPressed: () {},
                      child: Text(sub),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ProjectActions extends StatelessWidget {
  const _ProjectActions({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) => DropdownMenu(
    content: const DropdownMenuContent(
      width: 192,
      side: OverlaySide.right,
      align: OverlayAlign.start,
      children: [
        DropdownMenuItem(
          leading: InkIcon('folder'),
          child: Text('View project'),
        ),
        DropdownMenuItem(leading: InkIcon('share'), child: Text('Share')),
        DropdownMenuSeparator(),
        DropdownMenuItem(
          variant: InkMenuItemVariant.destructive,
          leading: InkIcon('trash'),
          child: Text('Delete'),
        ),
      ],
    ),
    child: DropdownMenuTrigger.builder(
      builder: (context, menu) => SidebarMenuAction(
        showOnHover: true,
        semanticLabel: 'Actions for $name',
        onPressed: menu.toggle,
        child: const InkIcon('ellipsis'),
      ),
    ),
  );
}
