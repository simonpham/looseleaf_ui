import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _projects = [
  (name: 'Design Engineering', icon: 'frame'),
  (name: 'Sales & Marketing', icon: 'chart-pie'),
  (name: 'Travel', icon: 'map'),
];

class SidebarGroupActionExample extends StatefulWidget {
  const SidebarGroupActionExample({super.key});

  @override
  State<SidebarGroupActionExample> createState() =>
      _SidebarGroupActionExampleState();
}

class _SidebarGroupActionExampleState extends State<SidebarGroupActionExample> {
  final _toasts = ToastController();

  @override
  void dispose() {
    _toasts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 250,
    child: Toaster(
      controller: _toasts,
      position: ToasterPosition.bottomRight,
      child: SidebarProvider(
        children: [
          Sidebar(
            seed: 'official-group-action',
            children: [
              SidebarContent(
                children: [
                  SidebarGroup(
                    action: SidebarGroupAction(
                      semanticLabel: 'Add Project',
                      onPressed: () =>
                          Sonner(_toasts)('You clicked the group action!'),
                      child: const InkIcon('plus'),
                    ),
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
    ),
  );
}
