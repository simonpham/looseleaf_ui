import 'package:flutter/widgets.dart';

/// What a [ContextMenu] shares with its trigger: whether it is open and a
/// way to open it at a point.
class InkContextMenuController {
  const InkContextMenuController({
    required this.open,
    required this.openAt,
    required this.close,
  });

  /// Whether the menu is open.
  final bool open;

  /// Opens the menu at [globalPosition].
  final ValueChanged<Offset> openAt;

  /// Closes it.
  final VoidCallback close;
}

/// Hands a [InkContextMenuController] down to the trigger.
class InkContextMenuScope extends InheritedWidget {
  const InkContextMenuScope({
    super.key,
    required this.controller,
    required super.child,
  });

  /// The menu's controller.
  final InkContextMenuController controller;

  @override
  bool updateShouldNotify(InkContextMenuScope oldWidget) =>
      oldWidget.controller.open != controller.open;
}
