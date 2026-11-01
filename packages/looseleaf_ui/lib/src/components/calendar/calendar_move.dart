import 'package:looseleaf_ui/src/components/calendar/calendar_dates.dart';

/// A keyboard move across a [Calendar]'s days.
enum CalendarMove {
  dayBefore,
  dayAfter,
  weekBefore,
  weekAfter,
  weekStart,
  weekEnd,
  monthBefore,
  monthAfter,
  yearBefore,
  yearAfter;

  /// Whether the move goes back in time.
  bool get backwards => switch (this) {
    dayBefore || weekBefore || weekStart || monthBefore || yearBefore => true,
    _ => false,
  };

  /// The day one move from [from].
  DateTime step(DateTime from, int weekStartsOn) => switch (this) {
    dayBefore => CalendarDates.addDays(from, -1),
    dayAfter => CalendarDates.addDays(from, 1),
    weekBefore => CalendarDates.addDays(from, -7),
    weekAfter => CalendarDates.addDays(from, 7),
    weekStart => CalendarDates.startOfWeek(from, weekStartsOn),
    weekEnd => CalendarDates.endOfWeek(from, weekStartsOn),
    monthBefore => CalendarDates.addMonthsToDay(from, -1),
    monthAfter => CalendarDates.addMonthsToDay(from, 1),
    yearBefore => CalendarDates.addMonthsToDay(from, -12),
    yearAfter => CalendarDates.addMonthsToDay(from, 12),
  };

  /// Where focus lands after this move from [from], react-day-picker's
  /// `getNextFocus`: kept within [start]..[end] (first and last months),
  /// stepping on by a day past [isDisabled] days, up to a year of tries.
  DateTime? land(
    DateTime from, {
    required int weekStartsOn,
    required bool Function(DateTime day) isDisabled,
    DateTime? start,
    DateTime? end,
  }) {
    var day = step(from, weekStartsOn);
    final last = switch (end) {
      final month? => DateTime(month.year, month.month + 1, 0),
      null => null,
    };
    for (var attempt = 0; attempt < 365; attempt++) {
      if (start != null && day.isBefore(start)) day = start;
      if (last != null && day.isAfter(last)) day = last;
      if (!isDisabled(day)) return day;
      final next = CalendarDates.addDays(day, switch (backwards) {
        true => -1,
        false => 1,
      });
      if ((start != null && next.isBefore(start)) ||
          (last != null && next.isAfter(last))) {
        return null;
      }
      day = next;
    }
    return null;
  }
}
