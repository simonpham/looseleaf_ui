import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/context_menu/context_menu.dart';

/// The region of a [ContextMenu] that answers a right click or a long
/// press by opening the menu at the pointer. The context menu key, or
/// Shift+F10, opens it at the region's centre while something inside has
/// focus. [disabled] leaves the region alone.
///
/// Mirrors `ContextMenuTrigger` in upstream
/// `src/components/ui/context-menu.tsx`.
class ContextMenuTrigger extends StatelessWidget {
  const ContextMenuTrigger({
    super.key,
    required this.child,
    this.disabled = false,
  });

  /// The region.
  final Widget child;

  /// Whether right clicks are ignored.
  final bool disabled;

  static bool _isMenuKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.contextMenu) return true;
    return key == LogicalKeyboardKey.f10 &&
        HardwareKeyboard.instance.isShiftPressed;
  }

  @override
  Widget build(BuildContext context) {
    final menu = ContextMenu.of(context);
    if (disabled) return child;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onKeyEvent: (node, event) {
        if (!_isMenuKey(event)) return KeyEventResult.ignored;
        final box = context.findRenderObject();
        if (box is! RenderBox) return KeyEventResult.ignored;
        menu.openAt(box.localToGlobal(box.size.center(Offset.zero)));
        return KeyEventResult.handled;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onSecondaryTapUp: (details) => menu.openAt(details.globalPosition),
        onLongPressStart: (details) => menu.openAt(details.globalPosition),
        child: child,
      ),
    );
  }
}
