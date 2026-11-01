import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/dropdown_menu/dropdown_menu.dart';

/// The control that opens a [DropdownMenu].
///
/// With [DropdownMenuTrigger.builder], hand the controller to your own
/// control (a `Button`'s `onPressed: menu.toggle`), like upstream's
/// `asChild`. With a plain [child], the trigger itself takes taps, Enter
/// and Space and is announced as a button. Either way Down opens the menu
/// with its first row highlighted, and it reports `expanded`.
///
/// Mirrors `DropdownMenuTrigger` in upstream
/// `src/components/ui/dropdown-menu.tsx`.
class DropdownMenuTrigger extends StatelessWidget {
  /// A trigger that toggles on tap, Enter and Space.
  const DropdownMenuTrigger({
    super.key,
    required Widget this.child,
    this.focusNode,
    this.autofocus = false,
  }) : builder = null;

  /// A trigger built around your own control.
  const DropdownMenuTrigger.builder({super.key, required this.builder})
    : child = null,
      focusNode = null,
      autofocus = false;

  /// The trigger's content.
  final Widget? child;

  /// Builds the trigger with the menu's controller.
  final Widget Function(BuildContext context, DropdownMenuController menu)?
  builder;

  /// The plain trigger's focus node.
  final FocusNode? focusNode;

  /// Whether the plain trigger takes focus first.
  final bool autofocus;

  KeyEventResult _onKey(DropdownMenuController menu, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey != LogicalKeyboardKey.arrowDown) {
      return KeyEventResult.ignored;
    }
    menu.setOpen(true, focusFirst: true);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final menu = DropdownMenu.of(context);
    final build = builder;
    final Widget control = switch (build) {
      final build? => Semantics(
        expanded: menu.open,
        child: build(context, menu),
      ),
      null => Semantics(
        container: true,
        button: true,
        expanded: menu.open,
        onTap: menu.toggle,
        child: FocusableActionDetector(
          focusNode: focusNode,
          autofocus: autofocus,
          mouseCursor: SystemMouseCursors.click,
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          },
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                menu.toggle();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: menu.toggle,
            child: child,
          ),
        ),
      ),
    };
    return TapRegion(
      groupId: menu.groupId,
      child: Listener(
        onPointerDown: (_) => menu.pointerDown(),
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onKeyEvent: (node, event) => _onKey(menu, event),
          child: control,
        ),
      ),
    );
  }
}
