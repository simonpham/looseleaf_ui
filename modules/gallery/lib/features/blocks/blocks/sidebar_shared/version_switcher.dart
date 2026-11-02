import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The guide's name and edition at the top of the pad; it drops a menu of
/// [versions] to switch editions.
///
/// Mirrors `VersionSwitcher` in upstream
/// `src/blocks/sidebar-shared/sidebar-version-switcher.tsx`.
class VersionSwitcher extends StatefulWidget {
  const VersionSwitcher({
    super.key,
    required this.versions,
    required this.defaultVersion,
    this.title = 'Field guide',
    this.icon = 'book-open',
  });

  final List<String> versions;
  final String defaultVersion;
  final String title;
  final String icon;

  @override
  State<VersionSwitcher> createState() => _VersionSwitcherState();
}

class _VersionSwitcherState extends State<VersionSwitcher> {
  late String _selected = widget.defaultVersion;

  @override
  Widget build(BuildContext context) => SidebarMenu(
    children: [
      SidebarMenuItem(
        child: LayoutBuilder(
          builder: (context, constraints) => DropdownMenu(
            content: DropdownMenuContent(
              width: constraints.maxWidth,
              align: OverlayAlign.start,
              children: [
                const DropdownMenuLabel(child: Text('Editions')),
                for (final version in widget.versions)
                  DropdownMenuItem(
                    onSelect: () => setState(() => _selected = version),
                    trailing: switch (version == _selected) {
                      true => const InkIcon(
                        'check',
                        semanticLabel: 'Current edition',
                      ),
                      false => null,
                    },
                    child: Text('v$version'),
                  ),
              ],
            ),
            child: DropdownMenuTrigger.builder(
              builder: (context, menu) => SidebarMenuButton(
                size: SidebarMenuButtonSize.lg,
                onPressed: menu.toggle,
                forcedStates: {if (menu.open) InkState.hovered},
                leading: BrandTile(icon: widget.icon),
                trailing: const InkIcon('chevrons-up-down'),
                child: BrandText(title: widget.title, subtitle: 'v$_selected'),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
