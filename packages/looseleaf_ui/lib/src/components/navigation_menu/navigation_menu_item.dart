import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/navigation_menu/navigation_menu.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One entry of a [NavigationMenuList]: a [NavigationMenuTrigger] with its
/// [content], or a [NavigationMenuLink] on its own.
///
/// Without the shared viewport, the item drops its own slip 8 px under its
/// tab, lined up with its start.
///
/// Mirrors `NavigationMenuItem` in upstream
/// `src/components/ui/navigation-menu.tsx`.
class NavigationMenuItem extends StatefulWidget {
  const NavigationMenuItem({
    super.key,
    required this.child,
    this.value,
    this.content,
  });

  /// The tab: a [NavigationMenuTrigger] or a [NavigationMenuLink].
  final Widget child;

  /// Names the item for the menu's value; a generated one when null.
  final String? value;

  /// The panel its trigger opens.
  final NavigationMenuContent? content;

  @override
  State<NavigationMenuItem> createState() => _NavigationMenuItemState();
}

class _NavigationMenuItemState extends State<NavigationMenuItem> {
  NavigationMenuController? _controller;
  String? _registered;

  String get _value => widget.value ?? 'item-${identityHashCode(this)}';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _register(NavigationMenu.maybeOf(context));
  }

  @override
  void didUpdateWidget(NavigationMenuItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    _register(_controller);
  }

  void _register(NavigationMenuController? controller) {
    if (_registered case final old?) _controller?.setContent(old, null);
    _controller = controller;
    _registered = _value;
    controller?.setContent(_value, widget.content);
  }

  @override
  void dispose() {
    if (_registered case final old?) _controller?.setContent(old, null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = NavigationMenu.maybeOf(context);
    final value = _value;
    final scoped = NavigationMenuItemScope(value: value, child: widget.child);
    final content = widget.content;
    if (controller == null || controller.viewport || content == null) {
      return scoped;
    }
    return InkPopup(
      open: controller.value == value,
      onOpenChange: (open) {
        if (!open) controller.close();
      },
      align: OverlayAlign.start,
      sideOffset: Spacing.d8,
      autofocus: false,
      groupId: controller.groupId,
      popupBuilder: (context, position) => MouseRegion(
        onEnter: (_) => controller.stay(),
        onExit: (_) => controller.leave(),
        child: Focus(
          focusNode: controller.panelFocus,
          child: content,
        ),
      ),
      child: scoped,
    );
  }
}
