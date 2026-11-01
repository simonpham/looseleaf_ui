import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart' as ink;
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The drawing context paper pieces share: the engine tier, calm density and
/// the tilt budget (`--ll-tilt-max`), read from the ambient theme.
abstract final class PaperInk {
  /// `--ll-tilt-max` in degrees: 2, none at calm density.
  static double tiltMax(LooseleafThemeData theme) => switch (theme.density) {
    LooseleafDensity.calm => 0,
    _ => 2,
  };

  /// Whether the theme is at calm density.
  static bool calm(LooseleafThemeData theme) =>
      theme.density == LooseleafDensity.calm;

  /// The engine tier ink is drawn at.
  static ink.Tier tier(LooseleafThemeData theme) =>
      switch (theme.effectiveTier) {
        LooseleafTier.lo => ink.Tier.lo,
        LooseleafTier.hi => ink.Tier.hi,
      };

  /// [degrees] clamped to [factor] times the tilt budget, in radians, like
  /// upstream's `rotate: clamp(calc(var(--ll-tilt-max) * -k), …)`.
  static double tilt(
    BuildContext context,
    double degrees, {
    double factor = 1,
  }) {
    final max = tiltMax(LooseleafTheme.of(context)) * factor;
    return degrees.clamp(-max, max) * math.pi / 180;
  }
}
