import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _projects = [
  (name: 'Design Engineering', icon: 'frame'),
  (name: 'Sales & Marketing', icon: 'chart-pie'),
  (name: 'Travel', icon: 'map'),
  (name: 'Support', icon: 'life-buoy'),
  (name: 'Feedback', icon: 'send'),
];

class SidebarMenuExample extends StatelessWidget {
  const SidebarMenuExample({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 260,
    child: SidebarProvider(
      children: [
        Sidebar(
          seed: 'official-menu',
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
                            SidebarMenuItem(
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
