import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_dates.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_dropdown.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_formatters.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_metrics.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_mode.dart';
import 'package:looseleaf_ui/src/components/native_select/native_select.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The caption over one month of a [Calendar]: the month and year in
/// script, or month / year [CalendarDropdown]s, as [layout] asks.
///
/// The label is a polite live region, so paging announces the month.
///
/// Mirrors the `month_caption`, `caption_label` and `dropdowns` parts of
/// upstream `src/components/ui/calendar.tsx`.
class CalendarCaption extends StatelessWidget {
  const CalendarCaption({
    super.key,
    required this.month,
    required this.startMonth,
    required this.endMonth,
    required this.onMonthChange,
    required this.seed,
    this.layout = CalendarCaptionLayout.label,
    this.formatters = const CalendarFormatters(),
  });

  /// The month shown.
  final DateTime month;

  /// The first month the dropdowns offer.
  final DateTime startMonth;

  /// The last month the dropdowns offer.
  final DateTime endMonth;

  /// Called with the month a dropdown picks.
  final ValueChanged<DateTime> onMonthChange;

  /// Pins the dropdown boxes.
  final String seed;

  final CalendarCaptionLayout layout;
  final CalendarFormatters formatters;

  bool _inBounds(DateTime candidate) =>
      !candidate.isBefore(CalendarDates.month(startMonth)) &&
      !candidate.isAfter(CalendarDates.month(endMonth));

  Widget _label(LooseleafThemeData theme, String text) => Text(
    text,
    maxLines: 1,
    style: theme.typography.face(
      KevinSansFace.script,
      cssSize: CalendarMetrics.captionSize(theme.density),
      cssLineHeight: 1,
      fontWeight: FontWeight.w600,
      color: theme.colors.ink,
    ),
  );

  Widget _months() => CalendarDropdown(
    value: month.month,
    seed: '$seed|${formatters.monthDropdownLabel}',
    semanticLabel: formatters.monthDropdownLabel,
    options: [
      for (var m = 1; m <= 12; m++)
        NativeSelectOption(
          value: m,
          label: formatters.monthDropdown(DateTime(month.year, m)),
          disabled: !_inBounds(DateTime(month.year, m)),
        ),
    ],
    onChanged: (m) => onMonthChange(DateTime(month.year, m)),
  );

  Widget _years() => CalendarDropdown(
    value: month.year,
    seed: '$seed|${formatters.yearDropdownLabel}',
    semanticLabel: formatters.yearDropdownLabel,
    options: [
      for (var y = startMonth.year; y <= endMonth.year; y++)
        NativeSelectOption(value: y, label: formatters.yearDropdown(y)),
    ],
    onChanged: (y) {
      final wanted = DateTime(y, month.month);
      final first = CalendarDates.month(startMonth);
      final last = CalendarDates.month(endMonth);
      final clamped = switch ((wanted.isBefore(first), wanted.isAfter(last))) {
        (true, _) => first,
        (_, true) => last,
        _ => wanted,
      };
      onMonthChange(clamped);
    },
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final cell = CalendarMetrics.cell.resolve(theme.density);
    final children = switch (layout) {
      CalendarCaptionLayout.label => [
        Semantics(
          liveRegion: true,
          child: _label(theme, formatters.caption(month)),
        ),
      ],
      CalendarCaptionLayout.dropdown => [_months(), _years()],
      CalendarCaptionLayout.dropdownMonths => [
        _months(),
        _label(theme, formatters.yearDropdown(month.year)),
      ],
      CalendarCaptionLayout.dropdownYears => [
        _label(theme, formatters.monthDropdown(month)),
        _years(),
      ],
    };
    return SizedBox(
      height: cell,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: cell),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: CalendarMetrics.dropdownGap,
          children: [for (final child in children) Flexible(child: child)],
        ),
      ),
    );
  }
}
