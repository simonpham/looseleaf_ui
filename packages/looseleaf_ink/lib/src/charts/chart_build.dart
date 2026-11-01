import 'dart:math' as math;

import 'package:looseleaf_ink/src/charts/build_inputs.dart';
import 'package:looseleaf_ink/src/charts/chart_data.dart';
import 'package:looseleaf_ink/src/charts/chart_looks.dart';
import 'package:looseleaf_ink/src/charts/curves.dart';
import 'package:looseleaf_ink/src/charts/format.dart';
import 'package:looseleaf_ink/src/charts/js_values.dart';
import 'package:looseleaf_ink/src/charts/scale.dart';
import 'package:looseleaf_ink/src/charts/xy_spec.dart';

/// [v] as a finite number, parsing non-blank strings; otherwise null.
///
/// Mirrors `toNum` in `src/lib/ink/charts/chart-build.ts`.
double? toNum(Object? v) {
  if (v is num && v.isFinite) return v.toDouble();
  if (v is String && v.trim().isNotEmpty) {
    final n = jsParse(v);
    if (n.isFinite) return n;
  }
  return null;
}

/// The most bars per series (`MAX_BARS`).
const int maxBars = 240;

/// The most bars in all (`MAX_BARS_TOTAL`).
const int maxBarsTotal = 480;

/// The most line or area points (`MAX_POINTS`).
const int maxPoints = 1500;

/// [rows] thinned to what a chart can draw: bars averaged in buckets,
/// lines reduced with [lttb]; [total] is the original count when thinned.
///
/// Mirrors `capRows` in `src/lib/ink/charts/chart-build.ts`.
({List<Row> rows, int? total}) capRows(
  List<Row> rows,
  List<String> keys,
  XYKind kind,
  String xKey,
) {
  final n = rows.length;
  if (kind == XYKind.scatter) return (rows: rows, total: null);
  final limit = math.min(
    maxBars,
    math.max(48, maxBarsTotal ~/ math.max(1, keys.length)),
  );
  if (kind == XYKind.bar && n > limit) {
    final size = (n / limit).ceil();
    final out = <Row>[];
    for (var i = 0; i < n; i += size) {
      final chunk = rows.sublist(i, math.min(n, i + size));
      final row = <String, Object?>{xKey: chunk[0][xKey]};
      for (final k in keys) {
        final vs = [for (final r in chunk) ?toNum(r[k])];
        row[k] = switch (vs.isEmpty) {
          true => null,
          false => vs.fold(0.0, (a, b) => a + b) / vs.length,
        };
      }
      out.add(row);
    }
    return (rows: out, total: n);
  }
  if (kind != XYKind.bar && n > maxPoints) {
    final first = keys.firstOrNull;
    final pts = [
      for (final (i, r) in rows.indexed)
        (
          i.toDouble(),
          toNum(switch (first) {
                final k? when k.isNotEmpty => r[k],
                _ => 0,
              }) ??
              0,
        ),
    ];
    return (rows: [for (final i in lttb(pts, maxPoints)) rows[i]], total: n);
  }
  return (rows: rows, total: null);
}

/// A series' pattern, marker and dash.
typedef SeriesLook = ({FillPattern pattern, MarkerShape marker, Dash dash});

T _cycle<T>(List<T> items, int slot) =>
    items[((slot % items.length) + items.length) % items.length];

/// The automatic look of a [kind] series in [slot] when [drawn] series
/// are drawn: patterns and markers vary only when several are.
///
/// Mirrors `autoLook` in `src/lib/ink/charts/chart-build.ts`.
SeriesLook autoLook(XYKind kind, int slot, int drawn, bool? patterns) {
  if (patterns == false) {
    return (
      pattern: FillPattern.solid,
      marker: MarkerShape.circle,
      dash: Dash.solid,
    );
  }
  final many = drawn > 1 || patterns == true;
  final pattern = switch ((kind, many)) {
    (XYKind.area, _) => _cycle(FillPattern.values, slot + 1),
    (XYKind.bar, true) => _cycle(FillPattern.values, slot),
    _ => FillPattern.solid,
  };
  return (
    pattern: pattern,
    marker: switch (many) {
      true => _cycle(markers, slot),
      false => MarkerShape.circle,
    },
    dash: switch (many) {
      true => _cycle(Dash.values, slot),
      false => Dash.solid,
    },
  );
}

/// [autoLook] with the series' own choices on top (ignored when
/// [patterns] is off).
///
/// Mirrors `seriesLook` in `src/lib/ink/charts/chart-build.ts`.
SeriesLook seriesLook(
  XYKind kind,
  int slot,
  int count,
  bool? patterns, {
  FillPattern? pattern,
  MarkerShape? marker,
  Dash? dash,
}) {
  final auto = autoLook(kind, slot, count, patterns);
  if (patterns == false) return auto;
  return (
    pattern: pattern ?? auto.pattern,
    marker: marker ?? auto.marker,
    dash: dash ?? auto.dash,
  );
}

/// Builds an XY chart spec from rows.
///
/// Mirrors `buildXY` in `src/lib/ink/charts/chart-build.ts`.
XYSpec buildXY(XYBuildInput input) => buildXYRows(input).spec;

/// Builds an XY chart spec from rows, with the rows actually drawn.
///
/// Mirrors `buildXYRows` in `src/lib/ink/charts/chart-build.ts`.
({XYSpec spec, List<Row> rows}) buildXYRows(XYBuildInput i) {
  final scatter = i.kind == XYKind.scatter;
  final capped = capRows(
    i.rows,
    [for (final s in i.series) s.key],
    i.kind,
    i.xKey,
  );
  final rows = capped.rows;
  final patterns = i.patterns;
  final n = switch (scatter) {
    true => 0,
    false => rows.length,
  };
  final series = <XYSeries>[
    for (final (idx, s) in i.series.indexed)
      if (!i.hidden.contains(s.key)) _series(i, s, idx, rows, scatter),
  ];
  final refs = <XYRef>[
    for (final r in i.refs) ?_ref(r),
  ];
  final hasFill = series.any(
    (s) => s.kind == XYKind.bar || s.kind == XYKind.area,
  );
  final y = yScaleFor(
    series,
    n: n,
    stacked: i.stacked ?? false,
    zero: i.zero ?? hasFill,
    domain: i.domain,
    ticks: i.tickCount ?? 5,
    format: i.yFormat ?? formatCompact,
    include: [
      for (final r in refs)
        if (r.axis == RefAxis.y) r.value,
    ],
  );
  final cats = <String>[
    if (!scatter)
      for (final (idx, r) in rows.indexed)
        switch (i.xFormat) {
          final f? => f(r[i.xKey], idx),
          null => switch (r[i.xKey]) {
            null => '',
            final v => jsString(v),
          },
        },
  ];
  final x = switch (scatter) {
    true => xScaleFor(
      [
        for (final s in series)
          for (final v in s.xs ?? const <double>[])
            if (isNum(v)) v,
      ],
      domain: i.xDomain,
      ticks: 6,
      format: switch (i.xFormat) {
        final f? => (v) => f(v, 0),
        null => formatCompact,
      },
      include: [
        for (final r in refs)
          if (r.axis == RefAxis.x) r.value,
      ],
    ),
    false => null,
  };
  final notes = [for (final nt in i.notes) ?_note(nt, series, cats)];
  final bands = <XYBand>[
    if (!scatter)
      for (final b in i.bands) ?_band(b, cats),
  ];
  final valueLabels = switch (i.values) {
    false => null,
    _ => [
      for (final s in series)
        [
          for (final v in s.values)
            switch (v) {
              final double value when s.kind == XYKind.bar && isNum(value) =>
                (i.valueFormat ?? formatNumber)(value),
              _ => null,
            },
        ],
    ],
  };
  final empty =
      series.isEmpty ||
      (!scatter && n == 0) ||
      series.every((s) => s.values.every((v) => v == null || !isNum(v)));
  final state =
      i.state ??
      switch (empty) {
        true => ChartState.empty,
        false => ChartState.ready,
      };
  final spec = XYSpec(
    cats: cats,
    series: series,
    stacked: i.stacked ?? false,
    horizontal: i.horizontal ?? false,
    curve: i.curve ?? CurveKind.smooth,
    yMin: y.min,
    yMax: y.max,
    yTicks: y.ticks,
    yTicksAlt: switch (y.ticksAlt.isEmpty) {
      true => null,
      false => y.ticksAlt,
    },
    xMin: x?.min,
    xMax: x?.max,
    xTicks: x?.ticks,
    xTicksAlt: x?.ticksAlt,
    dots: i.dots,
    values: i.values,
    valueLabels: valueLabels,
    grid: i.grid ?? true,
    showX: i.showX ?? true,
    showY: i.showY ?? true,
    zero: i.zero ?? hasFill,
    notes: notes,
    refs: refs,
    bands: bands,
    patterns: patterns != false,
    state: state,
    stateText: i.stateText,
    total: switch (capped.total) {
      final t? when t != 0 => t,
      _ => null,
    },
  );
  return (spec: spec, rows: rows);
}

XYSeries _series(
  XYBuildInput i,
  SeriesInput s,
  int idx,
  List<Row> rows,
  bool scatter,
) {
  final kind = s.kind ?? i.kind;
  final slot = s.slot ?? idx;
  final look = seriesLook(
    kind,
    slot,
    i.series.length,
    i.patterns,
    pattern: s.pattern,
    marker: s.marker,
    dash: s.dash,
  );
  return XYSeries(
    key: s.key,
    name: s.name ?? s.key,
    slot: slot,
    kind: kind,
    pattern: look.pattern,
    marker: look.marker,
    dash: look.dash,
    values: [for (final r in rows) toNum(r[s.key])],
    xs: switch (scatter) {
      true => [for (final r in rows) toNum(r[i.xKey]) ?? double.nan],
      false => null,
    },
    sizes: switch ((scatter, i.sizeKey)) {
      (true, final key?) => [
        for (final r in rows) toNum(r[key]) ?? double.nan,
      ],
      _ => null,
    },
  );
}

XYRef? _ref(RefInput r) {
  final pen = r.pen ?? NotePen.red;
  if (r.y case final y? when isNum(y)) {
    return XYRef(value: y, axis: RefAxis.y, label: r.label, pen: pen);
  }
  if (r.x case final x? when isNum(x)) {
    return XYRef(value: x, axis: RefAxis.x, label: r.label, pen: pen);
  }
  return null;
}

int _extreme(List<double?> values, bool max) {
  var best = -1;
  var bestV = 0.0;
  for (final (k, v) in values.indexed) {
    if (v == null || !isNum(v)) continue;
    final better = switch (max) {
      true => v > bestV,
      false => v < bestV,
    };
    if (best >= 0 && !better) continue;
    best = k;
    bestV = v;
  }
  return best;
}

int _noteIndex(Object at, List<double?> values, List<String> cats) {
  bool numeric(double? v) => v != null && isNum(v);
  return switch (at) {
    final int index => index,
    final num index => index.toInt(),
    'first' => values.indexWhere(numeric),
    'last' => values.length - 1 - values.reversed.toList().indexWhere(numeric),
    'max' => _extreme(values, true),
    'min' => _extreme(values, false),
    _ => cats.indexOf('$at'),
  };
}

XYNote? _note(NoteInput nt, List<XYSeries> series, List<String> cats) {
  final si = switch (nt.series) {
    null => 0,
    final int index => index,
    final key => series.indexWhere((s) => s.key == key),
  };
  if (si < 0 || si >= series.length) return null;
  final ser = series[si];
  final idx = _noteIndex(nt.at, ser.values, cats);
  if (idx < 0 || idx >= ser.values.length) return null;
  final v = ser.values[idx];
  if (v == null || !isNum(v)) return null;
  return XYNote(
    s: si,
    i: idx,
    text: nt.text,
    pen: nt.pen ?? NotePen.red,
    shape: nt.shape ?? NoteShape.loop,
    dx: nt.dx,
    dy: nt.dy,
  );
}

XYBand? _band(BandInput b, List<String> cats) {
  int at(Object v) => switch (v) {
    final int index => index,
    final num index => index.toInt(),
    _ => cats.indexOf('$v'),
  };
  final a = at(b.from);
  final z = at(b.to);
  if (a < 0 || z < 0 || a >= cats.length || z >= cats.length) return null;
  return XYBand(i0: math.min(a, z), i1: math.max(a, z), text: b.text);
}
