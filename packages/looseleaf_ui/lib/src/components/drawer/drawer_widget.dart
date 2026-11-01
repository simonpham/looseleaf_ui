import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';
import 'package:looseleaf_ui/src/components/drawer/drawer.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/components/sheet/sheet.dart';

/// A slip pulled out from an edge of the window ([direction], the bottom
/// by default): [content] (a [DrawerContent]) slides in over the dimmed
/// app and can be dragged back out: let go past a quarter of the way, or
/// flick it, and it closes.
///
/// Open state is yours with [open] and [onOpenChange], or its own starting
/// at [defaultOpen]. Escape and a tap on the dim close it too; focus moves
/// inside and back to the trigger on close. [modal] false drops the dim.
///
/// Mirrors `Drawer` in upstream `src/components/ui/drawer.tsx` (vaul's
/// `Drawer.Root`).
class Drawer extends StatefulWidget {
  const Drawer({
    super.key,
    required this.content,
    required this.child,
    this.direction = OverlaySide.bottom,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.modal = true,
    this.dismissible = true,
  });

  /// The slip that slides in, usually a [DrawerContent].
  final Widget content;

  /// The anchor, usually a [DrawerTrigger].
  final Widget child;

  /// The window edge it is pulled from.
  final OverlaySide direction;

  /// Whether it is open; it keeps its own state when null.
  final bool? open;

  /// Whether it starts open, when [open] is null.
  final bool defaultOpen;

  /// Called when it asks to open or close.
  final ValueChanged<bool>? onOpenChange;

  /// Dims and blocks the app and traps focus.
  final bool modal;

  /// Whether dragging it out and tapping the dim close it.
  final bool dismissible;

  @override
  State<Drawer> createState() => _DrawerState();
}

class _DrawerState extends State<Drawer> {
  late bool _open = widget.defaultOpen;
  final Object _group = Object();

  bool get _isOpen => widget.open ?? _open;

  void _setOpen(bool value) {
    if (value == _isOpen) return;
    if (widget.open == null) setState(() => _open = value);
    widget.onOpenChange?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final controller = DialogController(
      open: _isOpen,
      setOpen: _setOpen,
      groupId: _group,
    );
    return DialogScope(
      controller: controller,
      child: EdgePopup(
        open: _isOpen,
        onOpenChange: _setOpen,
        side: widget.direction,
        modal: widget.modal,
        dismissOnOutsideTap: widget.dismissible,
        dragToDismiss: widget.dismissible,
        groupId: _group,
        barrierLabel: 'Close',
        popupBuilder: (context) => DialogScope(
          controller: controller,
          child: DrawerScope(
            direction: widget.direction,
            child: widget.content,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
