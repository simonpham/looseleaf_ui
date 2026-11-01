import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The metrics of the combobox parts, from the classes of upstream
/// `src/components/ui/combobox.tsx` and the `command.tsx` rows it reuses.
abstract final class ComboboxMetrics {
  /// The trigger and field height: `h-9 compact:h-8 calm:h-7`.
  static const ByDensity<double> height = ByDensity(
    comfortable: Spacing.d36,
    compact: Spacing.d32,
    calm: Spacing.d28,
  );

  /// A row's least height: `min-h-9 compact:min-h-8 calm:min-h-7`.
  static const ByDensity<double> rowHeight = height;

  /// The search box height: `h-12 compact:h-10 calm:h-9`.
  static const ByDensity<double> searchHeight = ByDensity(
    comfortable: Spacing.d48,
    compact: Spacing.d40,
    calm: Spacing.d36,
  );

  /// A chip's height: `h-7 calm:h-6`.
  static double chipHeight(LooseleafDensity density) => switch (density) {
    LooseleafDensity.calm => Spacing.d24,
    _ => Spacing.d28,
  };

  /// A chip's start padding, clear of its punched hole: `ps-5 calm:ps-4`.
  static double chipStart(LooseleafDensity density) => switch (density) {
    LooseleafDensity.calm => Spacing.d16,
    _ => Spacing.d20,
  };

  /// The popup's least width (`min-w-52`).
  static const double contentMinWidth = 208;

  /// The popup's gap below its anchor (`sideOffset`).
  static const double sideOffset = Spacing.d6;

  /// The list's most height (`max-h-[min(20rem,…)]`).
  static const double listMaxHeight = 320;

  /// The highlighted row's swipe: upstream's `ll-swipe` radius,
  /// `3px 8px 4px 9px / 8px 3px 9px 4px`.
  static const BorderRadius swipe = BorderRadius.only(
    topLeft: Radius.elliptical(3, 8),
    topRight: Radius.elliptical(8, 3),
    bottomRight: Radius.elliptical(4, 9),
    bottomLeft: Radius.elliptical(9, 4),
  );

  /// The field text: `font-hand text-base calm:text-[15px]`.
  static TextStyle text(LooseleafThemeData theme, {Color? color}) =>
      theme.typography.face(
        KevinSansFace.hand,
        cssSize: switch (theme.density) {
          LooseleafDensity.calm => 15,
          _ => 16,
        },
        cssLineHeight: 1.5,
        color: color,
      );

  /// Group headings and [ComboboxLabel]: `font-type text-xs text-ink-muted`.
  static TextStyle heading(LooseleafThemeData theme) => theme.typography.face(
    KevinSansFace.type,
    cssSize: 12,
    cssLineHeight: 16 / 12,
    color: theme.colors.inkMuted,
  );

  /// Small hand text (`text-sm`), for chips and the loading row.
  static TextStyle small(
    LooseleafThemeData theme, {
    Color? color,
    FontWeight fontWeight = FontWeight.w400,
  }) => theme.typography.face(
    KevinSansFace.hand,
    cssSize: 14,
    cssLineHeight: 20 / 14,
    fontWeight: fontWeight,
    color: color,
  );
}
