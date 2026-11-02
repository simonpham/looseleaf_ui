import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';

/// Where a [TearOffStub] is on its way off: a shift, a turn (radians) and
/// its opacity.
///
/// Mirrors the `--tx`, `--ty`, `--rot` and `--tear` transform of
/// `TearOffStub` in upstream `src/components/ui/tear-off.tsx`.
@immutable
class TearOffPose {
  const TearOffPose({
    this.dx = 0,
    this.dy = 0,
    this.turn = 0,
    this.opacity = 1,
  });

  /// Attached, at rest.
  static const TearOffPose rest = TearOffPose();

  final double dx;
  final double dy;
  final double turn;
  final double opacity;

  /// `--tx0`, `--ty0`, `--rot0` scaled by a pull of [progress] (0 to 1).
  static TearOffPose pulled(
    double progress, {
    required Axis orientation,
    required TextDirection direction,
  }) {
    final (dx, dy, degrees) = _base(orientation, direction);
    return TearOffPose(
      dx: dx * progress,
      dy: dy * progress,
      turn: degrees * progress * math.pi / 180,
    );
  }

  /// The torn pose: three times as far, 28 px lower, turned 1.8 times as
  /// much, and faded out.
  static TearOffPose torn({
    required Axis orientation,
    required TextDirection direction,
  }) {
    final (dx, dy, degrees) = _base(orientation, direction);
    return TearOffPose(
      dx: dx * 3,
      dy: dy * 3 + 28,
      turn: degrees * 1.8 * math.pi / 180,
      opacity: 0,
    );
  }

  static (double, double, double) _base(
    Axis orientation,
    TextDirection direction,
  ) {
    final sign = switch (direction) {
      TextDirection.rtl => -1.0,
      TextDirection.ltr => 1.0,
    };
    return switch (orientation) {
      Axis.vertical => (0.0, 10.0, -14.0),
      Axis.horizontal => (8 * sign, 4.0, 14 * sign),
    };
  }

  /// The pose [t] of the way from [a] to [b]; [t] may overshoot.
  static TearOffPose lerp(TearOffPose a, TearOffPose b, double t) =>
      TearOffPose(
        dx: lerpDouble(a.dx, b.dx, t) ?? 0,
        dy: lerpDouble(a.dy, b.dy, t) ?? 0,
        turn: lerpDouble(a.turn, b.turn, t) ?? 0,
        opacity: (lerpDouble(a.opacity, b.opacity, t) ?? 1).clamp(0.0, 1.0),
      );

  @override
  bool operator ==(Object other) =>
      other is TearOffPose &&
      other.dx == dx &&
      other.dy == dy &&
      other.turn == turn &&
      other.opacity == opacity;

  @override
  int get hashCode => Object.hash(dx, dy, turn, opacity);
}
