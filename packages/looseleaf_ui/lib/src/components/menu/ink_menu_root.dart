import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';

/// Where a menu's slip goes when its content does not say: each kind of
/// menu has its own (a dropdown hangs 6 px under its button, a context
/// menu sits at the pointer, a menubar menu lines up with its trigger).
class InkMenuPlacement {
  const InkMenuPlacement({
    this.side = OverlaySide.bottom,
    this.align = OverlayAlign.center,
    this.sideOffset = 0,
    this.alignOffset = 0,
    this.minWidth,
  });

  /// The side of the trigger it opens on.
  final OverlaySide side;

  /// How it lines up with the trigger.
  final OverlayAlign align;

  /// The gap to the trigger.
  final double sideOffset;

  /// A shift along the side.
  final double alignOffset;

  /// The least width; the menu metrics' when null.
  final double? minWidth;
}

/// What every level of one open menu shares: how to close the whole menu,
/// the tap region group of its trigger and slips, whether the keyboard
/// opened it (so the first row is highlighted), and where horizontal arrows
/// that leave the menu go (the menubar's next menu).
class InkMenuRootData {
  const InkMenuRootData({
    required this.close,
    required this.groupId,
    this.placement = const InkMenuPlacement(),
    this.focusFirst = false,
    this.onArrowOut,
  });

  /// Closes the menu and every sub-menu.
  final VoidCallback close;

  /// The tap region group of the trigger and every slip.
  final Object groupId;

  /// The menu kind's default placement.
  final InkMenuPlacement placement;

  /// Highlights the first row on open.
  final bool focusFirst;

  /// Called with -1 or 1 (in reading order) when a horizontal arrow leaves
  /// the top level; null keeps the arrows inside.
  final ValueChanged<int>? onArrowOut;
}

/// Hands [InkMenuRootData] to every part of an open menu.
class InkMenuRootScope extends InheritedWidget {
  const InkMenuRootScope({super.key, required this.data, required super.child});

  /// The menu's shared data.
  final InkMenuRootData data;

  /// The nearest open menu's data, or null outside one.
  static InkMenuRootData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InkMenuRootScope>()?.data;

  @override
  bool updateShouldNotify(InkMenuRootScope oldWidget) =>
      oldWidget.data.focusFirst != data.focusFirst ||
      oldWidget.data.groupId != data.groupId ||
      oldWidget.data.placement != data.placement;
}
