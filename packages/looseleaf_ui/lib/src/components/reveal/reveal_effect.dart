import 'dart:ui';

import 'package:flutter/animation.dart';

/// Where a [RevealEffect] stands at one moment: opacity, offset, rotation
/// (radians) and scale, plus how wet the ink still looks (`soak`).
class RevealPose {
  const RevealPose({
    this.opacity = 1,
    this.offset = Offset.zero,
    this.rotation = 0,
    this.scale = 1,
    this.wet = 0,
  });

  final double opacity;
  final Offset offset;
  final double rotation;
  final double scale;

  /// 1 shows the ink in `--ll-wet-ink-from`, 0 in its own color.
  final double wet;

  /// The settled pose.
  static const RevealPose none = RevealPose();

  static RevealPose lerp(RevealPose a, RevealPose b, double t) => RevealPose(
    opacity: lerpDouble(a.opacity, b.opacity, t) ?? 1,
    offset: Offset.lerp(a.offset, b.offset, t) ?? Offset.zero,
    rotation: lerpDouble(a.rotation, b.rotation, t) ?? 0,
    scale: lerpDouble(a.scale, b.scale, t) ?? 1,
    wet: lerpDouble(a.wet, b.wet, t) ?? 0,
  );
}

const double _deg = 3.141592653589793 / 180;

/// How a [Reveal] brings its content in, with upstream's keyframes and
/// durations (`ll-wipe`, `ll-soak`, `ll-drop`, `ll-pop`, `ll-toss` in
/// `src/styles/looseleaf.css`).
enum RevealEffect {
  /// Wiped in from the reading start (`--ll-dur-draw`).
  wipe(Duration(milliseconds: 600), []),

  /// Soaks in like wet ink drying (`--ll-dur-soak`).
  soak(Duration(milliseconds: 520), [
    (0, RevealPose(opacity: 0.15, wet: 1)),
    (0.55, RevealPose(opacity: 0.9, wet: 0.45)),
    (1, RevealPose.none),
  ]),

  /// Dropped onto the page from above (`--ll-dur-drop`).
  drop(Duration(milliseconds: 340), [
    (
      0,
      RevealPose(
        opacity: 0,
        offset: Offset(0, -26),
        rotation: -2.4 * _deg,
        scale: 1.05,
      ),
    ),
    (
      0.62,
      RevealPose(offset: Offset(0, 2), rotation: 0.35 * _deg, scale: 0.995),
    ),
    (0.82, RevealPose(offset: Offset(0, -1), rotation: -0.1 * _deg)),
    (1, RevealPose.none),
  ]),

  /// Pops in with a little overshoot (`--ll-dur-pop`).
  pop(Duration(milliseconds: 180), [
    (0, RevealPose(opacity: 0, scale: 0.7, rotation: -6 * _deg)),
    (0.6, RevealPose(scale: 1.08, rotation: 1.5 * _deg)),
    (1, RevealPose.none),
  ]),

  /// Tossed onto the page from the lower right (`--ll-dur-toss`).
  toss(Duration(milliseconds: 440), [
    (
      0,
      RevealPose(
        opacity: 0,
        offset: Offset(46, 34),
        rotation: 14 * _deg,
        scale: 0.92,
      ),
    ),
    (
      0.6,
      RevealPose(offset: Offset(-2, -2), rotation: -1.5 * _deg, scale: 1.01),
    ),
    (1, RevealPose.none),
  ]);

  const RevealEffect(this.duration, this.keyframes);

  final Duration duration;

  /// Offset (0 → 1) to pose; empty for [wipe], which clips instead.
  final List<(double, RevealPose)> keyframes;

  /// The pose at [t] (0 → 1), each keyframe segment eased out like
  /// upstream's `var(--ll-ease-out)`.
  RevealPose poseAt(double t) {
    if (keyframes.isEmpty) return RevealPose.none;
    for (var i = 1; i < keyframes.length; i++) {
      final (from, a) = keyframes[i - 1];
      final (to, b) = keyframes[i];
      if (t > to) continue;
      final local = ((t - from) / (to - from)).clamp(0.0, 1.0);
      return RevealPose.lerp(a, b, _easeOut.transform(local));
    }
    return RevealPose.none;
  }

  static const Curve _easeOut = Cubic(0, 0, 0.58, 1);
}
