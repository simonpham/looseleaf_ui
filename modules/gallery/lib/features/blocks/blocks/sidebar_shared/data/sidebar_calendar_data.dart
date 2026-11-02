import 'dart:ui';

import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A calendar's ink.
enum CalendarTone {
  you,
  orange,
  green,
  red,
  grape;

  /// The paint token it writes in.
  Color of(LooseleafColors colors) => switch (this) {
    CalendarTone.you => colors.inkYou,
    CalendarTone.orange => colors.orangeText,
    CalendarTone.green => colors.green,
    CalendarTone.red => colors.red,
    CalendarTone.grape => colors.grape,
  };
}

/// A calendar you can show or hide.
class CalendarEntry {
  const CalendarEntry(this.name, this.tone);

  final String name;
  final CalendarTone tone;
}

/// A fold of calendars.
class CalendarGroup {
  const CalendarGroup(this.name, this.items);

  final String name;
  final List<CalendarEntry> items;
}

const calendarGroups = [
  CalendarGroup('My calendars', [
    CalendarEntry('Personal', CalendarTone.you),
    CalendarEntry('Work', CalendarTone.orange),
    CalendarEntry('Family', CalendarTone.green),
  ]),
  CalendarGroup('Favorites', [
    CalendarEntry('Holidays', CalendarTone.red),
    CalendarEntry('Birthdays', CalendarTone.grape),
  ]),
  CalendarGroup('Other', [
    CalendarEntry('Travel', CalendarTone.you),
    CalendarEntry('Reminders', CalendarTone.orange),
    CalendarEntry('Deadlines', CalendarTone.red),
  ]),
];

/// The calendars shown at first.
const defaultVisibleCalendars = ['Personal', 'Work', 'Holidays'];

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// "Friday, 25 September".
String formatDay(DateTime date) =>
    '${_weekdays[date.weekday - 1]}, ${date.day} ${_months[date.month - 1]}';

/// "September 2026".
String formatMonth(DateTime date) => '${_months[date.month - 1]} ${date.year}';
