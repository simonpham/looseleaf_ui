import 'package:looseleaf_ui/src/theme/theme.dart';

/// An avatar's size, from the `data-size` classes of upstream
/// `src/components/ui/avatar.tsx`.
enum AvatarSize {
  /// `size-6`, `text-xs`, a 2 px badge-less dot, groups overlap by 4.
  sm(Spacing.d24, 12, 16 / 12, Spacing.d8, null, Spacing.d4),

  /// `size-8`, `text-sm`, groups overlap by 6.
  regular(Spacing.d32, 14, 20 / 14, Spacing.d10, Spacing.d8, Spacing.d6),

  /// `size-10`, `text-base`, groups overlap by 8.
  lg(Spacing.d40, 16, 1.5, Spacing.d12, Spacing.d8, Spacing.d8),

  /// `size-14`, `text-xl`, groups overlap by 14.
  xl(
    Spacing.d48 + Spacing.d8,
    20,
    28 / 20,
    Spacing.d14,
    Spacing.d10,
    Spacing.d14,
  );

  const AvatarSize(
    this.dimension,
    this.cssFontSize,
    this.cssLineHeight,
    this.badge,
    this.badgeIcon,
    this.overlap,
  );

  /// The avatar's side.
  final double dimension;

  /// The fallback's CSS font size.
  final double cssFontSize;
  final double cssLineHeight;

  /// The status badge's side.
  final double badge;

  /// The size of an icon inside the badge; null hides it (`sm`).
  final double? badgeIcon;

  /// How far each avatar in a group tucks under the one before it.
  final double overlap;

  /// The count disc's icon size in a group of this size.
  double get countIcon => switch (this) {
    sm => Spacing.d12,
    lg || xl => Spacing.d20,
    regular => Spacing.d16,
  };
}
