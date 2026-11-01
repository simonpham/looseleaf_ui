import 'dart:ui';

import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A [BadgeSize]'s box and typography, from the `size` variants of
/// `badgeVariants` in upstream `src/components/ui/badge.tsx`.
extension BadgeMetrics on BadgeSize {
  /// `h-*`, with the default size's `calm:h-5`.
  ByDensity<double> get height => switch (this) {
    BadgeSize.sm => const ByDensity.all(Spacing.d20),
    BadgeSize.regular => const ByDensity(
      comfortable: Spacing.d24,
      compact: Spacing.d24,
      calm: Spacing.d20,
    ),
    BadgeSize.lg => const ByDensity.all(Spacing.d28),
  };

  /// `BADGE_H`: the height tally marks are measured against, whatever the
  /// density.
  double get tallyHeight => switch (this) {
    BadgeSize.sm => Spacing.d20,
    BadgeSize.regular => Spacing.d24,
    BadgeSize.lg => Spacing.d28,
  };

  /// `px-*`.
  double get padding => switch (this) {
    BadgeSize.sm => Spacing.d8,
    BadgeSize.regular => Spacing.d10,
    BadgeSize.lg => Spacing.d12,
  };

  /// `has-[>svg]:ps-*`: the start padding before a leading icon.
  double get iconPadding => switch (this) {
    BadgeSize.sm => Spacing.d6,
    BadgeSize.regular => Spacing.d8,
    BadgeSize.lg => Spacing.d10,
  };

  /// `ICON_PX`.
  double get iconSize => switch (this) {
    BadgeSize.sm => Spacing.d12,
    BadgeSize.regular => Spacing.d14,
    BadgeSize.lg => Spacing.d16,
  };
}

/// A [BadgeVariant]'s label color, from the `variant` classes of upstream
/// `badgeVariants`.
extension BadgeColors on BadgeVariant {
  /// The label color; a hovered link turns `text-link-hover`.
  Color label(LooseleafColors colors, {required bool hovered}) =>
      switch ((this, hovered)) {
        (BadgeVariant.destructive, _) => colors.paper,
        (BadgeVariant.link, false) => colors.link,
        (BadgeVariant.link, true) => colors.linkHover,
        _ => colors.ink,
      };
}
