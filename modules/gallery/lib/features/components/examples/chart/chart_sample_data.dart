import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Mirrors `src/docs/examples/chart/_data.ts`.
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
const _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

const visitors = <ChartRow>[
  {'month': 'January', 'desktop': 186, 'mobile': 80},
  {'month': 'February', 'desktop': 305, 'mobile': 200},
  {'month': 'March', 'desktop': 237, 'mobile': 120},
  {'month': 'April', 'desktop': 73, 'mobile': 190},
  {'month': 'May', 'desktop': 209, 'mobile': 130},
  {'month': 'June', 'desktop': 214, 'mobile': 140},
];

final desktopOnly = <ChartRow>[
  for (final row in visitors)
    {'month': row['month'], 'desktop': row['desktop']},
];

final radarDesktop = <ChartRow>[
  for (final row in desktopOnly)
    switch (row['month']) {
      'April' => {...row, 'desktop': 273},
      _ => row,
    },
];

const radarClose = <ChartRow>[
  {'month': 'January', 'desktop': 186, 'mobile': 160},
  {'month': 'February', 'desktop': 185, 'mobile': 170},
  {'month': 'March', 'desktop': 207, 'mobile': 180},
  {'month': 'April', 'desktop': 173, 'mobile': 160},
  {'month': 'May', 'desktop': 160, 'mobile': 190},
  {'month': 'June', 'desktop': 174, 'mobile': 204},
];

const visitorsThree = <ChartRow>[
  {'month': 'January', 'desktop': 186, 'mobile': 80, 'other': 45},
  {'month': 'February', 'desktop': 305, 'mobile': 200, 'other': 100},
  {'month': 'March', 'desktop': 237, 'mobile': 120, 'other': 150},
  {'month': 'April', 'desktop': 73, 'mobile': 190, 'other': 50},
  {'month': 'May', 'desktop': 209, 'mobile': 130, 'other': 100},
  {'month': 'June', 'desktop': 214, 'mobile': 140, 'other': 160},
];

final visitorsShare = <ChartRow>[
  for (final row in visitorsThree) _share(row),
];

ChartRow _share(ChartRow row) {
  const keys = ['desktop', 'mobile', 'other'];
  final total = keys.fold<num>(0, (sum, key) => sum + (row[key] as num));
  return {
    'month': row['month'],
    for (final key in keys)
      key: ((row[key] as num) / total * 1000).round() / 10,
  };
}

const swing = <ChartRow>[
  {'month': 'January', 'visitors': 186},
  {'month': 'February', 'visitors': 205},
  {'month': 'March', 'visitors': -207},
  {'month': 'April', 'visitors': 173},
  {'month': 'May', 'visitors': -209},
  {'month': 'June', 'visitors': 214},
];

final swingColumns = <ChartRow>[
  for (final row in swing)
    switch (row['visitors']) {
      final int value when value >= 0 => {'month': row['month'], 'gain': value},
      final value => {'month': row['month'], 'loss': value},
    },
];

const browsers = <ChartRow>[
  {'browser': 'chrome', 'visitors': 275},
  {'browser': 'safari', 'visitors': 200},
  {'browser': 'firefox', 'visitors': 187},
  {'browser': 'edge', 'visitors': 173},
  {'browser': 'other', 'visitors': 90},
];

const browsersActive = <ChartRow>[
  {'browser': 'chrome', 'visitors': 187},
  {'browser': 'safari', 'visitors': 200},
  {'browser': 'firefox', 'visitors': 275},
  {'browser': 'edge', 'visitors': 173},
  {'browser': 'other', 'visitors': 90},
];

const browsersBig = <ChartRow>[
  {'browser': 'chrome', 'visitors': 275},
  {'browser': 'safari', 'visitors': 200},
  {'browser': 'firefox', 'visitors': 287},
  {'browser': 'edge', 'visitors': 173},
  {'browser': 'other', 'visitors': 190},
];

final browserColumns = <ChartRow>[
  for (final row in browsers)
    {'browser': row['browser'], '${row['browser']}': row['visitors']},
];

const monthSlices = <ChartRow>[
  {'month': 'january', 'desktop': 186},
  {'month': 'february', 'desktop': 305},
  {'month': 'march', 'desktop': 237},
  {'month': 'april', 'desktop': 173},
  {'month': 'may', 'desktop': 209},
];

const activity = <ChartRow>[
  {'date': '2024-07-15', 'running': 450, 'swimming': 300},
  {'date': '2024-07-16', 'running': 380, 'swimming': 420},
  {'date': '2024-07-17', 'running': 520, 'swimming': 120},
  {'date': '2024-07-18', 'running': 140, 'swimming': 550},
  {'date': '2024-07-19', 'running': 600, 'swimming': 350},
  {'date': '2024-07-20', 'running': 480, 'swimming': 400},
];

const _daily = [
  (222, 150),
  (97, 180),
  (167, 120),
  (242, 260),
  (373, 290),
  (301, 340),
  (245, 180),
  (409, 320),
  (59, 110),
  (261, 190),
  (327, 350),
  (292, 210),
  (342, 380),
  (137, 220),
  (120, 170),
  (138, 190),
  (446, 360),
  (364, 410),
  (243, 180),
  (89, 150),
  (137, 200),
  (224, 170),
  (138, 230),
  (387, 290),
  (215, 250),
  (75, 130),
  (383, 420),
  (122, 180),
  (315, 240),
  (454, 380),
  (165, 220),
  (293, 310),
  (247, 190),
  (385, 420),
  (481, 390),
  (498, 520),
  (388, 300),
  (149, 210),
  (227, 180),
  (293, 330),
  (335, 270),
  (197, 240),
  (197, 160),
  (448, 490),
  (473, 380),
  (338, 400),
  (499, 420),
  (315, 350),
  (235, 180),
  (177, 230),
  (82, 140),
  (81, 120),
  (252, 290),
  (294, 220),
  (201, 250),
  (213, 170),
  (420, 460),
  (233, 190),
  (78, 130),
  (340, 280),
  (178, 230),
  (178, 200),
  (470, 410),
  (103, 160),
  (439, 380),
  (88, 140),
  (294, 250),
  (323, 370),
  (385, 320),
  (438, 480),
  (155, 200),
  (92, 150),
  (492, 420),
  (81, 130),
  (426, 380),
  (307, 350),
  (371, 310),
  (475, 520),
  (107, 170),
  (341, 290),
  (408, 450),
  (169, 210),
  (317, 270),
  (480, 530),
  (132, 180),
  (141, 190),
  (434, 380),
  (448, 490),
  (149, 200),
  (103, 160),
  (446, 400),
];

/// Ninety-one days from April 1, 2024.
final daily = <ChartRow>[
  for (final (index, (desktop, mobile)) in _daily.indexed)
    {'date': _aprilDay(index), 'desktop': desktop, 'mobile': mobile},
];

String _aprilDay(int index) {
  const daysInMonth = [30, 31, 30];
  var day = index;
  var month = 0;
  while (day >= daysInMonth[month]) {
    day -= daysInMonth[month];
    month++;
  }
  final mm = '${month + 4}'.padLeft(2, '0');
  final dd = '${day + 1}'.padLeft(2, '0');
  return '2024-$mm-$dd';
}

/// The first three letters: `January` → `Jan`.
String short(Object? value, [int index = 0]) {
  final text = '$value';
  return text.substring(0, text.length.clamp(0, 3));
}

/// `2024-04-07` → `Apr 7`.
String dayLabel(Object? value, [int index = 0]) {
  final [_, m, d] = '$value'.split('-');
  return '${_months[int.parse(m) - 1].substring(0, 3)} ${int.parse(d)}';
}

/// `2024-07-16` → `July 16, 2024`.
String longDate(Object? value) {
  final [y, m, d] = '$value'.split('-');
  return '${_months[int.parse(m) - 1]} ${int.parse(d)}, $y';
}

/// `2024-07-16` → `Tue`, by Sakamoto's method.
String weekday(Object? value, [int index = 0]) {
  final [y, m, d] = [for (final part in '$value'.split('-')) int.parse(part)];
  const t = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4];
  final yy = switch (m < 3) {
    true => y - 1,
    false => y,
  };
  return _weekdays[(yy + yy ~/ 4 - yy ~/ 100 + yy ~/ 400 + t[m - 1] + d) % 7];
}

/// `12840` → `12,840`.
String thousands(num n) => jsString(n).replaceAllMapped(
  RegExp(r'\B(?=(\d{3})+(?!\d))'),
  (_) => ',',
);

/// Tooltip labels read from the row instead of the axis text.
Widget monthOfRow(String label, List<ChartTooltipItem> items) =>
    Text('${items.firstOrNull?.payload?['month']}');

Widget dayOfRow(String label, List<ChartTooltipItem> items) =>
    Text(dayLabel(items.firstOrNull?.payload?['date']));

Widget dateOfRow(String label, List<ChartTooltipItem> items) =>
    Text(longDate(items.firstOrNull?.payload?['date']));
