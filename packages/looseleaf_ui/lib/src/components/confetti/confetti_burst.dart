import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/confetti/confetti_options.dart';

/// One burst in flight: the simulated [flights], where it leaves from and
/// when it started on its layer's clock.
///
/// The flights come from the engine's `simulate`, a frame every [stepMs];
/// a piece is shown between frames by linear interpolation, like upstream's
/// Web Animations keyframes.
class ConfettiBurst {
  ConfettiBurst({
    required this.flights,
    required this.started,
    required this.scalar,
    this.globalOrigin,
    this.onDone,
  }) : length = Duration(
         milliseconds:
             flights.fold(
               0,
               (longest, f) => math.max(longest, f.frames.length - 1),
             ) *
             stepMs,
       );

  /// Simulates a burst of [options] numbered [number] (its seed when the
  /// options give none), started at [started].
  factory ConfettiBurst.simulate(
    ConfettiOptions options, {
    required int number,
    required Duration started,
  }) {
    final count = math.min(400, math.max(0, options.count ?? 70));
    return ConfettiBurst(
      flights: simulate(
        FlightOptions(
          count: count,
          spread: options.spread ?? 70,
          angle: options.angle ?? 90,
          velocity: options.velocity ?? 1100,
          gravity: options.gravity ?? 520,
          drift: options.drift ?? 0,
          duration: (options.duration ?? defaultDuration).inMilliseconds
              .toDouble(),
          seed: options.seed ?? number,
        ),
        options.shapes ?? ConfettiKind.values,
        options.colors ?? ConfettiColor.values,
      ),
      started: started,
      scalar: options.scalar ?? 1,
      globalOrigin: options.origin,
      onDone: options.onDone,
    );
  }

  /// Upstream's default flight.
  static const Duration defaultDuration = Duration(milliseconds: 2600);

  final List<Flight> flights;

  /// When the burst started, on its layer's clock.
  final Duration started;

  /// Scales every piece.
  final double scalar;

  /// The requested origin in global coordinates; null is the center.
  final Offset? globalOrigin;
  final VoidCallback? onDone;

  /// How long the longest flight lasts.
  final Duration length;

  /// The origin in the layer's coordinates, once laid out.
  Offset? origin;

  /// Whether every piece has landed at [now].
  bool doneAt(Duration now) => now - started >= length;

  /// [flight]'s frame [elapsed] into the burst, or null once it has landed.
  static FlightFrame? frameAt(Flight flight, Duration elapsed) {
    final frames = flight.frames;
    final at = elapsed.inMicroseconds / 1000 / stepMs;
    if (at < 0 || at >= frames.length - 1) return null;
    final index = at.floor();
    final t = at - index;
    final a = frames[index];
    final b = frames[index + 1];
    double lerp(double from, double to) => from + (to - from) * t;
    return (
      x: lerp(a.x, b.x),
      y: lerp(a.y, b.y),
      rot: lerp(a.rot, b.rot),
      flip: lerp(a.flip, b.flip),
      opacity: lerp(a.opacity, b.opacity),
    );
  }
}
