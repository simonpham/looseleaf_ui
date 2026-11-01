import 'package:flutter/widgets.dart';

/// Tells a `ClipboardPaper` whether its clipboard has a height to fill.
class ClipboardScope extends InheritedWidget {
  const ClipboardScope({super.key, required this.fills, required super.child});

  /// Whether the clipboard has a least height the paper grows into.
  final bool fills;

  /// Whether the nearest clipboard has a height to fill.
  static bool fillsOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ClipboardScope>()?.fills ??
      false;

  @override
  bool updateShouldNotify(ClipboardScope oldWidget) => oldWidget.fills != fills;
}
