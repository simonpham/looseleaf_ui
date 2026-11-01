import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';

/// A modal window: [content] (a [DialogContent], a sheet of paper) drops
/// onto the desk in the middle of the window, with a little turn that
/// settles, while the page behind dims under a lamp.
///
/// Open state is yours with [open] and [onOpenChange], or the dialog's own
/// starting at [defaultOpen]. Escape and a tap on the dim close it. Focus
/// moves inside on open, Tab cycles inside, and focus goes back to the
/// trigger on close. [modal] false drops the dim and lets the page stay
/// usable.
///
/// ```dart
/// Dialog(
///   content: const DialogContent(
///     children: [
///       DialogHeader(children: [DialogTitle(Text('Edit profile'))]),
///     ],
///   ),
///   child: DialogTrigger.builder(
///     builder: (context, dialog) => Button(
///       variant: ButtonVariant.outline,
///       onPressed: dialog.show,
///       child: const Text('Edit profile'),
///     ),
///   ),
/// )
/// ```
///
/// Mirrors `Dialog` in upstream `src/components/ui/dialog.tsx` (Radix
/// `Dialog.Root`).
class Dialog extends StatefulWidget {
  const Dialog({
    super.key,
    required this.content,
    required this.child,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.modal = true,
    this.dismissOnOutsideTap = true,
  });

  /// The sheet that drops in, usually a [DialogContent].
  final Widget content;

  /// The anchor, usually a [DialogTrigger].
  final Widget child;

  /// Whether it is open; the dialog keeps its own state when null.
  final bool? open;

  /// Whether it starts open, when [open] is null.
  final bool defaultOpen;

  /// Called when it asks to open or close.
  final ValueChanged<bool>? onOpenChange;

  /// Dims and blocks the page and traps focus.
  final bool modal;

  /// Whether a tap outside (on the dim) closes it.
  final bool dismissOnOutsideTap;

  /// The nearest dialog's controller.
  static DialogController of(BuildContext context) => DialogScope.of(context);

  @override
  State<Dialog> createState() => _DialogState();
}

class _DialogState extends State<Dialog> {
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
        motion: PopupMotionStyle.sheetDrop,
        modal: widget.modal,
        scrim: widget.modal,
        dismissOnOutsideTap: widget.dismissOnOutsideTap,
        groupId: _group,
        barrierLabel: 'Close',
        popupBuilder: (context, _) =>
            DialogScope(controller: controller, child: widget.content),
        child: widget.child,
      ),
    );
  }
}
