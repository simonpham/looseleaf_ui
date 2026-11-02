import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_13/sidebar_13.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A settings dialog with a pad of its own: the sections down the side
/// (a picker on phones) and the chosen section's switches beside them.
/// [child] is what it opens over.
///
/// Mirrors upstream `src/blocks/sidebar-13/components/sidebar-13-settings-dialog.tsx`.
class Sidebar13SettingsDialog extends StatefulWidget {
  const Sidebar13SettingsDialog({
    super.key,
    required this.open,
    required this.onOpenChange,
    required this.child,
    this.defaultSection = 'Messages & media',
  });

  final bool open;
  final ValueChanged<bool> onOpenChange;
  final Widget child;
  final String defaultSection;

  @override
  State<Sidebar13SettingsDialog> createState() =>
      _Sidebar13SettingsDialogState();
}

class _Sidebar13SettingsDialogState extends State<Sidebar13SettingsDialog> {
  late String _section = widget.defaultSection;
  final Map<String, bool> _values = {
    for (final section in settingsSections)
      for (final toggle in section.toggles) toggle.id: toggle.on,
  };

  static const double _paneHeight = 480;
  static const double _mediumWidth = 768;
  static const double _largeWidth = 1024;
  static const double _maxWidth = 700;
  static const double _maxWidthLarge = 800;

  Widget _sections() => Sidebar(
    collapsible: SidebarCollapsible.none,
    seed: 'sidebar-13-settings',
    children: [
      SidebarContent(
        children: [
          SidebarGroup(
            children: [
              SidebarGroupContent(
                child: SidebarMenu(
                  children: [
                    for (final item in settingsSections)
                      SidebarMenuItem(
                        child: SidebarMenuButton(
                          isActive: item.name == _section,
                          onPressed: () => setState(() => _section = item.name),
                          leading: InkIcon(item.icon),
                          child: Text(item.name),
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
  );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final current =
        settingsSections.where((s) => s.name == _section).firstOrNull ??
        settingsSections.first;
    return Dialog(
      open: widget.open,
      onOpenChange: widget.onOpenChange,
      content: DialogContent(
        tilt: false,
        padding: EdgeInsets.zero,
        gap: 0,
        maxWidth: switch (width >= _largeWidth) {
          true => _maxWidthLarge,
          false => _maxWidth,
        },
        semanticLabel: 'Settings',
        children: [
          SizedBox(
            height: _paneHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (width >= _mediumWidth) _sections(),
                Expanded(
                  child: Sidebar13SettingsPane(
                    section: current,
                    onSectionChange: (name) => setState(() => _section = name),
                    values: _values,
                    onValueChange: (id, value) =>
                        setState(() => _values[id] = value),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      child: widget.child,
    );
  }
}
