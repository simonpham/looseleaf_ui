import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const List<(String, String)> _platform = [
  ('square-terminal', 'Playground'),
  ('bot', 'Models'),
  ('book-open', 'Documentation'),
  ('settings', 'Settings'),
];

const List<(String, String, String?)> _projects = [
  ('frame', 'Design engineering', null),
  ('chart-pie', 'Sales & marketing', '12'),
  ('map', 'Travel', null),
];

/// The upstream "App sidebar" example: a team switcher, a group with an
/// open sub-menu, projects with actions and a count, the inset page.
Widget appSidebar({
  bool defaultOpen = true,
  SidebarVariant variant = SidebarVariant.sidebar,
  SidebarCollapsible collapsible = SidebarCollapsible.offcanvas,
  SidebarSide side = SidebarSide.left,
  Set<InkState> hoverRow = const {},
}) {
  final sidebar = Sidebar(
    seed: 'app',
    variant: variant,
    collapsible: collapsible,
    side: side,
    rail: const SidebarRail(),
    children: [
      SidebarHeader(
        children: [
          SidebarMenu(
            children: [
              SidebarMenuItem(
                child: SidebarMenuButton(
                  size: SidebarMenuButtonSize.lg,
                  leading: Builder(
                    builder: (context) => SizedBox.square(
                      dimension: Spacing.d32,
                      child: ColoredBox(
                        color: LooseleafTheme.of(
                          context,
                        ).colors.marker.withValues(alpha: 0.8),
                        child: const Center(child: InkIcon('book-open')),
                      ),
                    ),
                  ),
                  trailing: const InkIcon('chevrons-up-down'),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Looseleaf',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'Notebook',
                        style: TextStyle(fontSize: 11, height: 1.1),
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
              const SidebarGroupLabel(child: Text('Platform')),
              SidebarGroupContent(
                child: SidebarMenu(
                  children: [
                    for (final (icon, title) in _platform)
                      SidebarMenuItem(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: Spacing.d4,
                          children: [
                            SidebarMenuButton(
                              seed: title,
                              isActive: title == 'Documentation',
                              tooltip: title,
                              forcedStates: switch (title) {
                                'Models' => hoverRow,
                                _ => const {},
                              },
                              leading: InkIcon(icon),
                              trailing: switch (title) {
                                'Documentation' => const InkIcon('chevron-up'),
                                _ => null,
                              },
                              onPressed: () {},
                              child: Text(title),
                            ),
                            if (title == 'Documentation')
                              SidebarMenuSub(
                                seed: 'docs',
                                children: [
                                  for (final sub in const [
                                    'Introduction',
                                    'Get started',
                                    'Tutorials',
                                  ])
                                    SidebarMenuSubItem(
                                      child: SidebarMenuSubButton(
                                        isActive: sub == 'Get started',
                                        onPressed: () {},
                                        child: Text(sub),
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
          SidebarGroup(
            action: SidebarGroupAction(
              semanticLabel: 'Add project',
              onPressed: () {},
              child: const InkIcon('plus'),
            ),
            children: [
              const SidebarGroupLabel(child: Text('Projects')),
              SidebarGroupContent(
                child: SidebarMenu(
                  children: [
                    for (final (icon, name, count) in _projects)
                      SidebarMenuItem(
                        badge: switch (count) {
                          final count? => SidebarMenuBadge(child: Text(count)),
                          null => null,
                        },
                        action: switch (count) {
                          null => SidebarMenuAction(
                            showOnHover: true,
                            semanticLabel: 'Actions for $name',
                            onPressed: () {},
                            child: const InkIcon('ellipsis'),
                          ),
                          _ => null,
                        },
                        child: SidebarMenuButton(
                          tooltip: name,
                          leading: InkIcon(icon),
                          onPressed: () {},
                          child: Text(name),
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
  return SidebarProvider(
    defaultOpen: defaultOpen,
    children: [
      if (side == SidebarSide.left) sidebar,
      SidebarInset(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.d16),
          child: Builder(
            builder: (context) {
              final theme = LooseleafTheme.of(context);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: Spacing.d8,
                    children: [
                      const SidebarTrigger(seed: 'trigger'),
                      Text(
                        'Get started',
                        style: theme.typography.title(cssSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.d12),
                  Text(
                    'The page beside the pad. Collapse it with the button, '
                    'with Ctrl/Cmd+B, or by clicking the strip on its edge.',
                    style: theme.typography.interface(
                      cssSize: 14,
                      color: theme.colors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: Spacing.d16),
                  Button(
                    variant: ButtonVariant.secondary,
                    size: ButtonSize.sm,
                    seed: 'continue',
                    leading: const InkIcon('sparkles'),
                    onPressed: () {},
                    child: const Text('Continue'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      if (side == SidebarSide.right) sidebar,
    ],
  );
}

/// [child] on the desk, [size] big, inside an [Overlay] for tooltips and
/// the phone sheet.
Widget deskStage(Widget child, {Size size = const Size(640, 500)}) =>
    RepaintBoundary(
      key: const Key('shot'),
      child: SizedBox.fromSize(
        size: size,
        child: Builder(
          builder: (context) => ColoredBox(
            color: LooseleafTheme.of(context).colors.desk,
            child: Overlay(
              initialEntries: [OverlayEntry(builder: (context) => child)],
            ),
          ),
        ),
      ),
    );
