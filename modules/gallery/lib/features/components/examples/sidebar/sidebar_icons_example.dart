import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _items = [
  (title: 'Inbox', icon: 'inbox', count: '3'),
  (title: 'Calendar', icon: 'calendar', count: null),
  (title: 'Search', icon: 'search', count: null),
  (title: 'Settings', icon: 'settings', count: null),
];

class SidebarIconsExample extends StatefulWidget {
  const SidebarIconsExample({super.key});

  @override
  State<SidebarIconsExample> createState() => _SidebarIconsExampleState();
}

class _SidebarIconsExampleState extends State<SidebarIconsExample> {
  bool _open = true;
  String _current = 'Inbox';

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return SizedBox(
      height: 460,
      child: SidebarProvider(
        open: _open,
        onOpenChange: (open) => setState(() => _open = open),
        children: [
          Sidebar(
            collapsible: SidebarCollapsible.icon,
            seed: 'icons',
            rail: const SidebarRail(),
            children: [
              SidebarHeader(
                children: [
                  SidebarMenu(
                    children: [
                      SidebarMenuItem(
                        child: SidebarMenuButton(
                          size: SidebarMenuButtonSize.lg,
                          tooltip: 'Looseleaf',
                          leading: const InkIcon('book-open'),
                          onPressed: () {},
                          child: const Text(
                            'Looseleaf',
                            style: TextStyle(fontWeight: FontWeight.w700),
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
                      const SidebarGroupLabel(child: Text('Application')),
                      SidebarGroupContent(
                        child: SidebarMenu(
                          children: [
                            for (final item in _items)
                              SidebarMenuItem(
                                badge: switch (item.count) {
                                  final count? => SidebarMenuBadge(
                                    child: Text(count),
                                  ),
                                  null => null,
                                },
                                child: SidebarMenuButton(
                                  isActive: _current == item.title,
                                  tooltip: item.title,
                                  leading: InkIcon(item.icon),
                                  onPressed: () =>
                                      setState(() => _current = item.title),
                                  child: Text(item.title),
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
                        _current,
                        style: theme.typography.title(cssSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.d12),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      'The pad is ${switch (_open) {
                        true => 'open',
                        false => 'collapsed to icons',
                      }}. Hover a button when it is collapsed to read its name.',
                      style: theme.typography.interface(
                        cssSize: 14,
                        color: theme.colors.inkMuted,
                      ),
                    ),
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
