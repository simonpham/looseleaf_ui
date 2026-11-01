import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The metrics of the dialog parts, from the classes of upstream
/// `src/components/ui/dialog.tsx` (shared by the alert dialog, sheet and
/// drawer).
abstract final class DialogMetrics {
  /// Tailwind's `sm` breakpoint: narrower windows get the phone layout.
  static const double phoneBreakpoint = 640;

  /// Tailwind's `md` breakpoint.
  static const double tabletBreakpoint = 768;

  /// The sheet's widest: `max-w-lg`.
  static const double maxWidth = 512;

  /// The padding: `p-6 compact:p-5 calm:p-4`.
  static const ByDensity<double> padding = ByDensity(
    comfortable: Spacing.d24,
    compact: Spacing.d20,
    calm: Spacing.d16,
  );

  /// The gap between the content's parts: `gap-4`.
  static const double gap = Spacing.d16;

  /// The close mark's box: `size-8`.
  static const double closeSize = Spacing.d32;

  /// The close mark's inset from the corner: `end-3 top-3`.
  static const double closeInset = Spacing.d12;

  /// The body's tallest: `max-h-[min(60dvh,32rem)]`.
  static const double bodyMaxHeight = 512;

  /// The body's tallest share of the window.
  static const double bodyMaxFraction = 0.6;

  /// Whether the window is phone-sized.
  static bool phone(BuildContext context) =>
      (MediaQuery.maybeSizeOf(context)?.width ?? phoneBreakpoint) <
      phoneBreakpoint;

  /// The title: `font-script text-[1.7rem] leading-none font-semibold`.
  static TextStyle title(LooseleafThemeData theme) => theme.typography.face(
    KevinSansFace.script,
    cssSize: 27.2,
    cssLineHeight: 1,
    fontWeight: FontWeight.w600,
    color: theme.colors.ink,
  );

  /// The description: `text-sm text-muted-foreground`.
  static TextStyle description(LooseleafThemeData theme) =>
      theme.typography.face(
        KevinSansFace.hand,
        cssSize: 14,
        cssLineHeight: 20 / 14,
        color: theme.colors.inkMuted,
      );
}
