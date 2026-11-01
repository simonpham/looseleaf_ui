import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The metrics of the command parts, from the classes of upstream
/// `src/components/ui/command.tsx`.
abstract final class CommandMetrics {
  /// The search row: `h-12 compact:h-10 calm:h-9`.
  static const ByDensity<double> inputHeight = ByDensity(
    comfortable: Spacing.d48,
    compact: Spacing.d40,
    calm: Spacing.d36,
  );

  /// A row's least height: `min-h-9 compact:min-h-8 calm:min-h-7`.
  static const ByDensity<double> itemHeight = ByDensity(
    comfortable: Spacing.d36,
    compact: Spacing.d32,
    calm: Spacing.d28,
  );

  /// A row's `py-1.5 calm:py-1`.
  static const ByDensity<double> itemVertical = ByDensity(
    comfortable: Spacing.d6,
    compact: Spacing.d6,
    calm: Spacing.d4,
  );

  /// A row's `px-2`.
  static const double itemInline = Spacing.d8;

  /// The list's and a group's `p-1`.
  static const double inset = Spacing.d4;

  /// The list's `max-h-[300px]`.
  static const double listMaxHeight = 300;

  /// A group heading's `px-2 py-1.5`.
  static const EdgeInsets heading = EdgeInsets.symmetric(
    horizontal: Spacing.d8,
    vertical: Spacing.d6,
  );

  /// The highlighted row's swipe: upstream's `ll-swipe` radius,
  /// `3px 8px 4px 9px / 8px 3px 9px 4px`.
  static const BorderRadius swipe = BorderRadius.only(
    topLeft: Radius.elliptical(3, 8),
    topRight: Radius.elliptical(8, 3),
    bottomRight: Radius.elliptical(4, 9),
    bottomLeft: Radius.elliptical(9, 4),
  );

  /// Rows and the search: `font-hand text-base calm:text-[15px]`.
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

  /// Group headings: `font-type text-xs text-ink-muted`.
  static TextStyle headingStyle(LooseleafThemeData theme) =>
      theme.typography.face(
        KevinSansFace.type,
        cssSize: 12,
        cssLineHeight: 16 / 12,
        color: theme.colors.inkMuted,
      );

  /// The empty message: `font-script text-xl leading-tight text-ink-muted`.
  static TextStyle empty(LooseleafThemeData theme) => theme.typography.face(
    KevinSansFace.script,
    cssSize: 20,
    cssLineHeight: 1.25,
    color: theme.colors.inkMuted,
  );

  /// The loading line: `font-hand text-sm text-ink-muted`.
  static TextStyle small(LooseleafThemeData theme) => theme.typography.face(
    KevinSansFace.hand,
    cssSize: 14,
    cssLineHeight: 20 / 14,
    color: theme.colors.inkMuted,
  );
}
