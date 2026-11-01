import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The metrics of the one-time-code parts, from upstream
/// `src/components/ui/input-otp.tsx`.
abstract final class InputOTPMetrics {
  /// The slot's `h-12 compact:h-10 calm:h-9`.
  static const ByDensity<double> slotHeight = ByDensity(
    comfortable: Spacing.d48,
    compact: Spacing.d40,
    calm: Spacing.d36,
  );

  /// The slot's `w-10 compact:w-9 calm:w-8`.
  static const ByDensity<double> slotWidth = ByDensity(
    comfortable: Spacing.d40,
    compact: Spacing.d36,
    calm: Spacing.d32,
  );

  /// The slot's CSS font size: `text-[1.75rem] calm:text-2xl`.
  static const ByDensity<double> cssFontSize = ByDensity(
    comfortable: 28,
    compact: 28,
    calm: 24,
  );

  /// A group's `gap-1.5 calm:gap-1`.
  static const ByDensity<double> groupGap = ByDensity(
    comfortable: Spacing.d6,
    compact: Spacing.d6,
    calm: Spacing.d4,
  );

  /// The row's `gap-3` between groups and separators.
  static const double gap = Spacing.d12;

  /// The separator's minus icon.
  static const double separatorIcon = Spacing.d20;

  /// The caret's `width: 9px; height: 1.6rem`.
  static const double caretWidth = 9;

  /// The caret's height.
  static const double caretHeight = 25.6;
}
