import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// [Toggle] and [ToggleGroupItem] sizes, the `size` variants of upstream
/// `toggleVariants` (`src/components/ui/toggle.tsx`).
enum ToggleSize {
  /// `h-9 min-w-9 px-2 text-base`.
  regular,

  /// `h-8 min-w-8 px-1.5 text-[15px]`.
  sm,

  /// `h-10 min-w-10 px-2.5 text-[17px]`.
  lg;

  /// `h-*` and `min-w-*`, with their `compact:` / `calm:` steps.
  ByDensity<double> get height => switch (this) {
    ToggleSize.regular => const ByDensity(
      comfortable: Spacing.d36,
      compact: Spacing.d32,
      calm: Spacing.d28,
    ),
    ToggleSize.sm => const ByDensity(
      comfortable: Spacing.d32,
      compact: Spacing.d28,
      calm: Spacing.d28,
    ),
    ToggleSize.lg => const ByDensity(
      comfortable: Spacing.d40,
      compact: Spacing.d36,
      calm: Spacing.d32,
    ),
  };

  /// `px-*`.
  double get padding => switch (this) {
    ToggleSize.regular => Spacing.d8,
    ToggleSize.sm => Spacing.d6,
    ToggleSize.lg => Spacing.d10,
  };

  /// The CSS font size.
  double get cssFontSize => switch (this) {
    ToggleSize.regular => 16,
    ToggleSize.sm => 15,
    ToggleSize.lg => 17,
  };

  /// The CSS line height: `text-base` sets 1.5, the arbitrary sizes keep
  /// the body's.
  double? get cssLineHeight => switch (this) {
    ToggleSize.regular => 1.5,
    _ => null,
  };
}
