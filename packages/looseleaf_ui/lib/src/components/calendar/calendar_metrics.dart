import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The metrics of a [Calendar], from the classes in upstream
/// `src/components/ui/calendar.tsx` and the masks of `calendarCss`.
abstract final class CalendarMetrics {
  /// `--cell`: a day's side, `compact:` and `calm:` steps included.
  static const ByDensity<double> cell = ByDensity(
    comfortable: Spacing.d40,
    compact: Spacing.d34,
    calm: Spacing.d30,
  );

  /// `--wn`: the week-number column.
  static const double weekNumber = Spacing.d32;

  /// `p-3`, `calm:p-2`.
  static const ByDensity<double> padding = ByDensity(
    comfortable: Spacing.d12,
    compact: Spacing.d12,
    calm: Spacing.d8,
  );

  /// The weekday header's `h-7`.
  static const double head = Spacing.d28;

  /// `gap-5` between months.
  static const double monthGap = Spacing.d20;

  /// The day button's `m-[3px]` inside its cell.
  static const double dayInset = Spacing.d3;

  /// The week number's `pe-2`.
  static const double weekNumberEnd = Spacing.d8;

  /// The footer's `mt-2`.
  static const double footerGap = Spacing.d8;

  /// The range band's `inset: 6px 0`.
  static const double bandInset = Spacing.d6;

  /// The ring's `inset: -3px` around the day button.
  static const double ringReach = Spacing.d3;

  /// The hatch's `inset: 3px` inside the day button.
  static const double hatchInset = Spacing.d3;

  /// The focus loop's `inset: -8px` around the cell.
  static const double focusReach = Spacing.d8;

  /// The nav buttons' `size="icon-sm"` chevrons.
  static const double chevron = Spacing.d16;

  /// The dropdown's chevron, `size={14}`.
  static const double dropdownChevron = Spacing.d14;

  /// The dropdowns' `gap-2.5`.
  static const double dropdownGap = Spacing.d10;

  /// The dropdown box: `h-8 calm:h-7`.
  static const ByDensity<double> dropdownHeight = ByDensity(
    comfortable: Spacing.d32,
    compact: Spacing.d32,
    calm: Spacing.d28,
  );

  /// The select's `ps-2.5 pe-7`.
  static const EdgeInsetsDirectional dropdownPadding =
      EdgeInsetsDirectional.only(start: Spacing.d10, end: Spacing.d28);

  /// The chevron's `end-1.5`.
  static const double dropdownChevronEnd = Spacing.d6;

  /// The hover wash's `border-radius: 3px 8px 4px 9px / 8px 3px 9px 4px`.
  static const BorderRadius hoverRadius = BorderRadius.only(
    topLeft: Radius.elliptical(Spacing.d3, Spacing.d8),
    topRight: Radius.elliptical(Spacing.d8, Spacing.d3),
    bottomRight: Radius.elliptical(Spacing.d4, Spacing.d9),
    bottomLeft: Radius.elliptical(Spacing.d9, Spacing.d4),
  );

  /// The caption label: `text-[1.65rem] calm:text-[1.4rem]`.
  static double captionSize(LooseleafDensity density) => switch (density) {
    LooseleafDensity.calm => 22.4,
    _ => 26.4,
  };

  /// The day number: `text-[1.3rem] compact:text-[1.2rem]
  /// calm:text-[1.05rem]`.
  static double daySize(LooseleafDensity density) => switch (density) {
    LooseleafDensity.comfortable => 20.8,
    LooseleafDensity.compact => 19.2,
    LooseleafDensity.calm => 16.8,
  };

  /// The weekday head: `text-[0.78rem]`.
  static const double weekdaySize = 12.48;

  /// The week number: `text-xs`.
  static const double weekNumberSize = 12;

  /// The dropdown's `text-[1.15rem]`.
  static const double dropdownSize = 18.4;

  /// The footer's `text-sm`.
  static const double footerSize = 14;
}
