import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/context_menu/context_menu.dart';
import 'package:looseleaf_ui/src/components/menu/menu.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A menu on a slip of paper that opens where you right-click (or
/// long-press) inside [child], usually a [ContextMenuTrigger] region:
/// [content] (a [ContextMenuContent]) is set down at the pointer, on its
/// end side, 2 px away.
///
/// The keys are a dropdown menu's: Up and Down move, Home and End jump,
/// typing finds a row, Right opens a sub-menu and Left closes it, Enter or
/// Space chooses, Escape closes. [modal] (the default) blocks the rest of
/// the app while open. A context menu should never be the only way to an
/// action: put the same actions on a visible control too.
///
/// Mirrors `ContextMenu` in upstream `src/components/ui/context-menu.tsx`
/// (Radix `ContextMenu.Root`).
class ContextMenu extends StatefulWidget {
  const ContextMenu({
    super.key,
    required this.content,
    required this.child,
    this.onOpenChange,
    this.modal = true,
  });

  /// The slip that opens.
  final ContextMenuContent content;

  /// The region; a [ContextMenuTrigger] or anything reading
  /// [ContextMenu.of].
  final Widget child;

  /// Called when it opens or asks to close.
  final ValueChanged<bool>? onOpenChange;

  /// Blocks the app below while open.
  final bool modal;

  /// Radix's `sideOffset`.
  static const double sideOffset = Spacing.d2;

  /// The nearest context menu's controller.
  static InkContextMenuController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<InkContextMenuScope>();
    if (scope == null) throw FlutterError('No ContextMenu above this widget.');
    return scope.controller;
  }

  @override
  State<ContextMenu> createState() => _ContextMenuState();
}

class _ContextMenuState extends State<ContextMenu> {
  bool _open = false;
  Rect? _anchor;
  final Object _group = Object();

  void _openAt(Offset globalPosition) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached) return;
    final local = box.globalToLocal(globalPosition);
    setState(() {
      _anchor = Rect.fromLTWH(local.dx, local.dy, 0, 0);
      _open = true;
    });
    widget.onOpenChange?.call(true);
  }

  void _setOpen(bool value) {
    if (value == _open) return;
    setState(() => _open = value);
    widget.onOpenChange?.call(value);
  }

  @override
  Widget build(BuildContext context) => InkContextMenuScope(
    controller: InkContextMenuController(
      open: _open,
      openAt: _openAt,
      close: () => _setOpen(false),
    ),
    child: InkMenuPopup(
      open: _open,
      onOpenChange: _setOpen,
      content: widget.content,
      groupId: _group,
      modal: widget.modal,
      anchor: _anchor,
      placement: InkMenuPlacement(
        side: switch (Directionality.of(context)) {
          TextDirection.rtl => OverlaySide.left,
          TextDirection.ltr => OverlaySide.right,
        },
        align: OverlayAlign.start,
        sideOffset: ContextMenu.sideOffset,
      ),
      child: widget.child,
    ),
  );
}
