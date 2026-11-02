import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _items = [
  (title: 'Home', icon: 'house'),
  (title: 'Inbox', icon: 'inbox'),
  (title: 'Calendar', icon: 'calendar'),
  (title: 'Search', icon: 'search'),
  (title: 'Settings', icon: 'settings'),
];

class SidebarDemoExample extends StatelessWidget {
  const SidebarDemoExample({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: Spacing.d320,
    child: SidebarProvider(
      children: [
        Sidebar(
          seed: 'official-demo',
          children: [
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
                              child: SidebarMenuButton(
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
              ],
            ),
          ],
        ),
        const SidebarInset(
          child: Align(
            alignment: AlignmentDirectional.topStart,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.d16),
              child: SizedBox(
                height: Spacing.d48,
                child: Row(children: [SidebarTrigger()]),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
