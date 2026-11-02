import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_13/sidebar_13.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A notes app whose settings open in a dialog with a sidebar of its own,
/// from the pad or from the button in the page's corner.
///
/// Mirrors upstream `src/blocks/sidebar-13/page.tsx`.
class Sidebar13Block extends StatefulWidget {
  const Sidebar13Block({super.key});

  @override
  State<Sidebar13Block> createState() => _Sidebar13BlockState();
}

class _Sidebar13BlockState extends State<Sidebar13Block> {
  bool _open = false;

  static const double _height = 560;

  void _openSettings() => setState(() => _open = true);

  @override
  Widget build(BuildContext context) => SizedBox(
    height: _height,
    child: Sidebar13SettingsDialog(
      open: _open,
      onOpenChange: (open) => setState(() => _open = open),
      child: SidebarProvider(
        children: [
          Sidebar13AppSidebar(onOpenSettings: _openSettings),
          SidebarPageSheet(
            children: [
              SidebarPageHeader(
                crumbs: const ['Notes', 'Untitled'],
                bordered: true,
                actions: [
                  Button(
                    variant: ButtonVariant.outline,
                    size: ButtonSize.sm,
                    onPressed: _openSettings,
                    leading: const InkIcon('settings'),
                    child: const Text('Settings'),
                  ),
                ],
              ),
              const SidebarPageBody(
                title: 'Untitled',
                kicker: 'Notes',
                children: [
                  SidebarPageNote(
                    title: 'Settings live in a drawer of their own',
                    pose: 'point',
                    description: 'Open them from the pad or from the button in the corner. Everything you change is kept while you write.',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
