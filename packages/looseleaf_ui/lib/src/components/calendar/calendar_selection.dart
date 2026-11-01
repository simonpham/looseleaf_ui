import 'package:looseleaf_ui/src/components/calendar/calendar_dates.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_mode.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_tiles.dart';
import 'package:looseleaf_ui/src/components/date_picker/date_picker.dart';

/// What a [Calendar] has chosen, in one of its modes, and what a tap on a
/// day makes of it: react-day-picker's selection hooks.
class CalendarSelection {
  const CalendarSelection({
    required this.mode,
    this.day,
    this.days = const [],
    this.range,
    this.required = false,
  });

  final CalendarMode mode;

  /// The single mode's day.
  final DateTime? day;

  /// The multiple mode's days.
  final List<DateTime> days;

  /// The range mode's span.
  final DateRange? range;

  /// The selection cannot be emptied.
  final bool required;

  /// Whether [date] is chosen, in any mode.
  bool isSelected(DateTime date) => switch (mode) {
    CalendarMode.single => switch (day) {
      final chosen? => isSameDay(chosen, date),
      null => false,
    },
    CalendarMode.multiple => days.any((chosen) => isSameDay(chosen, date)),
    CalendarMode.range => band(date, first: false, last: false) != null,
  };

  /// Whether [date] wears the ring: chosen and not part of a range
  /// (upstream `data-selected-single`).
  bool isRinged(DateTime date) =>
      mode != CalendarMode.range && isSelected(date);

  /// [date]'s cell of the range swipe, given whether it is the [first] or
  /// [last] cell of its week row (the `:first-of-type` / `:last-of-type`
  /// rules of `calendarCss`).
  CalendarBandKind? band(
    DateTime date, {
    required bool first,
    required bool last,
  }) {
    final span = range;
    if (mode != CalendarMode.range || span == null) return null;
    final from = span.from;
    final to = span.to;
    final start = isSameDay(from, date);
    final end = to != null && isSameDay(to, date);
    final middle =
        to != null && !start && !end && CalendarDates.within(date, from, to);
    final kind = switch ((start, end, middle)) {
      (true, true, _) => CalendarBandKind.pill,
      (true, false, _) => CalendarBandKind.start,
      (false, true, _) => CalendarBandKind.end,
      (false, false, true) => CalendarBandKind.mid,
      _ => null,
    };
    return switch ((kind, first, last)) {
      (CalendarBandKind.mid, true, true) => CalendarBandKind.pill,
      (CalendarBandKind.mid, true, false) => CalendarBandKind.start,
      (CalendarBandKind.mid, false, true) => CalendarBandKind.end,
      (CalendarBandKind.start, _, true) => CalendarBandKind.pill,
      (CalendarBandKind.end, true, _) => CalendarBandKind.pill,
      _ => kind,
    };
  }

  /// The single mode's day after [date] is tapped.
  DateTime? pickDay(DateTime date) {
    final chosen = day;
    if (chosen != null && isSameDay(chosen, date) && !required) return null;
    return date;
  }

  /// The multiple mode's days after [date] is tapped.
  List<DateTime> pickDays(DateTime date) {
    final kept = [
      for (final chosen in days)
        if (!isSameDay(chosen, date)) chosen,
    ];
    if (kept.length == days.length) return [...days, date];
    if (kept.isEmpty && required) return days;
    return kept;
  }

  /// The range mode's span after [date] is tapped.
  DateRange? pickRange(DateTime date) =>
      CalendarDates.addToRange(date, range, required: required);
}
