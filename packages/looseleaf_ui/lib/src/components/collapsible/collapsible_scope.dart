import 'package:flutter/widgets.dart';

/// What a [Collapsible] hands its parts: whether it is open, whether the
/// user has toggled it yet, and how to toggle it.
///
/// Read it with `Collapsible.of(context)` to open and shut the panel from a
/// widget of your own, such as a [Button] (upstream's `asChild` trigger).
class CollapsibleScope extends InheritedWidget {
  const CollapsibleScope({
    super.key,
    required this.open,
    required this.disabled,
    required this.touched,
    required this.toggle,
    required super.child,
  });

  final bool open;
  final bool disabled;

  /// Whether the user has toggled it: draw-ons and the soak only play then
  /// (upstream `data-touched`).
  final bool touched;

  /// Opens a shut panel and shuts an open one; does nothing when
  /// [disabled].
  final VoidCallback toggle;

  @override
  bool updateShouldNotify(CollapsibleScope oldWidget) =>
      oldWidget.open != open ||
      oldWidget.disabled != disabled ||
      oldWidget.touched != touched ||
      oldWidget.toggle != toggle;
}
