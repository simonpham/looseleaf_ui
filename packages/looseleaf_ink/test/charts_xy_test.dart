import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/src/charts/charts.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:test/test.dart';

Map<String, dynamic> _load(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
        as Map<String, dynamic>;

final Map<String, dynamic> _fx = _load('charts_xy');

List<Map<String, dynamic>> _list(Object? v) =>
    (v as List).cast<Map<String, dynamic>>();

double _n(Object? v) => switch (v) {
  final num x => x.toDouble(),
  final String s => double.parse(s),
  _ => double.nan,
};

double? _on(Object? v) => switch (v) {
  final num x => x.toDouble(),
  _ => null,
};

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

Object? _dump(ChartLayoutBase l, {bool series = false}) {
  final n = l.targets.n;
  final idx = [-1, for (var i = 0; i < n && i < 40; i++) i, n];
  return _clean({
    ...l.toJson(),
    'cursors': [
      for (final i in idx) [for (final c in l.cursorAt(i)) c.toJson()],
    ],
    if (series)
      'cursors0': [
        for (final i in idx) [for (final c in l.cursorAt(i, 0)) c.toJson()],
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

T? _enum<T extends Enum>(List<T> values, Object? v) => switch (v) {
  final String name => values.where((e) => e.name == name).firstOrNull,
  _ => null,
};

bool? _auto(Object? v) => switch (v) {
  final bool b => b,
  _ => null,
};

AxisDomain? _domain(Object? v) => switch (v) {
  [final lo, final hi] => (_on(lo), _on(hi)),
  _ => null,
};

List<Row> _rows(String name) => [
  for (final r in (_fx['data'] as Map<String, dynamic>)[name] as List)
    Map<String, Object?>.from(r as Map),
];

XYBuildInput _input(Map<String, dynamic> i, List<Row> rows, bool fmt) =>
    XYBuildInput(
      rows: rows,
      xKey: i['xKey'] as String,
      kind: XYKind.values.byName(i['kind'] as String),
      series: [
        for (final s in _list(i['series']))
          SeriesInput(
            s['key'] as String,
            name: s['name'] as String?,
            kind: _enum(XYKind.values, s['kind']),
            slot: (s['slot'] as num?)?.toInt(),
            pattern: _enum(FillPattern.values, s['pattern']),
            marker: _enum(MarkerShape.values, s['marker']),
            dash: _enum(Dash.values, s['dash']),
          ),
      ],
      stacked: i['stacked'] as bool?,
      horizontal: i['horizontal'] as bool?,
      curve: _enum(CurveKind.values, i['curve']),
      domain: _domain(i['domain']),
      xDomain: _domain(i['xDomain']),
      zero: i['zero'] as bool?,
      tickCount: (i['tickCount'] as num?)?.toInt(),
      dots: _auto(i['dots']),
      values: _auto(i['values']),
      grid: i['grid'] as bool?,
      showX: i['showX'] as bool?,
      showY: i['showY'] as bool?,
      patterns: _auto(i['patterns']),
      hidden: {...?(i['hidden'] as List?)?.cast<String>()},
      state: _enum(ChartState.values, i['state']),
      stateText: i['stateText'] as String?,
      sizeKey: i['sizeKey'] as String?,
      notes: [
        for (final nt in _list(i['notes'] ?? const []))
          NoteInput(
            at: switch (nt['at']) {
              final num x => x.toInt(),
              final Object o => o,
              null => 'max',
            },
            series: switch (nt['series']) {
              final num x => x.toInt(),
              final Object? o => o,
            },
            text: nt['text'] as String,
            pen: _enum(NotePen.values, nt['pen']),
            shape: _enum(NoteShape.values, nt['shape']),
            dx: _on(nt['dx']),
            dy: _on(nt['dy']),
          ),
      ],
      refs: [
        for (final r in _list(i['refs'] ?? const []))
          RefInput(
            y: _on(r['y']),
            x: _on(r['x']),
            label: r['label'] as String?,
            pen: _enum(NotePen.values, r['pen']),
          ),
      ],
      bands: [
        for (final b in _list(i['bands'] ?? const []))
          BandInput(
            from: switch (b['from']) {
              final num x => x.toInt(),
              final Object o => o,
              null => '',
            },
            to: switch (b['to']) {
              final num x => x.toInt(),
              final Object o => o,
              null => '',
            },
            text: b['text'] as String?,
          ),
      ],
      yFormat: switch (fmt) {
        true => (v) => '${JsMath.numberToString(v)}%',
        false => null,
      },
      xFormat: switch (fmt) {
        true => (v, idx) => '#$idx:${jsString(v)}',
        false => null,
      },
      valueFormat: switch (fmt) {
        true => (v) => '\$${JsMath.numberToString(v)}',
        false => null,
      },
    );

void main() {
  for (
    var part = 1;
    File('test/fixtures/charts_xy_$part.json').existsSync();
    part++
  ) {
    for (final c in _list(_load('charts_xy_$part')['cases'])) {
      group(c['name'], () {
        final input = _input(
          c['input'] as Map<String, dynamic>,
          _rows(c['data'] as String),
          c['fmt'] == true,
        );
        final built = buildXYRows(input);
        final spec = built.spec;
        test('spec', () {
          expect(built.rows.length, c['drawn']);
          expect(_clean(spec.toJson()), c['spec']);
        });
        test('summary and table', () {
          expect(
            summarizeXY(spec, kind: 'Chart', title: c['name'] as String),
            c['summary'],
          );
          expect(summarizeXY(spec, kind: 'Bar chart'), c['summaryPlain']);
          expect(_clean(tableXY(spec, xHead: 'Month').toJson()), c['table']);
        });
        for (final l in _list(c['layouts'])) {
          test(
            'layout ${l['w']}x${l['h']} calm: ${l['calm']}',
            () {
              final layout = layoutXY(
                spec,
                Box(_n(l['w']), _n(l['h'])),
                l['calm'] == true,
              );
              expect(_dump(layout, series: true), l['out']);
            },
          );
        }
      });
    }
  }

  test('looks', () {
    for (final c in _list(_fx['looks'])) {
      final kind = XYKind.values.byName(c['kind'] as String);
      final slot = (c['slot'] as num).toInt();
      final drawn = (c['drawn'] as num).toInt();
      final p = _auto(c['p']);
      Map<String, String> look(SeriesLook l) => {
        'pattern': l.pattern.name,
        'marker': l.marker.name,
        'dash': l.dash.name,
      };
      expect(look(autoLook(kind, slot, drawn, p)), c['auto'], reason: '$c');
      expect(
        look(
          seriesLook(
            kind,
            slot,
            drawn,
            p,
            pattern: FillPattern.cross,
            dash: Dash.dashdot,
          ),
        ),
        c['own'],
        reason: '$c',
      );
    }
  });

  test('toNum', () {
    for (final c in _list(_fx['nums'])) {
      final v = switch ((c['v'], c['num'])) {
        ('__undefined', _) => null,
        (final String s, true) => double.parse(s),
        (final Object? o, _) => o,
      };
      expect(toNum(v), c['out'], reason: '$c');
    }
  });

  test('capRows', () {
    for (final c in _list(_fx['caps'])) {
      final out = capRows(
        _rows(c['rows'] as String),
        (c['keys'] as List).cast<String>(),
        XYKind.values.byName(c['kind'] as String),
        c['x'] as String,
      );
      expect(
        _clean({'rows': out.rows, 'total': out.total}),
        c['out'],
        reason: '${c['rows']} ${c['kind']}',
      );
    }
  });

  test('stackRanges', () {
    final spec = buildXY(
      XYBuildInput(
        rows: _rows('gaps'),
        xKey: 'month',
        kind: XYKind.bar,
        series: const [SeriesInput('a'), SeriesInput('b'), SeriesInput('c')],
      ),
    );
    for (final c in _list(_fx['stacks'])) {
      final out = stackRanges(spec.series, c['stacked'] as bool, 9);
      expect(
        _clean([
          for (final row in out)
            [
              for (final r in row)
                switch (r) {
                  (final a, final b) => [a, b],
                  null => null,
                },
            ],
        ]),
        c['out'],
      );
    }
  });

  test('pickTicks', () {
    List<AxisTick> ticks(Object? v) => [
      for (final t in _list(v)) AxisTick(_n(t['v']), t['label'] as String),
    ];
    for (final c in _list(_fx['picks'])) {
      final out = pickTicks(
        ticks(c['d']),
        switch (c['a']) {
          final List<dynamic> sets => [for (final s in sets) ticks(s)],
          _ => null,
        },
        (c['m'] as num).toInt(),
        (_n((c['s'] as List)[0]), _n((c['s'] as List)[1])),
      );
      expect([for (final t in out) t.toJson()], c['out']);
    }
  });

  test('announceRow', () {
    expect(
      announceRow('Mar', [
        (name: 'Revenue', value: '1,234'),
        (name: 'Cost', value: '9'),
      ]),
      _fx['announce'],
    );
  });
}
