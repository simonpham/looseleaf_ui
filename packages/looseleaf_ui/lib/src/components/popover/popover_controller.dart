import 'package:flutter/widgets.dart';

/// What a [Popover] shares with its trigger and content: whether it is
/// open, ways to change that, and the tap region group the trigger joins so
/// tapping it does not count as outside.
class PopoverController {
  const PopoverController({
    required this.open,
    required this.setOpen,
    required this.groupId,
  });

  /// Whether the popover is open.
  final bool open;

  /// Asks to open or close it.
  final ValueChanged<bool> setOpen;

  /// The tap region group of the trigger and the content.
  final Object groupId;

  /// Opens a closed popover and closes an open one.
  void toggle() => setOpen(!open);

  /// Closes it.
  void close() => setOpen(false);
}

/// Hands a [PopoverController] down to the trigger and content.
class PopoverScope extends InheritedWidget {
  const PopoverScope({
    super.key,
    required this.controller,
    required super.child,
  });

  /// The popover's controller.
  final PopoverController controller;

  @override
  bool updateShouldNotify(PopoverScope oldWidget) =>
      oldWidget.controller.open != controller.open ||
      oldWidget.controller.groupId != controller.groupId;
}
