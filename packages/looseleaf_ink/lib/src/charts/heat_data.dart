import 'dart:math' as math;

import 'package:looseleaf_ink/src/charts/js_values.dart';
import 'package:looseleaf_ink/src/charts/mini_specs.dart';
import 'package:looseleaf_ink/src/charts/scale.dart';
import 'package:looseleaf_ink/src/core/core.dart';

const double _day = 86400000;

/// Short month names (`MONTHS`).
const List<String> months = [
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

/// Long month names (`MONTHS_LONG`).
const List<String> monthsLong = [
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

/// Short weekday names, Sunday first (`WEEKDAYS`).
const List<String> weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

final RegExp _isoDay = RegExp(r'^(\d{4})-(\d{2})-(\d{2})');

/// The UTC midnight (ms) of a `DateTime` or a `YYYY-MM-DD…` string, or NaN
/// (`Date.UTC` semantics: years 0–99 mean 1900–1999).
///
/// Mirrors `dayMs` in `src/lib/ink/charts/chart-heat.ts`.
double dayMs(Object? d) {
  if (d is DateTime) {
    final u = d.toUtc();
    return DateTime.utc(
      u.year,
      u.month,
      u.day,
    ).millisecondsSinceEpoch.toDouble();
  }
  if (d is String) {
    if (_isoDay.firstMatch(d) case final m?) {
      final year = int.parse(m[1] ?? '0');
      return DateTime.utc(
        switch (year) {
          >= 0 && <= 99 => 1900 + year,
          _ => year,
        },
        int.parse(m[2] ?? '1'),
        int.parse(m[3] ?? '1'),
      ).millisecondsSinceEpoch.toDouble();
    }
  }
  return double.nan;
}

DateTime _utc(double ms) =>
    DateTime.fromMillisecondsSinceEpoch(ms.toInt(), isUtc: true);

/// [ms] as `YYYY-MM-DD` (UTC).
///
/// Mirrors `isoDay` in `src/lib/ink/charts/chart-heat.ts`.
String isoDay(double ms) {
  final d = _utc(ms);
  final m = '${d.month}'.padLeft(2, '0');
  final day = '${d.day}'.padLeft(2, '0');
  return '${d.year}-$m-$day';
}

/// [ms] as `Mon, Jan 5` (UTC), with the [year] when asked.
///
/// Mirrors `formatDay` in `src/lib/ink/charts/chart-heat.ts`.
String formatDay(double ms, [bool year = false]) {
  final d = _utc(ms);
  final tail = switch (year) {
    true => ', ${d.year}',
    false => '',
  };
  return '${weekdays[d.weekday % 7]}, ${months[d.month - 1]} ${d.day}$tail';
}

/// The level (`1..levels-1`, 0 for none) of [v] against [max], or
/// against [thresholds] when given.
///
/// Mirrors `levelOf` in `src/lib/ink/charts/chart-heat.ts`.
int levelOf(double? v, double max, int levels, [List<double>? thresholds]) {
  if (v == null || !isNum(v) || v <= 0) return 0;
  if (thresholds case final t? when t.isNotEmpty) {
    final lv = t.where((x) => v >= x).length;
    return math.min(levels - 1, math.max(1, lv));
  }
  final scaled = ((v / JsMath.or(max, 1)) * (levels - 1)).ceil();
  return math.min(levels - 1, math.max(1, scaled));
}

/// A heatmap's cells before layout.
///
/// Mirrors `HeatCells` in `src/lib/ink/charts/chart-heat.ts`.
final class HeatCells {
  /// Cells.
  const HeatCells({
    required this.cols,
    required this.rows,
    required this.levels,
    required this.values,
    required this.days,
    required this.colLabels,
    required this.rowLabels,
    required this.max,
  });

  /// Columns.
  final int cols;

  /// Rows.
  final int rows;

  /// Level per cell, row by row; -1 for no cell.
  final List<int> levels;

  /// Value per cell.
  final List<double?> values;

  /// UTC midnight per cell (calendar), NaN otherwise.
  final List<double> days;

  /// Column labels.
  final List<HeatLabel> colLabels;

  /// ChartRow labels.
  final List<HeatLabel> rowLabels;

  /// The largest value.
  final double max;

  /// The upstream JSON shape.
  Map<String, Object?> toJson() => {
    'cols': cols,
    'rows': rows,
    'levels': levels,
    'values': values,
    'days': days,
    'colLabels': [for (final l in colLabels) l.toJson()],
    'rowLabels': [for (final l in rowLabels) l.toJson()],
    'max': max,
  };
}

/// One calendar entry: a date (`DateTime` or `YYYY-MM-DD`) and a value.
///
/// Mirrors `CalendarInput` in `src/lib/ink/charts/chart-heat.ts`.
typedef CalendarInput = ({Object? date, Object? value});

/// A contribution calendar: 7 weekday rows by [weeks] columns ending at
/// [end] (or the last date), summing values per day.
///
/// Mirrors `buildCalendar` in `src/lib/ink/charts/chart-heat.ts`.
HeatCells buildCalendar(
  List<CalendarInput> rows, {
  required int levels,
  int? weeks,
  Object? end,
  int weekStart = 0,
  List<double>? thresholds,
  bool weekdayLabels = true,
  bool monthLabels = true,
}) {
  final byDay = <double, double>{};
  var last = double.negativeInfinity;
  var first = double.infinity;
  for (final r in rows) {
    final ms = dayMs(r.date);
    final v = jsNumber(r.value);
    if (!ms.isFinite || !v.isFinite) continue;
    byDay[ms] = (byDay[ms] ?? 0) + v;
    last = math.max(last, ms);
    first = math.min(first, ms);
  }
  final ws = weekStart;
  final endAt = dayMs(end);
  final endMs = switch ((endAt.isFinite, last.isFinite)) {
    (true, _) => endAt,
    (false, true) => last,
    _ => dayMs('2026-01-01'),
  };
  final startFromData = switch (first.isFinite) {
    true => first,
    false => endMs,
  };
  final epoch = dayMs('1970-01-04');
  int weekOf(double ms) => ((ms - epoch - ws * _day) / (7 * _day)).floor();
  final spanWeeks = weekOf(endMs) - weekOf(startFromData) + 1;
  final count = math.max(1, math.min(weeks ?? math.min(53, spanWeeks), 60));
  final lastWeek = weekOf(endMs);
  final week0 = lastWeek - count + 1;
  final gridStart = epoch + ws * _day + week0 * 7 * _day;
  var max = 0.0;
  for (final MapEntry(key: ms, value: v) in byDay.entries) {
    if (ms >= gridStart && ms <= endMs) max = math.max(max, v);
  }
  final cellLevels = <int>[];
  final values = <double?>[];
  final days = <double>[];
  for (var r = 0; r < 7; r++) {
    for (var c = 0; c < count; c++) {
      final ms = gridStart + (c * 7 + r) * _day;
      if (ms > endMs) {
        cellLevels.add(-1);
        values.add(null);
        days.add(double.nan);
        continue;
      }
      final v = byDay[ms] ?? 0;
      cellLevels.add(levelOf(v, max, levels, thresholds));
      values.add(v);
      days.add(ms);
    }
  }
  final colLabels = <HeatLabel>[];
  if (monthLabels) {
    var prev = -1;
    var prevCol = -99;
    for (var c = 0; c < count; c++) {
      final ms = gridStart + c * 7 * _day;
      final month = _utc(ms).month - 1;
      final startsHere = c == 0 || _utc(ms - 7 * _day).month - 1 != month;
      if (startsHere &&
          month != prev &&
          c > 0 &&
          c < 3 &&
          colLabels.length == 1 &&
          colLabels[0].i == 0) {
        colLabels.clear();
        prevCol = -99;
      }
      if (startsHere && month != prev && c - prevCol >= 3) {
        colLabels.add(HeatLabel(c, months[month]));
        prev = month;
        prevCol = c;
      }
    }
  }
  final rowLabels = <HeatLabel>[
    if (weekdayLabels)
      for (final wd in const [1, 3, 5])
        HeatLabel((wd - ws + 7) % 7, weekdays[wd]),
  ];
  return HeatCells(
    cols: count,
    rows: 7,
    levels: cellLevels,
    values: values,
    days: days,
    colLabels: colLabels,
    rowLabels: rowLabels,
    max: max,
  );
}

/// One grid entry: row and column names and a value.
///
/// Mirrors `GridInput` in `src/lib/ink/charts/chart-heat.ts`.
typedef GridInput = ({Object? row, Object? col, Object? value});

/// A named grid heatmap, summing values per cell; row and column names
/// come from [rows]/[cols] or the data (at most 200 each).
///
/// Mirrors `buildGrid` in `src/lib/ink/charts/chart-heat.ts`.
HeatCells buildGrid(
  List<GridInput> data, {
  required int levels,
  List<String>? rows,
  List<String>? cols,
  List<double>? thresholds,
}) {
  final rowNames = (rows ?? {for (final d in data) jsString(d.row)}.toList())
      .take(200)
      .toList();
  final colNames = (cols ?? {for (final d in data) jsString(d.col)}.toList())
      .take(200)
      .toList();
  final cell = <String, double>{};
  var max = 0.0;
  for (final d in data) {
    final v = jsNumber(d.value);
    if (!v.isFinite) continue;
    final key = '${jsString(d.row)}\u0000${jsString(d.col)}';
    cell[key] = (cell[key] ?? 0) + v;
  }
  for (final v in cell.values) {
    max = math.max(max, v);
  }
  final cellLevels = <int>[];
  final values = <double?>[];
  for (final r in rowNames) {
    for (final c in colNames) {
      final v = cell['$r\u0000$c'];
      cellLevels.add(switch (v) {
        null => 0,
        final value => levelOf(value, max, levels, thresholds),
      });
      values.add(v ?? 0);
    }
  }
  return HeatCells(
    cols: colNames.length,
    rows: rowNames.length,
    levels: cellLevels,
    values: values,
    days: [for (final _ in cellLevels) double.nan],
    colLabels: [for (final (i, t) in colNames.indexed) HeatLabel(i, t)],
    rowLabels: [for (final (i, t) in rowNames.indexed) HeatLabel(i, t)],
    max: max,
  );
}
