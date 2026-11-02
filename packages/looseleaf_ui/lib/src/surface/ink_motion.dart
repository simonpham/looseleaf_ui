import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Looseleaf's motion tokens (`--ll-dur-*`, `--ll-ease-*`).
abstract final class InkMotion {
  static const Duration press = Duration(milliseconds: 90);
  static const Duration hover = Duration(milliseconds: 120);
  static const Duration fade = Duration(milliseconds: 150);
  static const Duration pop = Duration(milliseconds: 180);

  /// `--ll-dur-sheet`: the `swipe` wipe and a control's `reveal` draw-on
  /// (a checkbox tick).
  static const Duration sheet = Duration(milliseconds: 300);

  /// `--ll-dur-draw`: a mark drawing itself on (`ll-draw`, `ll-wipe`).
  static const Duration draw = Duration(milliseconds: 600);

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

  /// Whether motion is off here: the theme says [LooseleafMotion.reduced]
  /// or the platform asks to reduce motion (`--ll-motion: 0`).
  static bool reducedIn(BuildContext context) =>
      LooseleafTheme.of(context).motion == LooseleafMotion.reduced ||
      (MediaQuery.maybeDisableAnimationsOf(context) ?? false);

  /// [duration], or zero where motion is reduced.
  static Duration of(BuildContext context, Duration duration) =>
      switch (reducedIn(context)) {
        true => Duration.zero,
        false => duration,
      };

  /// The hidden rotation of `checked` / `indeterminate` layers (-3deg).
  static const double popRotation = -3 * 3.141592653589793 / 180;
}
