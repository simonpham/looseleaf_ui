import 'package:flutter/widgets.dart';

/// Scroll physics that settle a [CarouselContent] on one of its [snaps]
/// (in view lengths): the nearest one, or the next one along a fling.
class CarouselPhysics extends ScrollPhysics {
  const CarouselPhysics({required this.snaps, super.parent});

  /// The offsets the strip may rest on, as fractions of the view.
  final List<double> snaps;

  @override
  CarouselPhysics applyTo(ScrollPhysics? ancestor) =>
      CarouselPhysics(snaps: snaps, parent: buildParent(ancestor));

  double _target(ScrollMetrics position, double velocity, double tolerance) {
    final view = position.viewportDimension;
    final pixels = [for (final snap in snaps) snap * view];
    if (pixels.isEmpty) return position.pixels;
    final here = position.pixels;
    if (velocity > tolerance) {
      return pixels.firstWhere(
        (snap) => snap > here + 0.5,
        orElse: () => pixels.last,
      );
    }
    if (velocity < -tolerance) {
      return pixels.lastWhere(
        (snap) => snap < here - 0.5,
        orElse: () => pixels.first,
      );
    }
    var nearest = pixels.first;
    for (final snap in pixels) {
      if ((snap - here).abs() < (nearest - here).abs()) nearest = snap;
    }
    return nearest;
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    final atStart =
        velocity <= 0.0 && position.pixels <= position.minScrollExtent;
    final atEnd =
        velocity >= 0.0 && position.pixels >= position.maxScrollExtent;
    if (atStart || atEnd) {
      return super.createBallisticSimulation(position, velocity);
    }
    final tolerance = toleranceFor(position);
    final target = _target(position, velocity, tolerance.velocity);
    if (target == position.pixels) return null;
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      target,
      velocity,
      tolerance: tolerance,
    );
  }

  @override
  bool get allowImplicitScrolling => false;
}
