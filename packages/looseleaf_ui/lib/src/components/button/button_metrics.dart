import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A [ButtonSize]'s box and typography, from the `size` variants of
/// `buttonVariants` in upstream `src/components/ui/button.tsx`.
extension ButtonMetrics on ButtonSize {
  /// Whether the button is a square holding only an icon.
  bool get isIcon => switch (this) {
    ButtonSize.icon ||
    ButtonSize.iconXs ||
    ButtonSize.iconSm ||
    ButtonSize.iconLg => true,
    _ => false,
  };

  /// `h-*` (or `size-*` for icon buttons) with its `compact:` / `calm:` steps.
  ByDensity<double> get height => switch (this) {
    ButtonSize.regular || ButtonSize.icon => const ByDensity(
      comfortable: Spacing.d36,
      compact: Spacing.d32,
      calm: Spacing.d28,
    ),
    ButtonSize.xs || ButtonSize.iconXs => const ByDensity.all(Spacing.d24),
    ButtonSize.sm || ButtonSize.iconSm => const ByDensity(
      comfortable: Spacing.d32,
      compact: Spacing.d28,
      calm: Spacing.d28,
    ),
    ButtonSize.lg || ButtonSize.iconLg => const ByDensity(
      comfortable: Spacing.d40,
      compact: Spacing.d36,
      calm: Spacing.d32,
    ),
  };

  /// The inline padding: `px-*`, or `has-[>svg]:px-*` when [withIcon].
  double padding({required bool withIcon}) => switch ((this, withIcon)) {
    (ButtonSize.regular, false) => Spacing.d16,
    (ButtonSize.regular, true) => Spacing.d12,
    (ButtonSize.xs, false) => Spacing.d8,
    (ButtonSize.xs, true) => Spacing.d6,
    (ButtonSize.sm, false) => Spacing.d12,
    (ButtonSize.sm, true) => Spacing.d10,
    (ButtonSize.lg, false) => Spacing.d24,
    (ButtonSize.lg, true) => Spacing.d16,
    _ => 0,
  };

  /// `gap-*` between icons and the label.
  double get gap => switch (this) {
    ButtonSize.xs => Spacing.d4,
    ButtonSize.sm => Spacing.d6,
    _ => Spacing.d8,
  };

  /// `[&_svg]:size-4`, `size-3` in the xs sizes.
  double get iconSize => switch (this) {
    ButtonSize.xs || ButtonSize.iconXs => Spacing.d12,
    _ => Spacing.d16,
  };

  /// The CSS font size: `text-base`, `text-sm`, `text-[15px]`, `text-[17px]`;
  /// icon buttons inherit the body's.
  double? get cssFontSize => switch (this) {
    ButtonSize.regular => 16,
    ButtonSize.xs => 14,
    ButtonSize.sm => 15,
    ButtonSize.lg => 17,
    _ => null,
  };

  /// The CSS line height: Tailwind's `text-base` and `text-sm` set one, the
  /// arbitrary sizes inherit the body's.
  double? get cssLineHeight => switch (this) {
    ButtonSize.regular => 1.5,
    ButtonSize.xs => 20 / 14,
    _ => null,
  };
}
