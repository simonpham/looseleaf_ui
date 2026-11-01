import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';

/// The control that opens a [Drawer]; a [DialogTrigger] (use
/// `DrawerTrigger.builder` around your own `Button`).
///
/// Mirrors `DrawerTrigger` in upstream `src/components/ui/drawer.tsx`.
typedef DrawerTrigger = DialogTrigger;

/// Anything that closes the nearest [Drawer]; a [DialogClose].
///
/// Mirrors `DrawerClose` in upstream `src/components/ui/drawer.tsx`.
typedef DrawerClose = DialogClose;

/// A drawer's name, in the script face at 27 px.
///
/// Mirrors `DrawerTitle` in upstream `src/components/ui/drawer.tsx`.
typedef DrawerTitle = DialogTitle;

/// What a drawer is for, in small muted ink.
///
/// Mirrors `DrawerDescription` in upstream `src/components/ui/drawer.tsx`.
typedef DrawerDescription = DialogDescription;

/// Tells a drawer's parts which window edge it is pulled from.
class DrawerScope extends InheritedWidget {
  const DrawerScope({super.key, required this.direction, required super.child});

  /// The edge the drawer hangs from.
  final OverlaySide direction;

  /// The nearest drawer's edge, bottom outside one.
  static OverlaySide directionOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DrawerScope>()?.direction ??
      OverlaySide.bottom;

  @override
  bool updateShouldNotify(DrawerScope oldWidget) =>
      oldWidget.direction != direction;
}
