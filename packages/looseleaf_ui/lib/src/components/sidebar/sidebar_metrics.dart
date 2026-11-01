import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Sizes read from upstream `src/components/ui/sidebar.tsx`.
abstract final class SidebarMetrics {
  /// `SIDEBAR_WIDTH`, 16rem.
  static const double width = Spacing.d256;

  /// `SIDEBAR_WIDTH_MOBILE`, 18rem.
  static const double widthMobile = Spacing.d256 + Spacing.d32;

  /// `SIDEBAR_WIDTH_ICON`, 3rem.
  static const double widthIcon = Spacing.d48;

  /// `useIsMobile`'s `MOBILE_BREAKPOINT`: narrower windows get the sheet.
  static const double mobileBreakpoint = 768;

  /// The binder clip's width (`size={38}`).
  static const double clipSize = 38;

  /// How far a docked clip hangs above the pad (`-top-3.5`).
  static const double clipHang = Spacing.d14;

  /// Where a clip standing on the paper sits (`top-1`).
  static const double clipInside = Spacing.d4;

  /// The gutter above a docked pad (`pt-4`).
  static const double gutter = Spacing.d16;

  /// The pad's top padding under a hanging clip (`pt-6`).
  static const double clipPad = Spacing.d24;

  /// The pad's top padding under a standing clip (`pt-11`).
  static const double insideClipPad = Spacing.d44;

  /// The rail's width (`w-4`), half of it over the pad.
  static const double rail = Spacing.d16;

  /// A small row or group action (`w-6`).
  static const double action = Spacing.d24;

  /// The collapsed row (`size-8`).
  static const double iconRow = Spacing.d32;
}

/// A [SidebarMenuButtonSize]'s height and text, from
/// `sidebarMenuButtonVariants`.
extension SidebarMenuButtonMetrics on SidebarMenuButtonSize {
  /// `h-8 compact:h-7 calm:h-7`, `h-7`, `h-12`.
  ByDensity<double> get height => switch (this) {
    SidebarMenuButtonSize.regular => const ByDensity(
      comfortable: Spacing.d32,
      compact: Spacing.d28,
      calm: Spacing.d28,
    ),
    SidebarMenuButtonSize.sm => const ByDensity.all(Spacing.d28),
    SidebarMenuButtonSize.lg => const ByDensity.all(Spacing.d48),
  };

  /// `text-base`, `calm:text-[15px]`, `text-[15px]`.
  double cssFontSize(LooseleafDensity density) => switch ((this, density)) {
    (SidebarMenuButtonSize.sm, _) => 15,
    (SidebarMenuButtonSize.regular, LooseleafDensity.calm) => 15,
    _ => 16,
  };
}
