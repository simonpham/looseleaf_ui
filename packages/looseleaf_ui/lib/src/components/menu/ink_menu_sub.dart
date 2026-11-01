import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/menu/menu.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';

/// A nested menu: [trigger] (an [InkMenuSubTrigger]) opens [content] (an
/// [InkMenuSubContent]) beside it, on the end side (the left in
/// right-to-left).
///
/// Hovering the trigger opens it after a moment; Right (Left in
/// right-to-left), Enter or Space open it with its first row highlighted,
/// and Left closes it again with the highlight back on the trigger.
/// Highlighting another row of the parent closes it, and Escape closes the
/// whole menu. Open state is yours with [open] and [onOpenChange], or its
/// own starting at [defaultOpen].
///
/// Mirrors the `*MenuSub` parts of upstream `dropdown-menu.tsx`,
/// `context-menu.tsx` and `menubar.tsx` (Radix `Menu.Sub`).
class InkMenuSub extends StatefulWidget {
  const InkMenuSub({
    super.key,
    required this.trigger,
    required this.content,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
  });

  /// The row that opens it.
  final Widget trigger;

  /// The sub-menu's slip.
  final InkMenuSubContent content;

  /// Whether it is open; it keeps its own state when null.
  final bool? open;

  /// Whether it starts open, when [open] is null.
  final bool defaultOpen;

  /// Called when it asks to open or close.
  final ValueChanged<bool>? onOpenChange;

  @override
  State<InkMenuSub> createState() => InkMenuSubState();
}

/// The state of an [InkMenuSub], which its trigger and slip drive.
class InkMenuSubState extends State<InkMenuSub> {
  late bool _open = widget.defaultOpen;
  InkMenuLevel? _parent;
  InkMenuLevel? _child;

  /// The trigger row's focus node.
  final FocusNode triggerNode = FocusNode(debugLabel: 'InkMenuSubTrigger');

  /// Whether the slip highlights its first row when it opens.
  bool focusFirstOnOpen = false;

  /// Whether the sub-menu is open.
  bool get isOpen => widget.open ?? _open;

  /// The side the slip opens on: the reading end.
  OverlaySide get side => switch (Directionality.of(context)) {
    TextDirection.rtl => OverlaySide.left,
    TextDirection.ltr => OverlaySide.right,
  };

  /// Called by the slip when it mounts.
  void attach(InkMenuLevel level) => _child = level;

  /// Called by the slip when it goes.
  void detach(InkMenuLevel level) {
    if (identical(_child, level)) _child = null;
  }

  /// Opens the slip; [focusFirst] highlights its first row (also when it
  /// is already open).
  void show({bool focusFirst = false}) {
    if (isOpen) {
      if (focusFirst) _child?.edge(last: false);
      return;
    }
    focusFirstOnOpen = focusFirst;
    _set(true);
  }

  /// Closes the slip; [focusTrigger] puts the highlight back on the
  /// trigger.
  void close({bool focusTrigger = false}) {
    if (focusTrigger) {
      _parent?.viaKeys = true;
      triggerNode.requestFocus();
    }
    _set(false);
  }

  void _set(bool value) {
    if (value == isOpen || !mounted) return;
    if (widget.open == null) setState(() => _open = value);
    widget.onOpenChange?.call(value);
    _track(value);
  }

  void _track(bool open) {
    final parent = _parent;
    if (parent == null) return;
    if (open) {
      parent.openSub = this;
      return;
    }
    if (identical(parent.openSub, this)) parent.openSub = null;
  }

  @override
  void dispose() {
    _track(false);
    triggerNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final root = InkMenuRootScope.maybeOf(context);
    _parent = InkMenuLevelScope.maybeOf(context);
    _track(isOpen);
    final content = widget.content;
    final open = isOpen;
    return InkMenuSubScope(
      state: this,
      open: open,
      child: InkPopup(
        open: open,
        onOpenChange: (value) {
          if (!value) _set(false);
        },
        onDismiss: (reason) {
          if (reason == OverlayDismissReason.escape) root?.close();
        },
        side: side,
        align: OverlayAlign.start,
        sideOffset: content.sideOffset,
        alignOffset: content.alignOffset,
        autofocus: false,
        restoreFocus: false,
        dismissOnOutsideTap: false,
        groupId: root?.groupId,
        popupBuilder: (context, position) => InkMenuSubScope(
          state: this,
          open: open,
          child: InkMenuPositionScope(position: position, child: content),
        ),
        child: widget.trigger,
      ),
    );
  }
}

/// Hands the nearest [InkMenuSubState] to its trigger and slip.
class InkMenuSubScope extends InheritedWidget {
  const InkMenuSubScope({
    super.key,
    required this.state,
    required this.open,
    required super.child,
  });

  /// The sub-menu.
  final InkMenuSubState state;

  /// Whether it is open.
  final bool open;

  /// The nearest sub-menu.
  static InkMenuSubState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<InkMenuSubScope>();
    if (scope == null) throw FlutterError('No InkMenuSub above this widget.');
    return scope.state;
  }

  @override
  bool updateShouldNotify(InkMenuSubScope oldWidget) =>
      oldWidget.open != open || !identical(oldWidget.state, state);
}
