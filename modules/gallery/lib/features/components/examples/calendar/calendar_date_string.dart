const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// [day] the way JavaScript's `Date.toDateString` writes it:
/// `Thu Sep 17 2026`.
String calendarDateString(DateTime day) =>
    '${_weekdays[day.weekday - 1]} ${_months[day.month - 1]} '
    '${day.day.toString().padLeft(2, '0')} ${day.year}';
