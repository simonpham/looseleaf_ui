import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SidebarGroupCollapsibleExample extends StatelessWidget {
  const SidebarGroupCollapsibleExample({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 230,
    child: SidebarProvider(
      children: [
        Sidebar(
          seed: 'official-group-collapsible',
          children: [
            SidebarContent(
              children: [
                Collapsible(
                  defaultOpen: true,
                  child: SidebarGroup(
                    children: [
                      const CollapsibleTrigger(child: _HelpLabel()),
                      CollapsibleContent(
                        child: SidebarGroupContent(
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
                      ),
                    ],
                  ),
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

class _HelpLabel extends StatefulWidget {
  const _HelpLabel();

  @override
  State<_HelpLabel> createState() => _HelpLabelState();
}

class _HelpLabelState extends State<_HelpLabel> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final open = Collapsible.of(context).open;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: SidebarSwipe(
        on: _hovered,
        child: SidebarGroupLabel(
          child: Row(
            children: [
              const Expanded(child: Text('Help')),
              AnimatedRotation(
                turns: switch (open) {
                  true => 0.5,
                  false => 0,
                },
                duration: InkMotion.of(context, InkMotion.hover),
                child: const InkIcon('chevron-down'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
