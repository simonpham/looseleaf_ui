import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// [SelectTrigger] sizes, upstream's `size` prop.
enum SelectSize {
  /// `h-9 compact:h-8 calm:h-7`, `text-base` (15 px calm).
  regular,

  /// `h-8 compact:h-7 calm:h-7`, `text-[15px]`.
  sm;

  /// The trigger height per density.
  ByDensity<double> get height => switch (this) {
    SelectSize.regular => const ByDensity(
      comfortable: Spacing.d36,
      compact: Spacing.d32,
      calm: Spacing.d28,
    ),
    SelectSize.sm => const ByDensity(
      comfortable: Spacing.d32,
      compact: Spacing.d28,
      calm: Spacing.d28,
    ),
  };

  /// The CSS font size at [density].
  double cssFontSize(LooseleafDensity density) => switch ((this, density)) {
    (SelectSize.regular, LooseleafDensity.comfortable) ||
    (SelectSize.regular, LooseleafDensity.compact) => 16,
    _ => 15,
  };
}

/// Where a [SelectContent] opens, upstream's `position` prop.
enum SelectPosition {
  /// The chosen row lies over the trigger's value (Radix's default).
  itemAligned,

  /// Under (or over) the trigger, at least as wide as it.
  popper,
}

/// The metrics of the select parts, from the classes of upstream
/// `src/components/ui/select.tsx`.
abstract final class SelectMetrics {
  /// The trigger's `ps-3`.
  static const double triggerStart = Spacing.d12;

  /// The chevron cell's `w-8`.
  static const double cell = Spacing.d32;

  /// The chevron's `size={16}`.
  static const double chevron = Spacing.d16;

  /// The trigger's `gap-2` between value and cell.
  static const double triggerGap = Spacing.d8;

  /// The viewport's `p-1 compact:p-0.5 calm:p-0.5`.
  static const ByDensity<double> viewportPadding = ByDensity(
    comfortable: Spacing.d4,
    compact: Spacing.d2,
    calm: Spacing.d2,
  );

  /// An item's `min-h-8 compact:min-h-7 calm:min-h-7`.
  static const ByDensity<double> itemHeight = ByDensity(
    comfortable: Spacing.d32,
    compact: Spacing.d28,
    calm: Spacing.d28,
  );

  /// An item's `py-1.5 compact:py-1 calm:py-1`.
  static const ByDensity<double> itemVertical = ByDensity(
    comfortable: Spacing.d6,
    compact: Spacing.d4,
    calm: Spacing.d4,
  );

  /// An item's `ps-2 pe-8`: room for the tick at the end.
  static const EdgeInsetsDirectional itemInline = EdgeInsetsDirectional.only(
    start: Spacing.d8,
    end: Spacing.d32,
  );

  /// The tick's `end-2`.
  static const double tickEnd = Spacing.d8;

  /// A label's `px-2 py-1.5`.
  static const EdgeInsets labelPadding = EdgeInsets.symmetric(
    horizontal: Spacing.d8,
    vertical: Spacing.d6,
  );

  /// A separator's `my-1.5`; its `-mx-1` bleeds over the viewport's
  /// padding.
  static const double separatorGap = Spacing.d6;

  /// A scroll button's `py-1` around its 16 px chevron.
  static const double scrollButtonPadding = Spacing.d4;

  /// The list's least width (`min-w-32`).
  static const double contentMinWidth = Spacing.d128;

  /// Radix's `CONTENT_MARGIN`: how far an item-aligned list keeps from
  /// the window's edges.
  static const double margin = Spacing.d10;

  /// The popper list's gap to the trigger (`translate-y-1`).
  static const double popperOffset = Spacing.d4;

  /// The highlighted row's swipe: upstream's `ll-swipe` radius,
  /// `3px 8px 4px 9px / 8px 3px 9px 4px`.
  static const BorderRadius swipe = BorderRadius.only(
    topLeft: Radius.elliptical(3, 8),
    topRight: Radius.elliptical(8, 3),
    bottomRight: Radius.elliptical(4, 9),
    bottomLeft: Radius.elliptical(9, 4),
  );

  /// Trigger and item text: `font-hand text-base calm:text-[15px]`.
  static TextStyle text(
    LooseleafThemeData theme, {
    double cssSize = 16,
    Color? color,
    FontWeight fontWeight = FontWeight.w400,
  }) => theme.typography.face(
    KevinSansFace.hand,
    cssSize: switch (theme.density) {
      LooseleafDensity.calm => 15,
      _ => cssSize,
    },
    cssLineHeight: 1.5,
    fontWeight: fontWeight,
    color: color,
  );

  /// A [SelectLabel]: `font-type text-sm tracking-wide text-ink-muted`.
  static TextStyle labelStyle(LooseleafThemeData theme) => theme.typography
      .face(
        KevinSansFace.type,
        cssSize: 14,
        cssLineHeight: 20 / 14,
        color: theme.colors.inkMuted,
      )
      .copyWith(letterSpacing: 14 * 0.025);
}
