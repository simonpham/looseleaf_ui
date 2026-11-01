import 'package:flutter/widgets.dart';

/// What a dialog-like overlay ([Dialog], `AlertDialog`, `Sheet`, `Drawer`)
/// shares with its trigger, close buttons and content: whether it is open,
/// ways to change that, and the tap region group its trigger joins.
class DialogController {
  const DialogController({
    required this.open,
    required this.setOpen,
    required this.groupId,
  });

  /// Whether it is open.
  final bool open;

  /// Asks to open or close it.
  final ValueChanged<bool> setOpen;

  /// The tap region group of the trigger and the content.
  final Object groupId;

  /// Opens it.
  void show() => setOpen(true);

  /// Opens a closed one and closes an open one.
  void toggle() => setOpen(!open);

  /// Closes it.
  void close() => setOpen(false);
}

/// Hands a [DialogController] down to the trigger, the content and the
/// close buttons.
class DialogScope extends InheritedWidget {
  const DialogScope({
    super.key,
    required this.controller,
    required super.child,
  });

  /// The dialog's controller.
  final DialogController controller;

  /// The nearest controller, or null.
  static DialogController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DialogScope>()?.controller;

  /// The nearest controller.
  static DialogController of(BuildContext context) {
    final controller = maybeOf(context);
    if (controller == null) throw FlutterError('No Dialog above this widget.');
    return controller;
  }

  @override
  bool updateShouldNotify(DialogScope oldWidget) =>
      oldWidget.controller.open != controller.open ||
      oldWidget.controller.groupId != controller.groupId;
}

/// What a dialog's content tells its parts: whether a close mark sits in
/// the corner (the header keeps clear of it) and whether it is laid out for
/// a phone (stacked, centred).
class DialogContentScope extends InheritedWidget {
  const DialogContentScope({
    super.key,
    required this.closeMark,
    required this.phone,
    required super.child,
  });

  /// A close mark sits in the top corner.
  final bool closeMark;

  /// The window is narrower than [DialogMetrics.phoneBreakpoint].
  final bool phone;

  /// The nearest scope, or null outside a dialog's content.
  static DialogContentScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DialogContentScope>();

  @override
  bool updateShouldNotify(DialogContentScope oldWidget) =>
      oldWidget.closeMark != closeMark || oldWidget.phone != phone;
}
