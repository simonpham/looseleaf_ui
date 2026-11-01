import 'package:flutter/animation.dart';

/// Looseleaf's motion tokens (`--ll-dur-*`, `--ll-ease-*`).
abstract final class InkMotion {
  static const Duration press = Duration(milliseconds: 90);
  static const Duration hover = Duration(milliseconds: 120);
  static const Duration fade = Duration(milliseconds: 150);
  static const Duration pop = Duration(milliseconds: 180);

  /// CSS `ease-out`.
  static const Curve easeOut = Cubic(0, 0, 0.58, 1);

  /// `--ll-ease-settle`, a slight overshoot.
  static const Curve settle = Cubic(0.2, 0.9, 0.25, 1.12);

  /// `--ll-ease-pop`, the check mark's overshoot.
  static const Curve popCurve = Cubic(0.2, 0.9, 0.3, 1.15);

  /// `--ll-hover-tilt` in radians (-0.9deg).
  static const double hoverTilt = -0.9 * 3.141592653589793 / 180;

  /// `--ll-hover-misreg`.
  static const double hoverMisregister = 0.35;

  /// `--ll-press-misreg`.
  static const double pressMisregister = -0.78;

  /// `--ll-press-sink` in px.
  static const double pressSink = 1;

  /// The hidden scale of `checked` / `indeterminate` layers.
  static const double popScale = 0.9;

  /// The hidden rotation of `checked` / `indeterminate` layers (-3deg).
  static const double popRotation = -3 * 3.141592653589793 / 180;
}
