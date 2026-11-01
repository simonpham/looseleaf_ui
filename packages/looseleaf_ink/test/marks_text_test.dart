import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:test/test.dart';

typedef _Json = Map<String, dynamic>;

double _d(Object? v) => (v as num).toDouble();

double? _od(Object? v) => switch (v) {
  final num x => x.toDouble(),
  _ => null,
};

T _by<T extends Enum>(List<T> values, Object? id, [String Function(T)? key]) =>
    values.firstWhere((v) => (key?.call(v) ?? v.name) == id);

List<LayerName> _layers(Object? v) => [
  for (final n in v as List? ?? const []) LayerName.values.byName(n as String),
];

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
        lazy: _layers(c['lazy']),
        lazyOnly: c['lazyOnly'] == true,
        pad: _od(c['pad']),
      ),
    );
    return (frame, stableStringify(json(params)));
  }
}

LineParams _line(_Json p) => LineParams(
  metrics: LineMetrics(
    fs: _d(p['fs']),
    base: _d(p['base']),
    xh: _d(p['xh']),
    cap: _d(p['cap']),
    desc: _d(p['desc']),
    ch: _d(p['ch']),
  ),
  first: p['first'] as bool,
  last: p['last'] as bool,
  n: p['n'] as int,
  animate: p['animate'] as bool?,
);

MarkPen _tone(Object? v) => _by(MarkPen.values, v, (t) => t.id);

MarkWeight _weight(Object? v) => _by(MarkWeight.values, v);

final Map<String, _Entry<Object?>> _entries = {
  'underline': _Entry<UnderlineParams>(
    underlineRecipe,
    (p) => UnderlineParams(
      line: _line(p),
      kind: _by(UnderlineMarkKind.values, p['kind']),
      tone: _tone(p['tone']),
      weight: _weight(p['weight']),
    ),
    (p) => p.toJson(),
  ),
};

void main() {
  final fixture = jsonDecode(
    File('test/fixtures/marks_text.json').readAsStringSync(),
  ) as _Json;
  for (final c in (fixture['frames'] as List).cast<_Json>()) {
    test(c['name'], () {
      final entry = _entries[c['recipe']];
      if (entry == null) fail('no entry for ${c['recipe']}');
      final (frame, key) = entry.run(c);
      final out = c['out'] as _Json;
      expect(key, c['key']);
      expect(frame.layers.map((l) => l.name), out['layers']);
      expect(frame.lazyLayers.map((l) => l.name), out['lazyLayers']);
      expect([frame.pad, frame.w, frame.h], [out['pad'], out['w'], out['h']]);
      final parts = out['parts'] as _Json;
      expect(frame.parts.keys.map((k) => k.name), parts.keys);
      for (final MapEntry(:key, :value) in parts.entries) {
        expect(frame.parts[LayerName.values.byName(key)], value, reason: key);
      }
    });
  }
}
