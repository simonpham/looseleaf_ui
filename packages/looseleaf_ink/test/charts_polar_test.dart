import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/src/charts/charts.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:test/test.dart';

final Map<String, dynamic> _fx = jsonDecode(
  File('test/fixtures/charts_polar.json').readAsStringSync(),
) as Map<String, dynamic>;

List<Map<String, dynamic>> _list(Object? v) =>
    (v as List? ?? const []).cast<Map<String, dynamic>>();

double _n(Object? v) => switch (v) {
  final num x => x.toDouble(),
  _ => double.nan,
};

int _i(Object? v) => (v as num).toInt();

Object? _clean(Object? v) => switch (v) {
  final num x when !x.isFinite => null,
  final List<Object?> l => [for (final x in l) _clean(x)],
  final Map<String, Object?> m => {
    for (final MapEntry(:key, :value) in m.entries) key: ?_clean(value),
  },
  _ => v,
};

const List<String> _keys = [
  'Home',
  'End',
  'ArrowRight',
  'ArrowLeft',
  'ArrowDown',
  'ArrowUp',
  'PageDown',
  'PageUp',
  'Enter',
];

Object? _dump(ChartLayoutBase l) {
  final n = l.targets.n;
  final idx = [-1, for (var i = 0; i < n && i < 40; i++) i, n];
  return _clean({
    ...l.toJson(),
    'cursors': [
      for (final i in idx) [for (final c in l.cursorAt(i)) c.toJson()],
    ],
    'hits': [
      for (var gy = 0; gy <= 8; gy++)
        for (var gx = 0; gx <= 10; gx++)
          hitIndex(l.targets, (l.w * gx) / 10, (l.h * gy) / 8),
    ],
    'steps': [
      for (final key in _keys)
        [
          for (final from in [null, -1, 0, 1, n ~/ 2, n - 1, n])
            stepIndex(l.targets, from, key),
        ],
    ],
  });
}

ChartState _state(Object? v) => ChartState.values.byName(v as String);

FillPattern _pattern(Object? v) => FillPattern.values.byName(v as String);

List<double?> _values(Object? v) => [
  for (final x in v as List) (x as num?)?.toDouble(),
];

List<HeatLabel> _labels(Object? v) => [
  for (final l in _list(v)) HeatLabel(_i(l['i']), l['text'] as String),
];

ChartSpec _spec(Map<String, dynamic> s) => switch (s['type']) {
  'pie' => PieSpec(
    slices: [
      for (final x in _list(s['slices']))
        Slice(
          key: x['key'] as String,
          name: x['name'] as String,
          slot: _i(x['slot']),
          pattern: _pattern(x['pattern']),
          value: _n(x['value']),
          label: x['label'] as String?,
        ),
    ],
    inner: _n(s['inner']),
    start: _n(s['start']),
    labels: s['labels'] as bool,
    patterns: s['patterns'] as bool,
    state: _state(s['state']),
    stateText: s['stateText'] as String?,
  ),
  'radar' => RadarSpec(
    axes: (s['axes'] as List).cast<String>(),
    series: [
      for (final x in _list(s['series']))
        RadarSeries(
          key: x['key'] as String,
          name: x['name'] as String,
          slot: _i(x['slot']),
          pattern: _pattern(x['pattern']),
          marker: MarkerShape.values.byName(x['marker'] as String),
          values: _values(x['values']),
        ),
    ],
    max: _n(s['max']),
    levels: _n(s['levels']),
    ringLabels: (s['ringLabels'] as List).cast<String>(),
    fill: s['fill'] as bool,
    patterns: s['patterns'] as bool,
    dots: s['dots'] as bool,
    state: _state(s['state']),
    stateText: s['stateText'] as String?,
  ),
  'radial' => RadialSpec(
    rings: [
      for (final x in _list(s['rings']))
        RadialRing(
          key: x['key'] as String,
          name: x['name'] as String,
          slot: _i(x['slot']),
          pattern: _pattern(x['pattern']),
          value: _n(x['value']),
          max: _n(x['max']),
        ),
    ],
    start: _n(s['start']),
    end: _n(s['end']),
    patterns: s['patterns'] as bool,
    state: _state(s['state']),
    stateText: s['stateText'] as String?,
  ),
  'gauge' => GaugeSpec(
    value: _n(s['value']),
    min: _n(s['min']),
    max: _n(s['max']),
    zones: [
      for (final z in _list(s['zones']))
        GaugeZone(
          to: _n(z['to']),
          slot: _i(z['slot']),
          pattern: _pattern(z['pattern']),
        ),
    ],
    sweep: _n(s['sweep']),
    ticks: _n(s['ticks']),
    minLabel: s['minLabel'] as String,
    maxLabel: s['maxLabel'] as String,
    patterns: s['patterns'] as bool,
    state: _state(s['state']),
    stateText: s['stateText'] as String?,
  ),
  'spark' => SparkSpec(
    variant: SparkVariant.values.byName(s['variant'] as String),
    values: _values(s['values']),
    min: _n(s['min']),
    max: _n(s['max']),
    slot: _i(s['slot']),
    ends: s['ends'] as bool,
    extremes: s['extremes'] as bool,
    state: _state(s['state']),
  ),
  'tally' => TallySpec(
    rows: [
      for (final r in _list(s['rows']))
        TallyRow(
          key: r['key'] as String,
          name: r['name'] as String,
          slot: _i(r['slot']),
          count: _n(r['count']),
        ),
    ],
    unit: _n(s['unit']),
    totals: (s['totals'] as List).cast<String>(),
    state: _state(s['state']),
    stateText: s['stateText'] as String?,
  ),
  _ => HeatSpec(
    cols: _i(s['cols']),
    rows: _i(s['rows']),
    levels: [for (final l in s['levels'] as List) _i(l)],
    levelCount: _i(s['levelCount']),
    colLabels: _labels(s['colLabels']),
    rowLabels: _labels(s['rowLabels']),
    slot: _i(s['slot']),
    variant: HeatVariant.values.byName(s['variant'] as String),
    legend: switch (s['legend']) {
      final Map<String, dynamic> l => (
        less: l['less'] as String,
        more: l['more'] as String,
      ),
      _ => null,
    },
    patterns: s['patterns'] as bool,
    state: _state(s['state']),
    stateText: s['stateText'] as String?,
  ),
};

List<List<double>> _pts(List<Pt> pts) => [
  for (final (x, y) in pts) [x, y],
];

void main() {
  for (final (k, c) in _list(_fx['charts']).indexed) {
    final raw = c['spec'] as Map<String, dynamic>;
    group('${raw['type']} #$k', () {
      final spec = _spec(raw);
      for (final l in _list(c['layouts'])) {
        test('${l['w']}x${l['h']} calm: ${l['calm']}', () {
          final layout = layoutChart(
            spec,
            Box(_n(l['w']), _n(l['h'])),
            l['calm'] == true,
          );
          expect(_dump(layout), l['out']);
        });
      }
    });
  }

  test('polar helpers', () {
    final h = _fx['helpers'] as Map<String, dynamic>;
    expect([
      for (final d in [0, 90, -45, 270, 33.3]) deg(d.toDouble()),
    ], h['deg']);
    expect([
      for (final p in [
        polar(10, 20, 30, 0),
        polar(0, 0, 5, 1.3),
        polar(50, 50, 12.5, -2.2),
      ])
        [p.$1, p.$2],
    ], h['polar']);
    expect([
      angleOf(0, 0, 10, 0),
      angleOf(0, 0, 0, -10),
      angleOf(0, 0, -10, 0),
      angleOf(0, 0, 0, 10),
      angleOf(5, 5, 3, 9),
    ], h['angle']);
    expect([
      _pts(arcPts(50, 50, 40, 0, 1.2, 4)),
      _pts(arcPts(0, 0, 100, -1, 2.5, 6)),
      _pts(arcPts(10, 10, 2, 0, 0.1, 4)),
    ], h['arcs']);
    expect([
      _pts(sectorPoly(50, 50, 0, 40, 0, 1.2, 4)),
      _pts(sectorPoly(50, 50, 20, 40, -0.5, 0.5, 6)),
      _pts(sectorPoly(0, 0, 0.4, 9, 1, 2, 4)),
    ], h['sectors']);
  });
}
