import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The metrics and timings of [Stepper], from upstream
/// `src/components/ui/stepper.tsx`.
abstract final class StepperMetrics {
  /// `h-9 compact:h-8 calm:h-7`.
  static const ByDensity<double> height = ByDensity(
    comfortable: Spacing.d36,
    compact: Spacing.d32,
    calm: Spacing.d28,
  );

  /// A button's `m-[3px] calm:m-0.5`.
  static const ByDensity<double> buttonMargin = ByDensity(
    comfortable: Spacing.d3,
    compact: Spacing.d3,
    calm: Spacing.d2,
  );

  /// The minus and plus icons.
  static const double icon = Spacing.d18;

  /// The number's `w-16`.
  static const double inputWidth = Spacing.d64;

  /// The number's `px-1`.
  static const EdgeInsetsDirectional inputPadding =
      EdgeInsetsDirectional.symmetric(horizontal: Spacing.d4);

  /// The number's CSS size: `text-[1.65rem] calm:text-[1.35rem]`.
  static const ByDensity<double> cssFontSize = ByDensity(
    comfortable: 26.4,
    compact: 26.4,
    calm: 21.6,
  );

  /// `ll-swipe`'s `border-radius: 3px 8px 4px 9px / 8px 3px 9px 4px`.
  static const BorderRadius swipeRadius = BorderRadius.only(
    topLeft: Radius.elliptical(3, 8),
    topRight: Radius.elliptical(8, 3),
    bottomRight: Radius.elliptical(4, 9),
    bottomLeft: Radius.elliptical(9, 4),
  );

  /// `HOLD_DELAY`: how long a held button waits before repeating.
  static const Duration holdDelay = Duration(milliseconds: 420);

  /// `HOLD_EVERY`: the repeat interval.
  static const Duration holdEvery = Duration(milliseconds: 90);

  /// After this many repeats a held button steps five at a time.
  static const int holdSpeedUp = 24;

  /// `--ll-dur-toss`: the rattle at a bound.
  static const Duration rattle = Duration(milliseconds: 440);

  /// The tick slide: the number comes in from 38% of its height.
  static const double tickSlide = 0.38;

  /// The tick's starting opacity.
  static const double tickOpacity = 0.35;
}
