import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _projects = [
  (name: 'Design Engineering', icon: 'frame'),
  (name: 'Sales & Marketing', icon: 'chart-pie'),
  (name: 'Travel', icon: 'map'),
  (name: 'Support', icon: 'life-buoy'),
  (name: 'Feedback', icon: 'send'),
];

class SidebarControlledAndLoadingExample extends StatefulWidget {
  const SidebarControlledAndLoadingExample({super.key});

  @override
  State<SidebarControlledAndLoadingExample> createState() =>
      _SidebarControlledAndLoadingExampleState();
}

class _SidebarControlledAndLoadingExampleState
    extends State<SidebarControlledAndLoadingExample> {
  bool _open = true;
  bool _loaded = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _timer?.cancel();
    _timer = Timer(
      const Duration(seconds: 2),
      () => setState(() => _loaded = true),
    );
  }

  void _reload() {
    setState(() => _loaded = false);
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 360,
    child: SidebarProvider(
      open: _open,
      onOpenChange: (open) => setState(() => _open = open),
      children: [
        Sidebar(
          seed: 'official-controlled',
          children: [
            SidebarContent(
              children: [
                SidebarGroup(
                  children: [
                    const SidebarGroupLabel(child: Text('Projects')),
                    SidebarGroupContent(
                      child: Semantics(
                        liveRegion: true,
                        child: SidebarMenu(
                          children: [
                            for (final project in _projects)
                              SidebarMenuItem(
                                child: switch (_loaded) {
                                  true => SidebarMenuButton(
                                    leading: InkIcon(project.icon),
                                    onPressed: () {},
                                    child: Text(project.name),
                                  ),
                                  false => SidebarMenuSkeleton(
                                    showIcon: true,
                                    seed: project.name,
                                  ),
                                },
                              ),
                          ],
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
          child: Align(
            alignment: AlignmentDirectional.topStart,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.d16),
              child: SizedBox(
                height: Spacing.d48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Button(
                      variant: ButtonVariant.ghost,
                      size: ButtonSize.sm,
                      leading: InkIcon(switch (_open) {
                        true => 'panel-left-close',
                        false => 'panel-left-open',
                      }),
                      onPressed: () => setState(() => _open = !_open),
                      child: Text(switch (_open) {
                        true => 'Close Sidebar',
                        false => 'Open Sidebar',
                      }),
                    ),
                    Button(
                      variant: ButtonVariant.outline,
                      size: ButtonSize.sm,
                      disabled: !_loaded,
                      leading: const InkIcon('rotate-cw'),
                      onPressed: _reload,
                      child: const Text('Reload'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
