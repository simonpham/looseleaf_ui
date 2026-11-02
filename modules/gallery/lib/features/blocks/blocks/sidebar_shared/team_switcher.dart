import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The current team at the top of the pad; it drops a menu of [teams] to
/// switch to, and a row to add one. [compact] makes it a small row sized
/// to its name.
///
/// Mirrors `TeamSwitcher` in upstream
/// `src/blocks/sidebar-shared/sidebar-team-switcher.tsx`.
class TeamSwitcher extends StatefulWidget {
  const TeamSwitcher({super.key, required this.teams, this.compact = false});

  final List<Team> teams;
  final bool compact;

  @override
  State<TeamSwitcher> createState() => _TeamSwitcherState();
}

class _TeamSwitcherState extends State<TeamSwitcher> {
  late String? _activeName = widget.teams.firstOrNull?.name;

  static const double _compactMenuWidth = Spacing.d256;
  static const double _menuMinWidth = 224;

  Widget _button(Team active, DropdownMenuController menu) {
    final theme = LooseleafTheme.of(context);
    if (widget.compact) {
      return SidebarMenuButton(
        semanticLabel: 'Team: ${active.name}',
        onPressed: menu.toggle,
        forcedStates: {if (menu.open) InkState.hovered},
        leading: BrandTile(icon: active.icon, small: true),
        trailing: Opacity(
          opacity: 0.6,
          child: InkIcon('chevron-down', color: theme.colors.ink),
        ),
        child: Text(
          active.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      );
    }
    return SidebarMenuButton(
      size: SidebarMenuButtonSize.lg,
      tooltip: active.name,
      onPressed: menu.toggle,
      forcedStates: {if (menu.open) InkState.hovered},
      leading: BrandTile(icon: active.icon),
      trailing: const InkIcon('chevrons-up-down'),
      child: BrandText(title: active.name, subtitle: active.plan),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teams = widget.teams;
    final active =
        teams.where((team) => team.name == _activeName).firstOrNull ??
        teams.firstOrNull;
    if (active == null) return const SizedBox.shrink();
    final isMobile = SidebarProvider.maybeOf(context)?.isMobile ?? false;
    return SidebarMenu(
      children: [
        SidebarMenuItem(
          child: LayoutBuilder(
            builder: (context, constraints) => DropdownMenu(
              content: DropdownMenuContent(
                width: switch (widget.compact) {
                  true => _compactMenuWidth,
                  false => null,
                },
                minWidth: switch (widget.compact) {
                  true => null,
                  false => constraints.maxWidth.clamp(
                    _menuMinWidth,
                    double.infinity,
                  ),
                },
                align: OverlayAlign.start,
                side: switch (widget.compact || isMobile) {
                  true => OverlaySide.bottom,
                  false => OverlaySide.right,
                },
                sideOffset: Spacing.d4,
                children: [
                  const DropdownMenuLabel(child: Text('Teams')),
                  for (final team in teams)
                    DropdownMenuItem(
                      onSelect: () => setState(() => _activeName = team.name),
                      leading: InkIcon(team.icon),
                      trailing: switch (team.name == active.name) {
                        true => const InkIcon(
                          'check',
                          semanticLabel: 'Current team',
                        ),
                        false => null,
                      },
                      child: Text(team.name),
                    ),
                  const DropdownMenuSeparator(),
                  const DropdownMenuItem(
                    leading: InkIcon('plus'),
                    child: Text('Add team'),
                  ),
                ],
              ),
              child: DropdownMenuTrigger.builder(
                builder: (context, menu) => _button(active, menu),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
