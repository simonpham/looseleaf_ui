import 'package:looseleaf_ink/src/charts/chart_looks.dart';
import 'package:looseleaf_ink/src/charts/format.dart';
import 'package:looseleaf_ink/src/charts/scale.dart';
import 'package:looseleaf_ink/src/charts/xy_spec.dart';

String _list(List<String> items) {
  if (items.length <= 2) return items.join(' and ');
  return '${items.sublist(0, items.length - 1).join(', ')} and ${items.last}';
}

String _plural(int count, String one, String many) => switch (count) {
  1 => one,
  _ => many,
};

/// A screen-reader summary of an XY chart: series, range and extremes.
///
/// Mirrors `summarizeXY` in `src/lib/ink/charts/chart-data.ts`.
String summarizeXY(
  XYSpec spec, {
  required String kind,
  String? title,
  ValueFormat? format,
}) {
  final fmt = format ?? formatNumber;
  final named = switch (title) {
    final t? when t.isNotEmpty => '$t. ',
    _ => '',
  };
  if (spec.state == ChartState.loading) return '$named$kind. Loading.';
  final scatter = spec.series.any((s) => s.kind == XYKind.scatter);
  final count = switch (scatter) {
    true => spec.series.fold(
      0,
      (n, s) => n + s.values.where((v) => v != null && isNum(v)).length,
    ),
    false => spec.cats.length,
  };
  if (spec.series.isEmpty || count == 0 || spec.state == ChartState.empty) {
    return '$named$kind. No data.';
  }
  final range = switch (count > 1) {
    true => ' from ${spec.cats.firstOrNull} to ${spec.cats.lastOrNull}',
    false => ' (${spec.cats.firstOrNull})',
  };
  final unit = switch (scatter) {
    true => '$count point${_plural(count, '', 's')}',
    false => '$count categor${_plural(count, 'y', 'ies')}$range',
  };
  final parts = [for (final s in spec.series) _part(spec, s, scatter, fmt)];
  final shape = switch ((spec.stacked, spec.horizontal)) {
    (true, _) => ' Stacked.',
    (false, true) => ' Horizontal bars.',
    _ => '',
  };
  final thinned = switch (spec.total) {
    final t? when t != 0 =>
      ' Thinned from ${formatNumber(t.toDouble())} rows to keep the drawing readable.',
    _ => '',
  };
  final marked = switch (spec.bands.isEmpty) {
    true => '',
    false => ' Marked: ${spec.bands.map((b) => _band(spec, b)).join('; ')}.',
  };
  final names = _list([for (final s in spec.series) s.name]);
  return '$named$kind with ${spec.series.length} series ($names) and $unit.$shape$thinned ${parts.join('. ')}.$marked'
      .replaceAll('..', '.');
}

String _band(XYSpec spec, XYBand b) {
  final text = switch (b.text) {
    final t? when t.isNotEmpty => '$t, ',
    _ => '',
  };
  final to = switch (b.i1 != b.i0) {
    true => ' to ${spec.cats.elementAtOrNull(b.i1)}',
    false => '',
  };
  return '$text${spec.cats.elementAtOrNull(b.i0)}$to';
}

String _part(XYSpec spec, XYSeries s, bool scatter, ValueFormat fmt) {
  final nums = [
    for (final (i, v) in s.values.indexed)
      if (v != null && isNum(v)) (v, i),
  ];
  if (nums.isEmpty) return '${s.name}: no values';
  var lo = nums.first;
  var hi = nums.first;
  for (final e in nums) {
    if (e.$1 < lo.$1) lo = e;
    if (e.$1 > hi.$1) hi = e;
  }
  String at((double, int) e) => switch (scatter) {
    true => '',
    false => ' in ${spec.cats.elementAtOrNull(e.$2)}',
  };
  if (nums.length == 1) return '${s.name}: ${fmt(nums.first.$1)}';
  return '${s.name}: from ${fmt(lo.$1)}${at(lo)} to ${fmt(hi.$1)}${at(hi)}';
}

/// A data table: header, rows, and how many rows were cut.
///
/// Mirrors `TableModel` in `src/lib/ink/charts/chart-data.ts`.
final class TableModel {
  /// A table.
  const TableModel({required this.head, required this.rows, this.clipped});

  /// Column headers.
  final List<String> head;

  /// Cells, row by row.
  final List<List<String>> rows;

  /// Shown and total rows, when rows were cut.
  final ({int shown, int total})? clipped;

  /// The upstream JSON shape.
  Map<String, Object?> toJson() => {
    'head': head,
    'rows': rows,
    'clipped': switch (clipped) {
      final c? => {'shown': c.shown, 'total': c.total},
      null => null,
    },
  };
}

/// The most rows a chart table lists (`TABLE_ROW_CAP`).
const int tableRowCap = 240;

({int shown, int total})? _clip(int total) => switch (total > tableRowCap) {
  true => (shown: tableRowCap, total: total),
  false => null,
};

/// The data table of an XY chart: one row per category (or per scatter
/// point).
///
/// Mirrors `tableXY` in `src/lib/ink/charts/chart-data.ts`.
TableModel tableXY(
  XYSpec spec, {
  ValueFormat? format,
  String? xHead,
  ValueFormat? xFormat,
}) {
  final fmt = format ?? formatNumber;
  final scatter = spec.series.any((s) => s.kind == XYKind.scatter);
  if (scatter) {
    final rows = <List<String>>[
      for (final s in spec.series)
        for (final (j, v) in s.values.indexed)
          if (s.xs?.elementAtOrNull(j) case final x?
              when v != null && isNum(v) && isNum(x))
            [s.name, (xFormat ?? fmt)(x), fmt(v)],
    ];
    return TableModel(
      head: ['Series', xHead ?? 'x', 'y'],
      rows: rows.take(tableRowCap).toList(),
      clipped: _clip(rows.length),
    );
  }
  final rows = [
    for (final (i, c) in spec.cats.take(tableRowCap).indexed)
      [
        c,
        for (final s in spec.series)
          switch (s.values.elementAtOrNull(i)) {
            final double v when isNum(v) => fmt(v),
            _ => '',
          },
      ],
  ];
  return TableModel(
    head: [xHead ?? '', for (final s in spec.series) s.name],
    rows: rows,
    clipped: _clip(spec.cats.length),
  );
}

/// A live-region line for one category: `label: name value, …`.
///
/// Mirrors `announceRow` in `src/lib/ink/charts/chart-data.ts`.
String announceRow(String label, List<({String name, String value})> entries) =>
    '$label: ${entries.map((e) => '${e.name} ${e.value}').join(', ')}';
