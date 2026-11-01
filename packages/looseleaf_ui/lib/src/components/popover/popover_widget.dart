import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/components/popover/popover.dart';

/// A note that pops up beside its trigger: [content] (a [PopoverContent])
/// on a slip of paper, anchored to [child] (usually a [PopoverTrigger]).
///
/// Open state is yours with [open] and [onOpenChange], or the popover's own
/// starting at [defaultOpen]. It closes on Escape, a tap outside, or focus
/// moving out. Focus moves into it on open and back to the trigger on close.
/// [modal] blocks the rest of the app and keeps Tab inside.
///
/// ```dart
/// Popover(
///   content: const PopoverContent(child: Text('Hello')),
///   child: PopoverTrigger.builder(
///     builder: (context, popover) => Button(
///       variant: ButtonVariant.outline,
///       onPressed: popover.toggle,
///       child: const Text('Open popover'),
///     ),
///   ),
/// )
/// ```
///
/// Mirrors `Popover` in upstream `src/components/ui/popover.tsx` (Radix
/// `Popover.Root`).
class Popover extends StatefulWidget {
  const Popover({
    super.key,
    required this.content,
    required this.child,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.modal = false,
  });

  /// What pops up.
  final PopoverContent content;

  /// The anchor; a [PopoverTrigger] or anything reading [Popover.of].
  final Widget child;

  /// Whether it is open; the popover keeps its own state when null.
  final bool? open;

  /// Whether it starts open, when [open] is null.
  final bool defaultOpen;

  /// Called when it asks to open or close.
  final ValueChanged<bool>? onOpenChange;

  /// Blocks the app below and keeps focus inside.
  final bool modal;

  /// The nearest popover's controller.
  static PopoverController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PopoverScope>();
    if (scope == null) throw FlutterError('No Popover above this widget.');
    return scope.controller;
  }

  /// The nearest popover's controller, or null.
  static PopoverController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PopoverScope>()?.controller;

  @override
  State<Popover> createState() => _PopoverState();
}

class _PopoverState extends State<Popover> {
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
    final content = widget.content;
    final controller = PopoverController(
      open: _isOpen,
      setOpen: _setOpen,
      groupId: _group,
    );
    return PopoverScope(
      controller: controller,
      child: InkPopup(
        open: _isOpen,
        onOpenChange: _setOpen,
        side: content.side,
        align: content.align,
        sideOffset: content.sideOffset + content.pointerReach,
        alignOffset: content.alignOffset,
        collisionPadding: content.collisionPadding,
        avoidCollisions: content.avoidCollisions,
        modal: widget.modal,
        dismissOnFocusOutside: !widget.modal,
        groupId: _group,
        popupBuilder: (context, position) => PopoverScope(
          controller: controller,
          child: PopoverContentScope(position: position, child: content),
        ),
        child: widget.child,
      ),
    );
  }
}
