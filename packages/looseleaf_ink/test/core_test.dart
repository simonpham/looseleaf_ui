import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:test/test.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
        as Map<String, dynamic>;

List<double> _stream(Rng r, int count) => [for (var i = 0; i < count; i++) r()];

double _num(Object? v) => switch (v) {
  final num n => n.toDouble(),
  'NaN' => double.nan,
  'Infinity' => double.infinity,
  _ => throw ArgumentError('not a number: $v'),
};

void main() {
  final fixture = _fixture('core');

  group('rng', () {
    for (final c in (fixture['rng'] as List).cast<Map<String, dynamic>>()) {
      test('seed ${jsonEncode(c['seed'])}', () {
        final r = Rng(c['seed'] as Object);
        expect(r.seed, c['hashed']);
        expect(_stream(r, 8), c['plain']);
        expect([r.range(-3, 5), r.range(0.42, 0.6)], c['range']);
        expect([
          r.integer(3, 7),
          r.integer(-2, 2),
          r.integer(0, 100),
        ], c['ints']);
        expect([r.chance(0.5), r.chance(0.1), r.chance(0.9)], c['chances']);
        expect([r.sign(), r.sign(), r.sign()], c['signs']);
        expect([
          r.pick(['a', 'b', 'c', 'd']),
          r.pick([1, 2, 3]),
        ], c['picks']);
        expect([
          r.gauss(),
          r.gauss(),
          r.gauss(2, 0.5),
          r.gauss(0, 0.012),
          r.gauss(),
        ], c['gauss']);
        expect(_stream(r, 3), c['after']);
        for (final f in (c['forks'] as List).cast<Map<String, dynamic>>()) {
          expect(
            _stream(r.fork(f['name'] as Object), 4),
            f['values'],
            reason: 'fork ${f['name']}',
          );
        }
        expect(_stream(r.fork('a').fork('b').fork(3), 4), c['nested']);
      });
    }
  });

  test('hashSeed', () {
    for (final c in (fixture['hashes'] as List).cast<Map<String, dynamic>>()) {
      final input = switch (c['input']) {
        'NaN' => double.nan,
        'Infinity' => double.infinity,
        final Object other => other,
        null => throw ArgumentError('null input'),
      };
      expect(hashSeed(input), c['hash'], reason: '$input');
    }
  });

  test('noise1', () {
    for (final c in (fixture['noise'] as List).cast<Map<String, dynamic>>()) {
      final f = noise1(
        Rng(c['seed'] as String),
        _num(c['length']),
        _num(c['wavelength']),
      );
      expect(
        [for (final s in c['at'] as List) f(_num(s))],
        c['values'],
        reason: '${c['seed']}',
      );
    }
  });

  test('wander', () {
    for (final c in (fixture['wanders'] as List).cast<Map<String, dynamic>>()) {
      final f = wander(Rng(c['seed'] as String), [
        for (final p in c['periods'] as List) _num(p),
      ]);
      expect(
        [for (final s in c['at'] as List) f(_num(s))],
        c['values'],
        reason: '${c['seed']}',
      );
    }
  });

  test('n', () {
    for (final c in (fixture['formats'] as List).cast<Map<String, dynamic>>()) {
      final v = _num(c['v']);
      expect(
        [n(v, 10), n(v), n(v, 100)],
        [c['q10'], c['q20'], c['q100']],
        reason: '$v',
      );
    }
  });

  test('fmtUnits', () {
    for (final c in (fixture['units'] as List).cast<Map<String, dynamic>>()) {
      expect(fmtUnits(c['k'] as int, c['q'] as int), c['s'], reason: '$c');
    }
  });

  test('paint', () {
    final paints = (fixture['paints'] as List).cast<Map<String, dynamic>>();
    expect(paints.map((p) => p['key']), PaintKey.values.map((k) => k.id));
    for (final p in paints) {
      expect(
        paint(PaintKey.byId(p['key'] as String) ?? PaintKey.ink),
        p['css'],
      );
    }
  });

  test('esc', () {
    for (final c in (fixture['escapes'] as List).cast<Map<String, dynamic>>()) {
      expect(esc(c['s'] as String), c['out']);
    }
  });
}
