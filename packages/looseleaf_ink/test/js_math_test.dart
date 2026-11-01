import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:test/test.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
        as Map<String, dynamic>;

double _d(Object? v) => (v as num).toDouble();

void main() {
  final fixture = _fixture('js_math');

  void check(String name, double Function(List<dynamic> args) fn) {
    test(name, () {
      for (final c in (fixture[name] as List).cast<List<dynamic>>()) {
        final want = c.last;
        final got = fn(c);
        expect(
          got,
          want,
          reason: '$name(${c.sublist(0, c.length - 1).join(', ')})',
        );
      }
    });
  }

  check('sin', (c) => JsMath.sin(_d(c[0])));
  check('cos', (c) => JsMath.cos(_d(c[0])));
  check('exp', (c) => JsMath.exp(_d(c[0])));
  check('log', (c) => JsMath.log(_d(c[0])));
  check('atan', (c) => JsMath.atan(_d(c[0])));
  check('atan2', (c) => JsMath.atan2(_d(c[0]), _d(c[1])));
  check('hypot', (c) => JsMath.hypot(_d(c[0]), _d(c[1])));
  check('round', (c) => JsMath.round(_d(c[0])));

  test('pow', () {
    var misses = 0;
    for (final c in (fixture['pow'] as List).cast<List<dynamic>>()) {
      final got = JsMath.pow(_d(c[0]), _d(c[1]));
      final want = _d(c[2]);
      if (got == want) continue;
      misses++;
      expect(
        (got - want).abs(),
        lessThanOrEqualTo(want.abs() * 4.5e-16),
        reason: 'pow(${c[0]}, ${c[1]})',
      );
    }
    expect(
      misses,
      lessThan(40),
      reason: 'V8 calls the platform pow; fdlibm agrees to the last bit almost always',
    );
  });

  test('numberToString', () {
    for (final c in (fixture['strings'] as List).cast<List<dynamic>>()) {
      expect(JsMath.numberToString(_d(c[0])), c[1]);
    }
  });

  test('toFixed', () {
    for (final c in (fixture['fixed'] as List).cast<List<dynamic>>()) {
      expect(JsMath.toFixed(_d(c[0]), 2), c[1], reason: '${c[0]}');
    }
  });
}
