import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:test/test.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
        as Map<String, dynamic>;

double? _d(Object? v) => switch (v) {
  final num n => n.toDouble(),
  _ => null,
};

List<Pt> _pts(Object? v) => [
  for (final p in v as List)
    (_d((p as List)[0]) ?? double.nan, _d(p[1]) ?? double.nan),
];

final Map<String, double Function(double)> _presses = {
  'taper': (t) => 1 - 0.5 * t,
  'swell': (t) => 0.6 + JsMath.sin(JsMath.pi * t) * 0.6,
};

StrokeOpts _opts(Map<String, dynamic> o) => StrokeOpts(
  tier: switch (o['tier']) {
    final String t => Tier.values.byName(t),
    _ => null,
  },
  wobble: _d(o['wobble']),
  speed: _d(o['speed']),
  start: switch (o['start']) {
    final String s => StrokeStart.values.byName(s),
    _ => null,
  },
  end: switch (o['end']) {
    final String e => StrokeEnd.values.byName(e),
    _ => null,
  },
  width: _d(o['width']),
  alpha: _d(o['alpha']),
  color: switch (o['color']) {
    final String c => PaintKey.byId(c),
    _ => null,
  },
  poly: o['poly'] as bool?,
  round: _d(o['round']),
  raw: o['raw'] as bool?,
  dry: _d(o['dry']),
  press: _presses[o['press']],
  simple: o['simple'] as bool?,
);

Map<String, Object?> _json(StrokeResult r) => {
  'kind': r.kind.name,
  'layers': [
    for (final l in r.layers)
      {
        'k': l.k.name,
        'd': l.d,
        'fill': l.fill.id,
        'op': l.op,
        'rule': switch (l.evenOdd) {
          true => 'evenodd',
          false => null,
        },
      },
  ],
  'bbox': r.bbox.toList(),
  'len': r.len,
  'start': [r.start.x, r.start.y],
  'end': [r.end.x, r.end.y],
};

PenName _pen(Object? id) =>
    PenName.byId(id as String) ?? (throw ArgumentError('unknown pen $id'));

void main() {
  final fixture = _fixture('pen');
  final points = fixture['points'] as Map<String, dynamic>;

  test('pen table', () {
    final pens = (fixture['pens'] as List).cast<Map<String, dynamic>>();
    expect(
      pens.map((p) => p['name']).toSet(),
      PenName.values.map((p) => p.id).toSet(),
    );
    for (final p in pens) {
      expect(_pen(p['name']).spec.toJson(), p['spec'], reason: '${p['name']}');
    }
  });

  group('stroke', () {
    for (final (i, c)
        in (fixture['strokes'] as List).cast<Map<String, dynamic>>().indexed) {
      test('#$i ${c['pen']} ${c['points']} ${c['seed']}', () {
        final res = stroke(
          _pts(points[c['points']]),
          _pen(c['pen']),
          Rng(c['seed'] as String),
          _opts(c['o'] as Map<String, dynamic>),
        );
        expect(_json(res), c['out']);
      });
    }
  });

  group('dot', () {
    for (final (i, c)
        in (fixture['dots'] as List).cast<Map<String, dynamic>>().indexed) {
      test('#$i ${c['pen']} ${c['tier']}', () {
        final o = _opts({...c['o'] as Map<String, dynamic>, 'tier': c['tier']});
        final res = dot(
          10,
          12,
          _d(c['r']) ?? 0,
          _pen(c['pen']),
          Rng(c['seed'] as String),
          o,
        );
        expect(_json(res), c['out']);
      });
    }
  });
}
