import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/src/charts/charts.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:test/test.dart';

final Map<String, dynamic> _fx =
    jsonDecode(
          File('test/fixtures/charts.json').readAsStringSync(),
        )
        as Map<String, dynamic>;

List<Map<String, dynamic>> _list(Object? v) =>
    (v as List).cast<Map<String, dynamic>>();

double _n(Object? v) => switch (v) {
  final num x => x.toDouble(),
  final String s => double.parse(s),
  _ => double.nan,
};

List<double> _ns(Object? v) => [for (final x in v as List) _n(x)];

Object? _clean(Object? v) => switch (v) {
  final num x when !x.isFinite => null,
  final List<Object?> l => [for (final x in l) _clean(x)],
  final Map<String, Object?> m => {
    for (final MapEntry(:key, :value) in m.entries) key: ?_clean(value),
  },
  _ => v,
};

List<List<double>> _pts(List<Pt> pts) => [
  for (final (x, y) in pts) [x, y],
];

List<Pt> _toPts(Object? v) => [
  for (final p in v as List) (_n(p[0]), _n(p[1])),
];

void main() {
  test('log10 and pow10', () {
    for (final c in _fx['log10'] as List) {
      final x = _n(c[0]);
      expect(jsLog10(x), c[1], reason: '$x');
      expect(jsPow10(jsLog10(x).floorToDouble()), c[2], reason: '$x');
    }
  });

  test('niceScale, ticksIn, coarserTicks', () {
    for (final c in _list(_fx['scales'])) {
      final s = niceScale(_n(c['a']), _n(c['b']), (c['c'] as num).toInt());
      expect(
        _clean({'min': s.min, 'max': s.max, 'step': s.step, 'ticks': s.ticks}),
        c['out'],
        reason: '$c',
      );
    }
    for (final c in _list(_fx['ticks'])) {
      expect(
        ticksIn(_n(c['a']), _n(c['b']), (c['c'] as num).toInt()),
        c['out'],
      );
    }
    for (final c in _list(_fx['coarser'])) {
      expect(coarserTicks(_n(c['a']), _n(c['b']), _ns(c['d'])), c['out']);
    }
  });

  test('shares and radarRim', () {
    for (final c in _list(_fx['shares'])) {
      expect(shares(_ns(c['v']), (c['d'] as num).toInt()), c['out']);
    }
    for (final c in _list(_fx['rims'])) {
      expect(radarRim(_n(c['t']), _n(c['l'])), c['out'], reason: '$c');
    }
  });

  test('formats', () {
    for (final c in _list(_fx['formats'])) {
      final v = _n(c['v']);
      expect(formatNumber(v), c['number'], reason: '$v');
      expect(formatNumber(v, 0), c['number0'], reason: '$v');
      expect(formatNumber(v, 4), c['number4'], reason: '$v');
      expect(formatCompact(v), c['compact'], reason: '$v');
      expect(formatPercent(v), c['pct'], reason: '$v');
      expect(formatPercent(v, 1), c['pct1'], reason: '$v');
      expect(_clean(roundTo(v)), c['round'], reason: '$v');
      expect(_clean(roundTo(v, 0)), c['round0'], reason: '$v');
      expect(_clean(roundTo(v, 10)), c['round10'], reason: '$v');
    }
  });

  test('text measure and label picking', () {
    for (final c in _list(_fx['texts'])) {
      final s = c['s'] as String;
      expect(textWidth(s, 15), c['script'], reason: s);
      expect(textWidth(s, 12.5, LabelFont.hand), c['hand'], reason: s);
      expect(textWidth(s, 13, LabelFont.mono), c['mono'], reason: s);
      expect(labelWidth(s, 16), c['label'], reason: s);
    }
    for (final c in _list(_fx['picks'])) {
      final out = pickLabelIndices(_ns(c['w']), _n(c['p']));
      expect({'idx': out.idx, 'stride': out.stride}, c['out'], reason: '$c');
    }
    for (final c in _list(_fx['clears'])) {
      final items = [
        for (final it in _list(c['items'])) (x: _n(it['x']), w: _n(it['w'])),
      ];
      final out = clearLabels(items, (it) => it.x, (it) => it.w);
      expect([
        for (final it in out) {'x': it.x, 'w': it.w},
      ], c['out']);
    }
  });

  test('curves and thinning', () {
    for (final c in _list(_fx['curves'])) {
      final pts = _toPts(c['pts']);
      expect(_pts(monotoneCurve(pts)), c['mono']);
      expect(_pts(monotoneCurve(pts, 3)), c['mono3']);
      expect(_pts(stepCurve(pts)), c['step']);
    }
    final wave = [
      for (var i = 0; i < 300; i++)
        (
          i.toDouble(),
          JsMath.sin(i / 7) * 40 +
              JsMath.cos(i / 23) * 25 +
              switch (i % 17) {
                0 => 30,
                _ => 0,
              },
        ),
    ];
    for (final c in _list(_fx['lttbs'])) {
      final n = (c['n'] as num).toInt();
      expect(lttb(wave.sublist(0, n), (c['t'] as num).toInt()), c['out']);
    }
    for (final c in _list(_fx['thins'])) {
      final n = (c['n'] as num).toInt(), m = (c['m'] as num).toInt();
      expect(thinIndices(n, m), c['thin']);
      expect(strideIndices(n, m), c['stride']);
    }
  });

  test('misc', () {
    final misc = _fx['misc'] as Map<String, dynamic>;
    expect(
      [0, 279.9, 280, 559, 560, 1200].map((w) => bucketOf(w.toDouble()).name),
      misc['buckets'],
    );
    for (final c in _list(misc['clamps'])) {
      expect(_clean(clampN(_n(c['v']), _n(c['a']), _n(c['b']))), c['out']);
    }
    final slots = misc['slots'] as List;
    for (final (k, s) in [-9, -1, 0, 3, 7, 8, 15, 100].indexed) {
      expect([
        slotKey(s).id,
        defaultPattern(s).name,
        defaultMarker(s).name,
        defaultDash(s).name,
      ], slots[k]);
    }
  });

  group('heat data', () {
    final heat = _fx['heat'] as Map<String, dynamic>;
    final calRows = <CalendarInput>[
      for (final r in _list(heat['calRows']))
        (date: r['date'], value: r['value']),
    ];
    test('days', () {
      for (final c in _list(heat['dates'])) {
        final ms = dayMs(c['d']);
        expect(ms.isNaN, _n(c['ms']).isNaN, reason: '${c['d']}');
        if (!ms.isNaN) expect(ms, c['ms'], reason: '${c['d']}');
      }
      for (final c in _list(heat['days'])) {
        final ms = _n(c['ms']);
        expect(isoDay(ms), c['iso']);
        expect(formatDay(ms), c['day']);
        expect(formatDay(ms, true), c['dayYear']);
      }
    });
    test('levelOf', () {
      for (final c in _list(heat['levels'])) {
        final t = switch (c['t']) {
          final List<dynamic> list => _ns(list),
          _ => null,
        };
        final v = switch (c['v']) {
          null => null,
          final x => _n(x),
        };
        expect(
          levelOf(v, _n(c['m']), (c['l'] as num).toInt(), t),
          c['out'],
          reason: '$c',
        );
      }
    });
    test('calendars', () {
      for (final c in _list(heat['calendars'])) {
        final o = c['o'] as Map<String, dynamic>;
        final out = buildCalendar(
          calRows,
          levels: (o['levels'] as num).toInt(),
          weeks: (o['weeks'] as num?)?.toInt(),
          end: o['end'],
          weekStart: (o['weekStart'] as num?)?.toInt() ?? 0,
          thresholds: switch (o['thresholds']) {
            final List<dynamic> list => _ns(list),
            _ => null,
          },
          weekdayLabels: o['weekdayLabels'] != false,
          monthLabels: o['monthLabels'] != false,
        );
        expect(_clean(out.toJson()), c['out'], reason: '$o');
      }
      expect(
        _clean(buildCalendar(const [], levels: 5).toJson()),
        heat['emptyCal'],
      );
    });
    test('grids', () {
      final data = <GridInput>[
        for (final d in _list(heat['gridData']))
          (row: d['row'], col: d['col'], value: d['value']),
      ];
      for (final c in _list(heat['grids'])) {
        final o = c['o'] as Map<String, dynamic>;
        final out = buildGrid(
          data,
          levels: (o['levels'] as num).toInt(),
          rows: (o['rows'] as List?)?.cast<String>(),
          cols: (o['cols'] as List?)?.cast<String>(),
          thresholds: switch (o['thresholds']) {
            final List<dynamic> list => _ns(list),
            _ => null,
          },
        );
        expect(_clean(out.toJson()), c['out'], reason: '$o');
      }
    });
  });
}
