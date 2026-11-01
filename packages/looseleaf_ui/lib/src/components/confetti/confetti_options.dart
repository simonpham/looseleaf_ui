import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';

/// How a confetti burst flies; null fields take upstream's defaults.
///
/// Mirrors `ConfettiOptions` in upstream `src/components/ui/confetti.tsx`.
@immutable
class ConfettiOptions {
  const ConfettiOptions({
    this.origin,
    this.count,
    this.spread,
    this.angle,
    this.velocity,
    this.gravity,
    this.drift,
    this.duration,
    this.colors,
    this.shapes,
    this.scalar,
    this.seed,
    this.onDone,
  });

  /// Where the pieces leave from, in global coordinates; the layer's
  /// center when null.
  final Offset? origin;

  /// How many pieces, 0 to 400; 70 by default.
  final int? count;

  /// The launch cone in degrees; 70 by default, 360 throws a ring.
  final double? spread;

  /// The launch direction in degrees, 90 (up) by default.
  final double? angle;

  /// Launch speed in px/s; 1100 by default.
  final double? velocity;

  /// Fall in px/s²; 520 by default.
  final double? gravity;

  /// Sideways wind in px/s; none by default.
  final double? drift;

  /// The flight; 2.6 s by default.
  final Duration? duration;

  /// The colors pieces are cut from; all by default.
  final List<ConfettiColor>? colors;

  /// The piece shapes; all by default.
  final List<ConfettiKind>? shapes;

  /// Scales every piece; 1 by default.
  final double? scalar;

  /// Pins the burst; each burst gets the next number when null.
  final int? seed;

  /// Called once the last piece has landed.
  final VoidCallback? onDone;

  /// These options with [other]'s non-null fields over them.
  ConfettiOptions merge(ConfettiOptions? other) {
    if (other == null) return this;
    return ConfettiOptions(
      origin: other.origin ?? origin,
      count: other.count ?? count,
      spread: other.spread ?? spread,
      angle: other.angle ?? angle,
      velocity: other.velocity ?? velocity,
      gravity: other.gravity ?? gravity,
      drift: other.drift ?? drift,
      duration: other.duration ?? duration,
      colors: other.colors ?? colors,
      shapes: other.shapes ?? shapes,
      scalar: other.scalar ?? scalar,
      seed: other.seed ?? seed,
      onDone: other.onDone ?? onDone,
    );
  }
}
