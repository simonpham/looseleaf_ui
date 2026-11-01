import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:test/test.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
        as Map<String, dynamic>;

double _d(Object? v) => (v as num).toDouble();

Knobs _knobs(Object? v) {
  final k = v as Map<String, dynamic>;
  return Knobs(
    wobble: _d(k['wobble']),
    misreg: _d(k['misreg']),
    bleed: _d(k['bleed']),
    width: _d(k['width']),
  );
}

void main() {
  final fixture = _fixture('recipes');

  test('orderLayers', () {
    for (final c in (fixture['order'] as List).cast<Map<String, dynamic>>()) {
      final names = [
        for (final n in c['names'] as List)
          LayerName.values.byName(n as String),
      ];
      expect(orderLayers(names).map((l) => l.name), c['out']);
    }
  });

  test('stableStringify', () {
    for (final c
        in (fixture['stringify'] as List).cast<Map<String, dynamic>>()) {
      final v = switch (c['v']) {
        '__undefined' => null,
        '__NaN' => double.nan,
        '__Infinity' => double.infinity,
        final Object? other => other,
      };
      expect(stableStringify(v), c['out'], reason: '$v');
    }
  });

  test('bucketBox', () {
    for (final c in (fixture['buckets'] as List).cast<Map<String, dynamic>>()) {
      final q = switch (c['q']) {
        [final num a, final num b] => (a.toDouble(), b.toDouble()),
        _ => (4.0, 2.0),
      };
      final out = bucketBox(_d(c['w']), _d(c['h']), q);
      expect([out.w, out.h], [c['out']['w'], c['out']['h']]);
    }
  });

  test('knobsKey', () {
    for (final c
        in (fixture['knobsKeys'] as List).cast<Map<String, dynamic>>()) {
      expect(knobsKey(_knobs(c['k'])), c['out']);
    }
  });

  test('resolveKnobs', () {
    final theme = Knobs(wobble: 1.2, misreg: 0.8, bleed: 1.4, width: 1.1);
    for (final c
        in (fixture['resolved'] as List).cast<Map<String, dynamic>>()) {
      expect(
        resolveKnobs(
          theme,
          Density.values.byName(c['density'] as String),
        ).toJson(),
        c['out'],
      );
    }
  });

  test('defineRecipe validates', () {
    expect(
      () => defineRecipe<void>(
        id: 'Bad_Id',
        layers: const [LayerName.rest],
        pad: 1,
        draw: (_, _, _, _) {},
      ),
      throwsArgumentError,
    );
    expect(
      () => defineRecipe<void>(
        id: 'lazy-check',
        layers: const [LayerName.rest],
        lazy: const [LayerName.focus],
        pad: 1,
        draw: (_, _, _, _) {},
      ),
      throwsArgumentError,
    );
    final first = defineRecipe<void>(
      id: 'rev-check',
      layers: const [LayerName.rest],
      pad: 1,
      draw: (_, _, _, _) {},
    );
    final second = defineRecipe<void>(
      id: 'rev-check',
      layers: const [LayerName.rest],
      pad: 1,
      draw: (_, _, _, _) {},
    );
    expect([first.rev, second.rev, first.kind], [1, 2, 'rev-check']);
    expect(getRecipe('rev-check'), same(second));
    expect(allRecipes(), contains(second));
  });

  test('padFor runs after drawing', () {
    final recipe = defineRecipe<double>(
      id: 'pad-fn',
      layers: const [LayerName.rest],
      padFor: (size, extra, ctx) => size.w / 10 + extra,
      draw: (ink, size, extra, ctx) => box(ink, 0, 0, size.w, size.h),
    );
    final frame = runRecipe(
      recipe,
      RunRequest(
        box: const Box(80, 20),
        params: 2.0,
        seed: 's',
        tier: Tier.lo,
        density: Density.comfortable,
        dir: Dir.ltr,
        knobs: Knobs(),
      ),
    );
    expect(frame.pad, 10);
    expect(frame.layers, [LayerName.rest]);
  });
}
