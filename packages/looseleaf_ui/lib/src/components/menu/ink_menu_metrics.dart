import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The sizes, type and colours of the menu parts shared by dropdown menus,
/// context menus and the menubar.
///
/// Mirrors upstream `src/lib/menu-styles.ts`.
abstract final class InkMenuMetrics {
  /// A row's least height: `min-h-8 compact:min-h-7 calm:min-h-7`.
  static const ByDensity<double> rowHeight = ByDensity(
    comfortable: Spacing.d32,
    compact: Spacing.d28,
    calm: Spacing.d28,
  );

  /// A row's vertical padding: `py-1 compact:py-0.5 calm:py-0.5`.
  static const ByDensity<double> rowPadding = ByDensity(
    comfortable: Spacing.d4,
    compact: Spacing.d2,
    calm: Spacing.d2,
  );

  /// A row's start and end padding (`ps-2.5 pe-2.5`).
  static const double rowInline = Spacing.d10;

  /// An inset row's start padding, in line with ticked rows (`ps-9`).
  static const double inset = Spacing.d36;

  /// The gap between a row's parts (`gap-2.5`).
  static const double rowGap = Spacing.d10;

  /// The viewport padding around the rows: `p-1 compact:p-0.5 calm:p-0.5`.
  static const ByDensity<double> viewportPadding = ByDensity(
    comfortable: Spacing.d4,
    compact: Spacing.d2,
    calm: Spacing.d2,
  );

  /// The slip's least width (`min-w-32`).
  static const double minWidth = Spacing.d128;

  /// The gap kept to the window's edges (`max-w-[calc(100vw-1rem)]`).
  static const double windowGap = Spacing.d16;

  /// A sub-menu's shift along its row, level with the opening row
  /// (`alignOffset` -4).
  static const double subAlignOffset = -Spacing.d4;

  /// The separator's vertical margin: `my-1.5 calm:my-1`.
  static const ByDensity<double> separatorMargin = ByDensity(
    comfortable: Spacing.d6,
    compact: Spacing.d6,
    calm: Spacing.d4,
  );

  /// The label's vertical padding: `py-1.5 calm:py-1`.
  static const ByDensity<double> labelPadding = ByDensity(
    comfortable: Spacing.d6,
    compact: Spacing.d6,
    calm: Spacing.d4,
  );

  /// The shortcut's start padding (`ps-4`).
  static const double shortcutGap = Spacing.d16;

  /// A keycap's height (`h-5`).
  static const double keycapHeight = Spacing.d20;

  /// The tick or dot box at a choice row's start (`size-4`).
  static const double indicator = Spacing.d16;

  /// The keyboard focus bar at a row's start edge (`inset 3px`).
  static const double focusBar = Spacing.d3;

  /// The highlighter swipe: upstream's `ll-swipe` radius,
  /// `3px 8px 4px 9px / 8px 3px 9px 4px`.
  static const BorderRadius swipe = BorderRadius.only(
    topLeft: Radius.elliptical(3, 8),
    topRight: Radius.elliptical(8, 3),
    bottomRight: Radius.elliptical(4, 9),
    bottomLeft: Radius.elliptical(9, 4),
  );

  /// A row's text: `font-hand text-base leading-6 calm:text-[15px]`.
  static TextStyle row(LooseleafThemeData theme, {Color? color}) =>
      theme.typography.face(
        KevinSansFace.hand,
        cssSize: switch (theme.density) {
          LooseleafDensity.calm => 15,
          _ => 16,
        },
        cssLineHeight: 24 / 16,
        color: color,
      );

  /// A label: `font-type text-sm tracking-wide text-ink-muted`.
  static TextStyle label(LooseleafThemeData theme) => theme.typography
      .face(
        KevinSansFace.type,
        cssSize: 14,
        cssLineHeight: 20 / 14,
        color: theme.colors.inkMuted,
      )
      .copyWith(letterSpacing: 0.025 * 14);
}
