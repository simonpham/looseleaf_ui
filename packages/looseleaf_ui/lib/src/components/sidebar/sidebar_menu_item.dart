import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One row of a [SidebarMenu]: its [child] (a [SidebarMenuButton], or a
/// [Collapsible] holding the button and a [SidebarMenuSub]) with an
/// optional [action] or [badge] at the end of the button.
///
/// Mirrors `SidebarMenuItem` in upstream `src/components/ui/sidebar.tsx`,
/// whose absolutely placed action and badge children become slots.
class SidebarMenuItem extends StatefulWidget {
  const SidebarMenuItem({
    super.key,
    required this.child,
    this.action,
    this.badge,
  });

  /// The row's button.
  final Widget child;

  /// A [SidebarMenuAction] at the end of the button.
  final Widget? action;

  /// A [SidebarMenuBadge] at the end of the button.
  final Widget? badge;

  @override
  State<SidebarMenuItem> createState() => _SidebarMenuItemState();
}

class _SidebarMenuItemState extends State<SidebarMenuItem> {
  final ValueNotifier<SidebarMenuButtonSize> _size = ValueNotifier(
    SidebarMenuButtonSize.regular,
  );
  final ValueNotifier<bool> _engaged = ValueNotifier(false);
  bool _hovered = false;
  bool _focused = false;

  void _update() => _engaged.value = _hovered || _focused;

  @override
  void dispose() {
    _size.dispose();
    _engaged.dispose();
    super.dispose();
  }

  Widget _end(Widget child) => PositionedDirectional(
    top: 0,
    end: Spacing.d4,
    child: ValueListenableBuilder(
      valueListenable: _size,
      builder: (context, size, child) => SizedBox(
        height: size.height.resolve(LooseleafTheme.of(context).density),
        child: Center(child: child),
      ),
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final action = widget.action;
    final badge = widget.badge;
    return SidebarMenuItemScope(
      hasAction: action != null,
      buttonSize: _size,
      engaged: _engaged,
      child: MouseRegion(
        onEnter: (_) {
          _hovered = true;
          _update();
        },
        onExit: (_) {
          _hovered = false;
          _update();
        },
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onFocusChange: (focused) {
            _focused = focused;
            _update();
          },
          child: Stack(
            children: [
              widget.child,
              if (badge != null) _end(IgnorePointer(child: badge)),
              if (action != null) _end(action),
            ],
          ),
        ),
      ),
    );
  }
}
