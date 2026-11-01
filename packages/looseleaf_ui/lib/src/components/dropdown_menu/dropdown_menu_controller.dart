import 'package:flutter/widgets.dart';

/// What a [DropdownMenu] shares with its trigger: whether it is open, ways
/// to change that, and the tap region group the trigger joins.
class DropdownMenuController {
  const DropdownMenuController({
    required this.open,
    required this.setOpen,
    required this.groupId,
    required this.pointerDown,
  });

  /// Whether the menu is open.
  final bool open;

  /// Asks to open or close it; [focusFirst] highlights the first row.
  final void Function(bool open, {bool focusFirst}) setOpen;

  /// The tap region group of the trigger and the slips.
  final Object groupId;

  /// Tells the menu a pointer went down on the trigger, so the next
  /// [toggle] came from the pointer, not the keyboard.
  final VoidCallback pointerDown;

  /// Opens a closed menu (with the first row highlighted when the keyboard
  /// asked) and closes an open one.
  void toggle() => setOpen(!open, focusFirst: true);

  /// Closes it.
  void close() => setOpen(false);
}

/// Hands a [DropdownMenuController] down to the trigger.
class DropdownMenuScope extends InheritedWidget {
  const DropdownMenuScope({
    super.key,
    required this.controller,
    required super.child,
  });

  /// The menu's controller.
  final DropdownMenuController controller;

  @override
  bool updateShouldNotify(DropdownMenuScope oldWidget) =>
      oldWidget.controller.open != controller.open ||
      oldWidget.controller.groupId != controller.groupId;
}
