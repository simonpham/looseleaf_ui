import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The page's corner: when it was edited (on wider screens), a star to
/// keep it in the favorites, and three dots that open its menu of
/// actions.
///
/// Mirrors upstream `src/blocks/sidebar-10/components/sidebar-10-nav-actions.tsx`.
class Sidebar10NavActions extends StatefulWidget {
  const Sidebar10NavActions({super.key, this.defaultOpen = false});

  final bool defaultOpen;

  @override
  State<Sidebar10NavActions> createState() => _Sidebar10NavActionsState();
}

class _Sidebar10NavActionsState extends State<Sidebar10NavActions> {
  bool _starred = false;
  late bool _open = widget.defaultOpen;

  static const double _menuWidth = 224;
  static const double _mediumWidth = 768;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= _mediumWidth;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d8,
      children: [
        if (wide)
          Text(
            'Edited just now',
            style: theme.typography.face(
              KevinSansFace.hand,
              cssSize: 14,
              color: theme.colors.inkMuted,
            ),
          ),
        Semantics(
          toggled: _starred,
          child: Button(
            variant: ButtonVariant.ghost,
            size: ButtonSize.iconSm,
            semanticLabel: switch (_starred) {
              true => 'Remove from favorites',
              false => 'Add to favorites',
            },
            onPressed: () => setState(() => _starred = !_starred),
            child: InkIcon(
              'star',
              tone: switch (_starred) {
                true => ArtTone.doodle,
                false => ArtTone.ui,
              },
            ),
          ),
        ),
        Popover(
          open: _open,
          onOpenChange: (open) => setState(() => _open = open),
          content: PopoverContent(
            width: _menuWidth,
            padding: EdgeInsets.zero,
            align: OverlayAlign.end,
            tilt: false,
            semanticLabel: 'Page actions',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, group) in pageActions.indexed) ...[
                  if (index > 0) const Separator(),
                  SidebarGroup(
                    children: [
                      SidebarGroupContent(
                        child: SidebarMenu(
                          children: [
                            for (final item in group)
                              SidebarMenuItem(
                                child: SidebarMenuButton(
                                  onPressed: () =>
                                      setState(() => _open = false),
                                  leading: InkIcon(item.icon),
                                  child: Text(item.label),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          child: PopoverTrigger.builder(
            builder: (context, popover) => Button(
              variant: ButtonVariant.ghost,
              size: ButtonSize.iconSm,
              semanticLabel: 'More actions',
              forcedStates: {if (_open) InkState.hovered},
              onPressed: popover.toggle,
              child: const InkIcon('ellipsis'),
            ),
          ),
        ),
      ],
    );
  }
}
