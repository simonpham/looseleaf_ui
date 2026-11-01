import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/menu/menu.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';

/// Shows a menu's [content] beside [child] while [open]: the [InkPopup]
/// under dropdown menus, context menus and menubar menus.
///
/// [placement] is the menu kind's default placement, which the content's
/// own props override; [anchor] pins it to a rect in [child] (a context
/// menu's pointer). [focusFirst] highlights the first row (the keyboard
/// opened it). [modal] blocks the app below while it is open. Escape, a
/// tap outside [groupId] or choosing a row ask [onOpenChange] for false;
/// focus goes back to where it was.
class InkMenuPopup extends StatelessWidget {
  const InkMenuPopup({
    super.key,
    required this.open,
    required this.onOpenChange,
    required this.content,
    required this.groupId,
    required this.child,
    this.placement = const InkMenuPlacement(),
    this.focusFirst = false,
    this.anchor,
    this.modal = true,
    this.onArrowOut,
  });

  /// Whether the menu is shown.
  final bool open;

  /// Asked to open or close the menu.
  final ValueChanged<bool> onOpenChange;

  /// The menu's slip.
  final InkMenuContent content;

  /// The tap region group of the trigger and every slip.
  final Object groupId;

  /// The anchor.
  final Widget child;

  /// The menu kind's default placement.
  final InkMenuPlacement placement;

  /// Highlights the first row on open.
  final bool focusFirst;

  /// A rect in [child]'s coordinates to anchor to.
  final Rect? anchor;

  /// Blocks the app below while open.
  final bool modal;

  /// Where horizontal arrows leaving the top level go.
  final ValueChanged<int>? onArrowOut;

  @override
  Widget build(BuildContext context) {
    final data = InkMenuRootData(
      close: () => onOpenChange(false),
      groupId: groupId,
      placement: placement,
      focusFirst: focusFirst,
      onArrowOut: onArrowOut,
    );
    return InkPopup(
      open: open,
      onOpenChange: onOpenChange,
      side: content.side ?? placement.side,
      align: content.align ?? placement.align,
      sideOffset: content.sideOffset ?? placement.sideOffset,
      alignOffset: content.alignOffset ?? placement.alignOffset,
      collisionPadding: content.collisionPadding,
      avoidCollisions: content.avoidCollisions,
      anchor: anchor,
      modal: modal,
      autofocus: false,
      groupId: groupId,
      popupBuilder: (context, position) => InkMenuRootScope(
        data: data,
        child: InkMenuPositionScope(position: position, child: content),
      ),
      child: child,
    );
  }
}
