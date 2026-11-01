import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SidebarHeaderAndFooterExample extends StatelessWidget {
  const SidebarHeaderAndFooterExample({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 360,
    child: SidebarProvider(
      children: [
        Sidebar(
          seed: 'official-header-footer',
          children: [
            SidebarHeader(
              children: [
                SidebarMenu(
                  children: [
                    SidebarMenuItem(
                      child: _MenuButton(
                        label: 'Select Workspace',
                        chevron: 'chevron-down',
                        side: OverlaySide.bottom,
                        items: ['Acme Inc', 'Acme Corp.'],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SidebarContent(children: []),
            SidebarFooter(
              children: [
                SidebarMenu(
                  children: [
                    SidebarMenuItem(
                      child: _MenuButton(
                        label: 'Username',
                        chevron: 'chevron-up',
                        side: OverlaySide.top,
                        items: ['Account', 'Billing', 'Sign out'],
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

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.label,
    required this.chevron,
    required this.side,
    required this.items,
  });

  final String label;
  final String chevron;
  final OverlaySide side;
  final List<String> items;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => DropdownMenu(
      content: DropdownMenuContent(
        side: side,
        width: constraints.maxWidth,
        children: [
          for (final item in items)
            DropdownMenuItem(onSelect: () {}, child: Text(item)),
        ],
      ),
      child: DropdownMenuTrigger.builder(
        builder: (context, menu) => SidebarMenuButton(
          onPressed: menu.toggle,
          forcedStates: {if (menu.open) InkState.hovered},
          trailing: InkIcon(chevron),
          child: Text(label),
        ),
      ),
    ),
  );
}
