import 'dart:math' as math;

import 'package:looseleaf_ui/src/components/date_picker/date_picker.dart';

/// Day arithmetic for a [Calendar], in local calendar days (no clock).
///
/// Mirrors the parts of react-day-picker's date library upstream
/// `src/components/ui/calendar.tsx` relies on.
abstract final class CalendarDates {
  /// [date] at midnight.
  static DateTime day(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// The first day of [date]'s month.
  static DateTime month(DateTime date) => DateTime(date.year, date.month);

  /// [month] moved by [months].
  static DateTime addMonths(DateTime month, int months) =>
      DateTime(month.year, month.month + months);

  /// [date] moved by [days] calendar days.
  static DateTime addDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);

  /// [date] moved by [months], kept on the same day of the month when it
  /// exists, else on that month's last day (date-fns `addMonths`).
  static DateTime addMonthsToDay(DateTime date, int months) {
    final target = DateTime(date.year, date.month + months);
    final last = DateTime(target.year, target.month + 1, 0).day;
    return DateTime(target.year, target.month, math.min(date.day, last));
  }

  /// Months from [a] to [b].
  static int monthsBetween(DateTime a, DateTime b) =>
      (b.year - a.year) * 12 + b.month - a.month;

  /// Index of [date] in a week starting on [weekStartsOn] (0 is Sunday).
  static int weekday(DateTime date, int weekStartsOn) =>
      (date.weekday % 7 - weekStartsOn + 7) % 7;

  /// The first day of [date]'s week.
  static DateTime startOfWeek(DateTime date, int weekStartsOn) =>
      addDays(day(date), -weekday(date, weekStartsOn));

  /// The last day of [date]'s week.
  static DateTime endOfWeek(DateTime date, int weekStartsOn) =>
      addDays(startOfWeek(date, weekStartsOn), 6);

  /// The weeks shown for [month]: whole weeks from the one holding the
  /// 1st to the one holding the last day, six when [fixedWeeks].
  static List<List<DateTime>> weeks(
    DateTime month, {
    required int weekStartsOn,
    bool fixedWeeks = false,
  }) {
    final first = startOfWeek(month, weekStartsOn);
    final last = endOfWeek(
      DateTime(month.year, month.month + 1, 0),
      weekStartsOn,
    );
    final spanned = (last.difference(first).inHours / 24).round() ~/ 7 + 1;
    final count = switch (fixedWeeks) {
      true => 6,
      false => spanned,
    };
    return [
      for (var w = 0; w < count; w++)
        [for (var d = 0; d < 7; d++) addDays(first, w * 7 + d)],
    ];
  }

  /// The week of the year for [date], date-fns `getWeek` with
  /// [weekStartsOn] and `firstWeekContainsDate: 1`: week 1 holds Jan 1st.
  static int weekNumber(DateTime date, int weekStartsOn) {
    final start = startOfWeek(date, weekStartsOn);
    final nextYearWeek = startOfWeek(DateTime(date.year + 1), weekStartsOn);
    if (!start.isBefore(nextYearWeek)) return 1;
    final yearWeek = startOfWeek(DateTime(date.year), weekStartsOn);
    final yearStart = switch (start.isBefore(yearWeek)) {
      true => startOfWeek(DateTime(date.year - 1), weekStartsOn),
      false => yearWeek,
    };
    return (start.difference(yearStart).inHours / 24).round() ~/ 7 + 1;
  }

  /// Whether [date] lies between [a] and [b], ends included.
  static bool within(DateTime date, DateTime a, DateTime b) =>
      !date.isBefore(day(a)) && !date.isAfter(day(b));

  /// react-day-picker's `addToRange`: the range after [date] is picked.
  static DateRange? addToRange(
    DateTime date,
    DateRange? range, {
    bool required = false,
  }) {
    final from = range?.from;
    final to = range?.to;
    if (from == null) return DateRange(from: date, to: date);
    if (to == null) {
      if (isSameDay(from, date)) return DateRange(from: from, to: date);
      if (date.isBefore(from)) return DateRange(from: date, to: from);
      return DateRange(from: from, to: date);
    }
    if (isSameDay(from, date) && isSameDay(to, date)) {
      return switch (required) {
        true => range,
        false => null,
      };
    }
    if (isSameDay(from, date)) return DateRange(from: from, to: date);
    if (isSameDay(to, date)) return DateRange(from: date, to: date);
    if (date.isBefore(from)) return DateRange(from: date, to: to);
    return DateRange(from: from, to: date);
  }
}
