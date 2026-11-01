import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';
import 'package:looseleaf_ui/src/components/sheet/sheet.dart';

/// A page that slides in from an edge of the window: [content] (a
/// [SheetContent]) bound like a notebook along its inner edge, over the
/// dimmed app.
///
/// Open state is yours with [open] and [onOpenChange], or its own starting
/// at [defaultOpen]. Escape and a tap on the dim close it; focus moves
/// inside, Tab stays inside, and focus goes back to the trigger on close.
///
/// Mirrors `Sheet` in upstream `src/components/ui/sheet.tsx` (Radix
/// `Dialog.Root`).
class Sheet extends StatefulWidget {
  const Sheet({
    super.key,
    required this.content,
    required this.child,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.modal = true,
  });

  /// The page that slides in.
  final SheetContent content;

  /// The anchor, usually a [SheetTrigger].
  final Widget child;

  /// Whether it is open; it keeps its own state when null.
  final bool? open;

  /// Whether it starts open, when [open] is null.
  final bool defaultOpen;

  /// Called when it asks to open or close.
  final ValueChanged<bool>? onOpenChange;

  /// Dims and blocks the app and traps focus.
  final bool modal;

  @override
  State<Sheet> createState() => _SheetState();
}

class _SheetState extends State<Sheet> {
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
        side: widget.content.side,
        modal: widget.modal,
        groupId: _group,
        barrierLabel: 'Close',
        popupBuilder: (context) =>
            DialogScope(controller: controller, child: widget.content),
        child: widget.child,
      ),
    );
  }
}
