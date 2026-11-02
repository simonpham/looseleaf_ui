import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';

/// A question that interrupts: [content] (an [AlertDialogContent]) drops
/// onto the dimmed page like a [Dialog], but only its answers close it: a
/// tap on the dim does nothing, Escape cancels, and focus starts on
/// [AlertDialogCancel].
///
/// Open state is yours with [open] and [onOpenChange], or its own starting
/// at [defaultOpen].
///
/// Mirrors `AlertDialog` in upstream `src/components/ui/alert-dialog.tsx`
/// (Radix `AlertDialog.Root`).
class AlertDialog extends StatefulWidget {
  const AlertDialog({
    super.key,
    required this.content,
    required this.child,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
  });

  /// The question, usually an [AlertDialogContent].
  final Widget content;

  /// The anchor, usually an [AlertDialogTrigger].
  final Widget child;

  /// Whether it is open; it keeps its own state when null.
  final bool? open;

  /// Whether it starts open, when [open] is null.
  final bool defaultOpen;

  /// Called when it asks to open or close.
  final ValueChanged<bool>? onOpenChange;

  @override
  State<AlertDialog> createState() => _AlertDialogState();
}

class _AlertDialogState extends State<AlertDialog> {
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
      child: InkPopup(
        open: _isOpen,
        onOpenChange: _setOpen,
        centered: true,
        placement: DialogMetrics.placement(context),
        motion: DialogMetrics.motion(context),
        modal: true,
        scrim: true,
        dismissOnOutsideTap: false,
        groupId: _group,
        popupBuilder: (context, _) =>
            DialogScope(controller: controller, child: widget.content),
        child: widget.child,
      ),
    );
  }
}
