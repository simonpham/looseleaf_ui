import 'package:flutter/widgets.dart';

/// What a [ResizablePanelGroup] hands a [ResizableHandle]: which seam it
/// is and how to move it.
class ResizableScope extends InheritedWidget {
  const ResizableScope({
    super.key,
    required this.axis,
    required this.disabled,
    required this.seam,
    required this.size,
    required this.min,
    required this.max,
    required this.moveBy,
    required this.moveTo,
    required super.child,
  });

  /// The group's direction: [Axis.horizontal] panels sit side by side.
  final Axis axis;
  final bool disabled;

  /// The seam's index: it sits after panel [seam].
  final int seam;

  /// The size of the panel before the seam, in percent.
  final double size;

  /// The smallest and largest that panel can be, given its neighbour.
  final double min;
  final double max;

  /// Moves the seam by a number of logical pixels.
  final ValueChanged<double> moveBy;

  /// Sets the panel before the seam to a size in percent.
  final ValueChanged<double> moveTo;

  static ResizableScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ResizableScope>();

  @override
  bool updateShouldNotify(ResizableScope oldWidget) =>
      oldWidget.axis != axis ||
      oldWidget.disabled != disabled ||
      oldWidget.seam != seam ||
      oldWidget.size != size ||
      oldWidget.min != min ||
      oldWidget.max != max;
}
