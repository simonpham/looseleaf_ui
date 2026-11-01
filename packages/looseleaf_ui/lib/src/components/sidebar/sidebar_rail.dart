import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A thin strip on the pad's page edge, given to [Sidebar.rail]: pointing
/// at it shows a pencil line and a resize cursor, a click toggles the
/// sidebar. Not a tab stop: the trigger and Ctrl/Cmd + B are the keyboard
/// routes.
///
/// Mirrors `SidebarRail` in upstream `src/components/ui/sidebar.tsx`.
class SidebarRail extends StatefulWidget {
  const SidebarRail({super.key, this.forceHover = false});

  /// Shows the hover line whatever the pointer does, for goldens.
  final bool forceHover;

  @override
  State<SidebarRail> createState() => _SidebarRailState();
}

class _SidebarRailState extends State<SidebarRail> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final data = SidebarProvider.of(context);
    final panel = SidebarPanelScope.maybeOf(context);
    final side = panel?.side ?? SidebarSide.left;
    final offcanvas = panel?.offcanvasCollapsed ?? false;
    final cursor = switch ((side, data.open)) {
      (SidebarSide.left, true) ||
      (SidebarSide.right, false) => SystemMouseCursors.resizeLeft,
      _ => SystemMouseCursors.resizeRight,
    };
    final line = switch ((offcanvas, side)) {
      (false, _) => Alignment.center,
      (true, SidebarSide.left) => Alignment.centerRight,
      (true, SidebarSide.right) => Alignment.centerLeft,
    };
    final shown = _hovered || widget.forceHover;
    return Semantics(
      button: true,
      label: 'Toggle Sidebar',
      onTap: data.toggleSidebar,
      child: MouseRegion(
        cursor: cursor,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: data.toggleSidebar,
          child: Align(
            alignment: line,
            child: AnimatedContainer(
              duration: InkMotion.of(context, InkMotion.hover),
              width: Spacing.d2,
              color: switch (shown) {
                true => LooseleafTheme.of(context).colors.pencilMark,
                false => LooseleafTheme.of(
                  context,
                ).colors.pencilMark.withValues(alpha: 0),
              },
            ),
          ),
        ),
      ),
    );
  }
}
