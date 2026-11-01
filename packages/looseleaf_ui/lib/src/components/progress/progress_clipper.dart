import 'package:flutter/widgets.dart';

/// Clips a progress fill to the window from [start] to [end] (fractions of
/// the width, from the reading start), with [bleed] of room above and below:
/// upstream's `clip-path: inset(-12px …)` on the indicator.
class ProgressClipper extends CustomClipper<Rect> {
  const ProgressClipper({
    required this.start,
    required this.end,
    required this.direction,
    this.bleed = 12,
  });

  final double start;
  final double end;
  final TextDirection direction;
  final double bleed;

  @override
  Rect getClip(Size size) {
    final (left, right) = switch (direction) {
      TextDirection.ltr => (start, end),
      TextDirection.rtl => (1 - end, 1 - start),
    };
    return Rect.fromLTRB(
      size.width * left,
      -bleed,
      size.width * right,
      size.height + bleed,
    );
  }

  @override
  bool shouldReclip(ProgressClipper oldClipper) =>
      oldClipper.start != start ||
      oldClipper.end != end ||
      oldClipper.direction != direction ||
      oldClipper.bleed != bleed;
}
