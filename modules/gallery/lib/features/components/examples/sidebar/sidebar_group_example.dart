import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SidebarGroupExample extends StatelessWidget {
  const SidebarGroupExample({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 230,
    child: SidebarProvider(
      children: [
        Sidebar(
          seed: 'official-group',
          children: [
            SidebarContent(
              children: [
                SidebarGroup(
                  children: [
                    const SidebarGroupLabel(child: Text('Help')),
                    SidebarGroupContent(
                      child: SidebarMenu(
                        children: [
                          SidebarMenuItem(
                            child: SidebarMenuButton(
                              leading: const InkIcon('life-buoy'),
                              onPressed: () {},
                              child: const Text('Support'),
                            ),
                          ),
                          SidebarMenuItem(
                            child: SidebarMenuButton(
                              leading: const InkIcon('send'),
                              onPressed: () {},
                              child: const Text('Feedback'),
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
