import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// How an [InkItem] row is drawn.
///
/// Mirrors the `variant` of upstream `itemVariants`
/// (`src/components/ui/item.tsx`).
enum ItemVariant {
  /// Bare.
  regular,

  /// Ruled pencil edges around the row.
  outline,

  /// A paper-shade wash with rounded corners.
  muted,
}

/// An [InkItem]'s padding and gaps.
///
/// Mirrors the `size` of upstream `itemVariants`.
enum ItemSize {
  /// `gap-4 p-4 compact:p-3 calm:p-2.5`.
  regular,

  /// `gap-2.5 px-4 py-3 compact:px-3 compact:py-2.5 calm:py-2`.
  sm;

  /// The gap between media, content and actions.
  double get gap => switch (this) {
    ItemSize.regular => Spacing.d16,
    ItemSize.sm => Spacing.d10,
  };

  /// The row's padding at [density].
  EdgeInsets padding(LooseleafDensity density) => switch ((this, density)) {
    (ItemSize.regular, LooseleafDensity.comfortable) => const EdgeInsets.all(
      Spacing.d16,
    ),
    (ItemSize.regular, LooseleafDensity.compact) => const EdgeInsets.all(
      Spacing.d12,
    ),
    (ItemSize.regular, LooseleafDensity.calm) => const EdgeInsets.all(
      Spacing.d10,
    ),
    (ItemSize.sm, LooseleafDensity.comfortable) => const EdgeInsets.symmetric(
      horizontal: Spacing.d16,
      vertical: Spacing.d12,
    ),
    (ItemSize.sm, LooseleafDensity.compact) => const EdgeInsets.symmetric(
      horizontal: Spacing.d12,
      vertical: Spacing.d10,
    ),
    (ItemSize.sm, LooseleafDensity.calm) => const EdgeInsets.symmetric(
      horizontal: Spacing.d16,
      vertical: Spacing.d8,
    ),
  };
}

/// What an [ItemMedia] holds.
///
/// Mirrors upstream `itemMediaVariants`.
enum ItemMediaVariant {
  /// As given.
  regular,

  /// A 36 px shaded square in a pencil outline, the icon 16 px.
  icon,

  /// A 40 px photo, slightly turned, on a white mount.
  image,
}

/// Item metrics read from upstream's CSS.
abstract final class ItemMetrics {
  /// `ll-swipe`: the hovered link row's highlighter radius,
  /// `3px 8px 4px 9px / 8px 3px 9px 4px`.
  static const BorderRadius swipe = BorderRadius.only(
    topLeft: Radius.elliptical(Spacing.d3, Spacing.d8),
    topRight: Radius.elliptical(Spacing.d8, Spacing.d3),
    bottomRight: Radius.elliptical(Spacing.d4, Spacing.d10),
    bottomLeft: Radius.elliptical(Spacing.d10, Spacing.d4),
  );

  /// A muted row's corners (`border-radius: 6px`).
  static const BorderRadius muted = BorderRadius.all(
    Radius.circular(Spacing.d6),
  );
}
