import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:test/test.dart';

typedef _Json = Map<String, dynamic>;

double _d(Object? v) => (v as num).toDouble();

double? _od(Object? v) => (v as num?)?.toDouble();

int _i(Object? v) => (v as num).toInt();

List<_Json> _list(Object? v) => (v as List? ?? const []).cast<_Json>();

List<String> _strings(Object? v) => (v as List? ?? const []).cast<String>();

List<double?> _values(Object? v) => [
  for (final x in v as List) (x as num?)?.toDouble(),
];

List<double>? _doubles(Object? v) => switch (v) {
  final List<dynamic> l => [for (final x in l) _d(x)],
  _ => null,
};

T _by<T extends Enum>(List<T> values, Object? v) => values.byName(v as String);

T? _maybe<T extends Enum>(List<T> values, Object? v) => switch (v) {
  final String name => values.byName(name),
  _ => null,
};

ChartState _state(Object? v) => _by(ChartState.values, v);

FillPattern _pattern(Object? v) => _by(FillPattern.values, v);

bool? _auto(Object? v) => switch (v) {
  final bool b => b,
  _ => null,
};

List<AxisTick> _ticks(Object? v) => [
  for (final t in _list(v)) AxisTick(_d(t['v']), t['label'] as String),
];

List<List<AxisTick>>? _alt(Object? v) => switch (v) {
  final List<dynamic> sets => [for (final s in sets) _ticks(s)],
  _ => null,
};

XYSpec _xy(_Json s) => XYSpec(
  cats: _strings(s['cats']),
  series: [
    for (final x in _list(s['series']))
      XYSeries(
        key: x['key'] as String,
        name: x['name'] as String,
        slot: _i(x['slot']),
        kind: _by(XYKind.values, x['kind']),
        pattern: _pattern(x['pattern']),
        marker: _by(MarkerShape.values, x['marker']),
        dash: _by(Dash.values, x['dash']),
        values: _values(x['values']),
        xs: _doubles(x['xs']),
        sizes: _doubles(x['sizes']),
      ),
  ],
  stacked: s['stacked'] as bool,
  horizontal: s['horizontal'] as bool,
  curve: _by(CurveKind.values, s['curve']),
  yMin: _d(s['yMin']),
  yMax: _d(s['yMax']),
  yTicks: _ticks(s['yTicks']),
  yTicksAlt: _alt(s['yTicksAlt']),
  xMin: _od(s['xMin']),
  xMax: _od(s['xMax']),
  xTicks: switch (s['xTicks']) {
    final List<dynamic> t => _ticks(t),
    _ => null,
  },
  xTicksAlt: _alt(s['xTicksAlt']),
  dots: _auto(s['dots']),
  values: _auto(s['values']),
  valueLabels: switch (s['valueLabels']) {
    final List<dynamic> rows => [
      for (final r in rows) (r as List).cast<String?>(),
    ],
    _ => null,
  },
  grid: s['grid'] as bool,
  showX: s['showX'] as bool,
  showY: s['showY'] as bool,
  zero: s['zero'] as bool,
  notes: [
    for (final n in _list(s['notes']))
      XYNote(
        s: _i(n['s']),
        i: _i(n['i']),
        text: n['text'] as String,
        pen: _by(NotePen.values, n['pen']),
        shape: _by(NoteShape.values, n['shape']),
        dx: _od(n['dx']),
        dy: _od(n['dy']),
      ),
  ],
  refs: [
    for (final r in _list(s['refs']))
      XYRef(
        value: _d(r['value']),
        axis: _by(RefAxis.values, r['axis']),
        pen: _by(NotePen.values, r['pen']),
        label: r['label'] as String?,
      ),
  ],
  bands: [
    for (final b in _list(s['bands']))
      XYBand(i0: _i(b['i0']), i1: _i(b['i1']), text: b['text'] as String?),
  ],
  patterns: s['patterns'] as bool,
  state: _state(s['state']),
  stateText: s['stateText'] as String?,
  total: switch (s['total']) {
    final num t => t.toInt(),
    _ => null,
  },
);

PieSpec _pie(_Json s) => PieSpec(
  slices: [
    for (final x in _list(s['slices']))
      Slice(
        key: x['key'] as String,
        name: x['name'] as String,
        slot: _i(x['slot']),
        pattern: _pattern(x['pattern']),
        value: _d(x['value']),
        label: x['label'] as String?,
      ),
  ],
  inner: _d(s['inner']),
  start: _d(s['start']),
  labels: s['labels'] as bool,
  patterns: s['patterns'] as bool,
  state: _state(s['state']),
  stateText: s['stateText'] as String?,
);

RadarSpec _radar(_Json s) => RadarSpec(
  axes: _strings(s['axes']),
  series: [
    for (final x in _list(s['series']))
      RadarSeries(
        key: x['key'] as String,
        name: x['name'] as String,
        slot: _i(x['slot']),
        pattern: _pattern(x['pattern']),
        marker: _by(MarkerShape.values, x['marker']),
        values: _values(x['values']),
      ),
  ],
  max: _d(s['max']),
  levels: _d(s['levels']),
  ringLabels: _strings(s['ringLabels']),
  fill: s['fill'] as bool,
  patterns: s['patterns'] as bool,
  dots: s['dots'] as bool,
  state: _state(s['state']),
  stateText: s['stateText'] as String?,
);

RadialSpec _radial(_Json s) => RadialSpec(
  rings: [
    for (final x in _list(s['rings']))
      RadialRing(
        key: x['key'] as String,
        name: x['name'] as String,
        slot: _i(x['slot']),
        pattern: _pattern(x['pattern']),
        value: _d(x['value']),
        max: _d(x['max']),
      ),
  ],
  start: _d(s['start']),
  end: _d(s['end']),
  patterns: s['patterns'] as bool,
  state: _state(s['state']),
  stateText: s['stateText'] as String?,
);

GaugeSpec _gauge(_Json s) => GaugeSpec(
  value: _d(s['value']),
  min: _d(s['min']),
  max: _d(s['max']),
  zones: [
    for (final z in _list(s['zones']))
      GaugeZone(
        to: _d(z['to']),
        slot: _i(z['slot']),
        pattern: _pattern(z['pattern']),
      ),
  ],
  sweep: _d(s['sweep']),
  ticks: _d(s['ticks']),
  minLabel: s['minLabel'] as String,
  maxLabel: s['maxLabel'] as String,
  patterns: s['patterns'] as bool,
  state: _state(s['state']),
  stateText: s['stateText'] as String?,
);

SparkSpec _spark(_Json s) => SparkSpec(
  variant: _by(SparkVariant.values, s['variant']),
  values: _values(s['values']),
  min: _d(s['min']),
  max: _d(s['max']),
  slot: _i(s['slot']),
  ends: s['ends'] as bool,
  extremes: s['extremes'] as bool,
  state: _state(s['state']),
);

TallySpec _tally(_Json s) => TallySpec(
  rows: [
    for (final r in _list(s['rows']))
      TallyRow(
        key: r['key'] as String,
        name: r['name'] as String,
        slot: _i(r['slot']),
        count: _d(r['count']),
      ),
  ],
  unit: _d(s['unit']),
  totals: _strings(s['totals']),
  state: _state(s['state']),
  stateText: s['stateText'] as String?,
);

List<HeatLabel> _heatLabels(Object? v) => [
  for (final l in _list(v)) HeatLabel(_i(l['i']), l['text'] as String),
];

HeatSpec _heat(_Json s) => HeatSpec(
  cols: _i(s['cols']),
  rows: _i(s['rows']),
  levels: [for (final l in s['levels'] as List) _i(l)],
  levelCount: _i(s['levelCount']),
  colLabels: _heatLabels(s['colLabels']),
  rowLabels: _heatLabels(s['rowLabels']),
  slot: _i(s['slot']),
  variant: _by(HeatVariant.values, s['variant']),
  legend: switch (s['legend']) {
    final _Json l => (less: l['less'] as String, more: l['more'] as String),
    _ => null,
  },
  patterns: s['patterns'] as bool,
  state: _state(s['state']),
  stateText: s['stateText'] as String?,
);

MiniParams _mini(_Json p) => switch (p['kind']) {
  'swatch' => MiniSwatch(
    slot: _i(p['slot']),
    pattern: _pattern(p['pattern']),
    marker: _maybe(MarkerShape.values, p['marker']),
    line: p['line'] as bool?,
    dash: _maybe(Dash.values, p['dash']),
  ),
  'column' => MiniColumn(slot: (p['slot'] as num?)?.toInt()),
  'guide' => MiniGuide(slot: (p['slot'] as num?)?.toInt()),
  'cell' => MiniCell(slot: (p['slot'] as num?)?.toInt()),
  'ring' => MiniRing(slot: _i(p['slot'])),
  'slice' => MiniSlice(
    cx: _d(p['cx']),
    cy: _d(p['cy']),
    r0: _d(p['r0']),
    r1: _d(p['r1']),
    a0: _d(p['a0']),
    a1: _d(p['a1']),
  ),
  _ => MiniSpoke(
    x1: _d(p['x1']),
    y1: _d(p['y1']),
    x2: _d(p['x2']),
    y2: _d(p['y2']),
  ),
};

Object? _clean(Object? v) => switch (v) {
  final List<Object?> l => [for (final x in l) _clean(x)],
  final Map<String, Object?> m => {
    for (final MapEntry(:key, :value) in m.entries) key: ?_clean(value),
  },
  _ => v,
};

final class _Entry<P> {
  _Entry(this.recipe, this.decode, this.json);

  final Recipe<P> recipe;
  final P Function(_Json p) decode;
  final Map<String, Object?> Function(P p) json;

  (RawFrame, String) run(_Json c) {
    final params = decode(c['params'] as _Json);
    final knobs = c['knobs'] as _Json;
    final frame = runRecipe(
      recipe,
      RunRequest<P>(
        box: Box(_d(c['w']), _d(c['h'])),
        params: params,
        seed: c['seed'] as String,
        tier: Tier.values.byName(c['tier'] as String),
        density: Density.values.byName(c['density'] as String),
        dir: Dir.values.byName(c['dir'] as String),
        knobs: Knobs(
          wobble: _d(knobs['wobble']),
          misreg: _d(knobs['misreg']),
          bleed: _d(knobs['bleed']),
          width: _d(knobs['width']),
        ),
        lazy: [
          for (final n in c['lazy'] as List)
            LayerName.values.byName(n as String),
        ],
        lazyOnly: c['lazyOnly'] == true,
        pad: _od(c['pad']),
      ),
    );
    return (frame, stableStringify(json(params)));
  }
}

final Map<String, _Entry<Object?>> _entries = {
  'chart-xy': _Entry<XYSpec>(
    chartXYRecipe,
    _xy,
    (s) => _clean(s.toJson()) as _Json,
  ),
  'chart-pie': _Entry<PieSpec>(chartPieRecipe, _pie, (s) => s.toJson()),
  'chart-radar': _Entry<RadarSpec>(chartRadarRecipe, _radar, (s) => s.toJson()),
  'chart-radial': _Entry<RadialSpec>(
    chartRadialRecipe,
    _radial,
    (s) => s.toJson(),
  ),
  'chart-gauge': _Entry<GaugeSpec>(chartGaugeRecipe, _gauge, (s) => s.toJson()),
  'chart-spark': _Entry<SparkSpec>(chartSparkRecipe, _spark, (s) => s.toJson()),
  'chart-tally': _Entry<TallySpec>(chartTallyRecipe, _tally, (s) => s.toJson()),
  'chart-heat': _Entry<HeatSpec>(chartHeatRecipe, _heat, (s) => s.toJson()),
  'chart-mark': _Entry<MiniParams>(chartMarkRecipe, _mini, (p) => p.toJson()),
};

void main() {
  for (
    var part = 1;
    File('test/fixtures/chart_recipes_$part.json').existsSync();
    part++
  ) {
    final fixture =
        jsonDecode(
              File('test/fixtures/chart_recipes_$part.json').readAsStringSync(),
            )
            as _Json;
    group('part $part', () {
      for (final c in _list(fixture['frames'])) {
        test(c['name'], () {
          final entry = _entries[c['recipe']];
          if (entry == null) fail('no entry for ${c['recipe']}');
          final (frame, key) = entry.run(c);
          final out = c['out'] as _Json;
          expect(key, c['key']);
          expect(frame.layers.map((l) => l.name), out['layers']);
          expect(frame.lazyLayers.map((l) => l.name), out['lazyLayers']);
          expect(
            [frame.pad, frame.w, frame.h],
            [out['pad'], out['w'], out['h']],
          );
          final parts = out['parts'] as _Json;
          expect(frame.parts.keys.map((k) => k.name), parts.keys);
          for (final MapEntry(:key, :value) in parts.entries) {
            expect(
              frame.parts[LayerName.values.byName(key)],
              value,
              reason: key,
            );
          }
        });
      }
    });
  }

  test('heatAlpha and hatchOn', () {
    expect(heatAlpha(0, 5), 0.16);
    expect(heatAlpha(1, 5), 0.26);
    expect(heatAlpha(4, 5), closeTo(0.94, 1e-12));
    expect(heatAlpha(2, 2), 0.26 + 0.68);
    expect(
      [
        for (final s in [-1, 0, 1, 8, 9]) hatchOn(s),
      ],
      [
        PaintKey.photo,
        PaintKey.ink,
        PaintKey.photo,
        PaintKey.ink,
        PaintKey.photo,
      ],
    );
  });
}
