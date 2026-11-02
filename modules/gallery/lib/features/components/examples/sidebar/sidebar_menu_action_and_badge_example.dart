import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _projects = [
  (name: 'Design Engineering', icon: 'frame'),
  (name: 'Sales & Marketing', icon: 'chart-pie'),
  (name: 'Travel', icon: 'map'),
];

const _unread = [
  (name: 'Support', icon: 'life-buoy', badge: '21'),
  (name: 'Feedback', icon: 'send', badge: '8'),
  (name: 'Travel', icon: 'map', badge: '3'),
];

class SidebarMenuActionAndBadgeExample extends StatelessWidget {
  const SidebarMenuActionAndBadgeExample({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 380,
    child: SidebarProvider(
      children: [
        Sidebar(
          seed: 'official-menu-action',
          children: [
            SidebarContent(
              children: [
                SidebarGroup(
                  children: [
                    const SidebarGroupLabel(child: Text('Projects')),
                    SidebarGroupContent(
                      child: SidebarMenu(
                        children: [
                          for (final project in _projects)
                            _ProjectRow(name: project.name, icon: project.icon),
                        ],
                      ),
                    ),
                  ],
                ),
                SidebarGroup(
                  children: [
                    const SidebarGroupLabel(child: Text('Unread')),
                    SidebarGroupContent(
                      child: SidebarMenu(
                        children: [
                          for (final project in _unread)
                            SidebarMenuItem(
                              badge: SidebarMenuBadge(
                                child: Text(project.badge),
                              ),
                              child: SidebarMenuButton(
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
          ],
        ),
        const SidebarInset(child: SizedBox.shrink()),
      ],
    ),
  );
}

class _ProjectRow extends StatefulWidget {
  const _ProjectRow({required this.name, required this.icon});

  final String name;
  final String icon;

  @override
  State<_ProjectRow> createState() => _ProjectRowState();
}

class _ProjectRowState extends State<_ProjectRow> {
  bool _menuOpen = false;

  @override
  Widget build(BuildContext context) => SidebarMenuItem(
    action: DropdownMenu(
      onOpenChange: (open) => setState(() => _menuOpen = open),
      content: DropdownMenuContent(
        side: OverlaySide.right,
        align: OverlayAlign.start,
        children: [
          DropdownMenuItem(onSelect: () {}, child: const Text('Edit Project')),
          DropdownMenuItem(
            onSelect: () {},
            child: const Text('Delete Project'),
          ),
        ],
      ),
      child: DropdownMenuTrigger.builder(
        builder: (context, menu) => SidebarMenuAction(
          semanticLabel: 'More',
          onPressed: menu.toggle,
          child: const InkIcon('ellipsis'),
        ),
      ),
    ),
    child: SidebarMenuButton(
      forcedStates: {if (_menuOpen) InkState.hovered},
      leading: InkIcon(widget.icon),
      onPressed: () {},
      child: Text(widget.name),
    ),
  );
}
