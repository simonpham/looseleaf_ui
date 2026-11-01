const List<String> _months = [
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

const List<String> _weekdays = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];

String _ordinal(int day) {
  if (day % 100 >= 11 && day % 100 <= 13) return '${day}th';
  return switch (day % 10) {
    1 => '${day}st',
    2 => '${day}nd',
    3 => '${day}rd',
    _ => '${day}th',
  };
}

/// The words and numerals of a [Calendar], react-day-picker's
/// `formatters` and `labels`. The defaults are English; pass your own for
/// another language (and other numerals).
class CalendarFormatters {
  const CalendarFormatters({
    this.caption = formatCaption,
    this.monthDropdown = formatMonthDropdown,
    this.yearDropdown = formatYearDropdown,
    this.weekdayName = formatWeekdayName,
    this.day = formatDay,
    this.weekNumber = formatWeekNumber,
    this.dayLabel = labelDay,
    this.gridLabel = formatCaption,
    this.previousMonthLabel = 'Go to the Previous Month',
    this.nextMonthLabel = 'Go to the Next Month',
    this.monthDropdownLabel = 'Choose the Month',
    this.yearDropdownLabel = 'Choose the Year',
  });

  /// The caption above a month: `September 2026` (`LLLL y`).
  final String Function(DateTime month) caption;

  /// A month in the month dropdown: `Sep` (`LLL`, upstream's override).
  final String Function(DateTime month) monthDropdown;

  /// A year in the year dropdown: `2026`.
  final String Function(int year) yearDropdown;

  /// A weekday column head: `Su` (`cccccc`).
  final String Function(DateTime day) weekdayName;

  /// The number in a day cell.
  final String Function(DateTime day) day;

  /// A week number in the margin.
  final String Function(int week) weekNumber;

  /// A day's accessible name: [today] and [selected] add to the date.
  final String Function(DateTime day, {bool today, bool selected}) dayLabel;

  /// A month grid's accessible name.
  final String Function(DateTime month) gridLabel;

  final String previousMonthLabel;
  final String nextMonthLabel;
  final String monthDropdownLabel;
  final String yearDropdownLabel;

  /// `September 2026`.
  static String formatCaption(DateTime month) =>
      '${_months[month.month - 1]} ${month.year}';

  /// `Sep`.
  static String formatMonthDropdown(DateTime month) =>
      _months[month.month - 1].substring(0, 3);

  /// `2026`.
  static String formatYearDropdown(int year) => '$year';

  /// `Su`.
  static String formatWeekdayName(DateTime day) =>
      _weekdays[day.weekday % 7].substring(0, 2);

  /// `17`.
  static String formatDay(DateTime day) => '${day.day}';

  /// `37`.
  static String formatWeekNumber(int week) => '$week';

  /// `Today, Thursday, September 17th, 2026, selected`.
  static String labelDay(
    DateTime day, {
    bool today = false,
    bool selected = false,
  }) {
    final date =
        '${_weekdays[day.weekday % 7]}, ${_months[day.month - 1]} '
        '${_ordinal(day.day)}, ${day.year}';
    return [
      if (today) 'Today',
      date,
      if (selected) 'selected',
    ].join(', ');
  }
}
