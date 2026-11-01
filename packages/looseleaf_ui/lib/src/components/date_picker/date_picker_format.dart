/// Turns a date into the field's text.
typedef DatePickerFormat = String Function(DateTime date);

const List<String> _monthsShort = [
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

const List<String> _monthsLong = [
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

/// date-fns `PP` in English: `Sep 17, 2026`, upstream's default format.
String formatDateMedium(DateTime date) =>
    '${_monthsShort[date.month - 1]} ${date.day}, ${date.year}';

/// date-fns `P` in English: `09/17/2026`.
String formatDateShort(DateTime date) =>
    '${_two(date.month)}/${_two(date.day)}/${date.year}';

/// date-fns `PPP` in English: `September 17th, 2026`.
String formatDateLong(DateTime date) =>
    '${_monthsLong[date.month - 1]} ${date.day}${_ordinal(date.day)}, '
    '${date.year}';

/// `yyyy-MM-dd`, upstream `toIsoDate`.
String toIsoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${_two(date.month)}-'
    '${_two(date.day)}';

String _two(int value) => value.toString().padLeft(2, '0');

String _ordinal(int day) {
  if (day % 100 >= 11 && day % 100 <= 13) return 'th';
  return switch (day % 10) {
    1 => 'st',
    2 => 'nd',
    3 => 'rd',
    _ => 'th',
  };
}

int? _month(String name) {
  final lower = name.toLowerCase();
  for (var index = 0; index < 12; index++) {
    final long = _monthsLong[index].toLowerCase();
    if (lower == long || lower == long.substring(0, 3)) return index + 1;
    if (lower == 'sept' && index == 8) return 9;
  }
  return null;
}

/// Reads typed text as a day, like upstream `parseDateInput`
/// (`src/components/ui/date-picker.tsx`): "today", "tomorrow" and
/// "yesterday" (from [reference]), then the shapes of upstream's fallback
/// formats in English: `Sep 17, 2026`, `September 17th, 2026`,
/// `17 Sep 2026`, `2026-09-17`, `2026/9/17`, `9/17/2026`, `9/17/26`,
/// `17.9.2026`, `17.9.26`. Two-digit years land within 50 years of
/// [reference]. Null when nothing reads.
DateTime? parseDateInput(String text, {DateTime? reference}) {
  final typed = text.trim();
  if (typed.isEmpty) return null;
  final now = reference ?? DateTime(2000);
  final word = typed.toLowerCase();
  if (reference != null) {
    final today = DateTime(now.year, now.month, now.day);
    switch (word) {
      case 'today':
        return today;
      case 'tomorrow':
        return DateTime(now.year, now.month, now.day + 1);
      case 'yesterday':
        return DateTime(now.year, now.month, now.day - 1);
    }
  }
  for (final read in _readers) {
    final date = read(typed, now);
    if (date != null) return date;
  }
  return null;
}

typedef _Reader = DateTime? Function(String text, DateTime reference);

final List<_Reader> _readers = [
  (text, _) => _match(
    RegExp(r'^(\d{4})[-/](\d{1,2})[-/](\d{1,2})$'),
    text,
    (m) => _day(int.parse(m[1] ?? ''), int.parse(m[2] ?? ''), m[3]),
  ),
  (text, reference) => _match(
    RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{2}|\d{4})$'),
    text,
    (m) => _day(_year(m[3] ?? '', reference), int.parse(m[1] ?? ''), m[2]),
  ),
  (text, reference) => _match(
    RegExp(r'^(\d{1,2})\.(\d{1,2})\.(\d{2}|\d{4})$'),
    text,
    (m) => _day(_year(m[3] ?? '', reference), int.parse(m[2] ?? ''), m[1]),
  ),
  (text, _) => _match(
    RegExp(r'^([A-Za-z]+)\.?\s+(\d{1,2})(?:st|nd|rd|th)?,?\s+(\d{4})$'),
    text,
    (m) => switch (_month(m[1] ?? '')) {
      final month? => _day(int.parse(m[3] ?? ''), month, m[2]),
      null => null,
    },
  ),
  (text, _) => _match(
    RegExp(r'^(\d{1,2})(?:st|nd|rd|th)?\s+([A-Za-z]+)\.?,?\s+(\d{4})$'),
    text,
    (m) => switch (_month(m[2] ?? '')) {
      final month? => _day(int.parse(m[3] ?? ''), month, m[1]),
      null => null,
    },
  ),
];

DateTime? _match(
  RegExp pattern,
  String text,
  DateTime? Function(RegExpMatch match) read,
) {
  final match = pattern.firstMatch(text);
  if (match == null) return null;
  return read(match);
}

int _year(String digits, DateTime reference) {
  final value = int.parse(digits);
  if (digits.length == 4) return value;
  final century = reference.year ~/ 100 * 100;
  final candidates = [
    century - 100 + value,
    century + value,
    century + 100 + value,
  ];
  candidates.sort(
    (a, b) => (a - reference.year).abs().compareTo((b - reference.year).abs()),
  );
  return candidates.first;
}

DateTime? _day(int year, int month, String? dayText) {
  final day = int.tryParse(dayText ?? '');
  if (day == null || month < 1 || month > 12 || day < 1) return null;
  if (year < 1000 || year > 9999) return null;
  final date = DateTime(year, month, day);
  if (date.month != month || date.day != day) return null;
  return date;
}

/// Whether [a] and [b] fall on the same day.
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
