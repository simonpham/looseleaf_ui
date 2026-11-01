import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:test/test.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
        as Map<String, dynamic>;

double _d(Object? v) => (v as num).toDouble();

ButtonParams _params(Map<String, dynamic> p) => ButtonParams(
  variant: ButtonVariant.values.firstWhere((v) => v.id == p['variant']),
  size: ButtonSize.values.firstWhere((s) => s.id == p['size']),
  disabled: p['disabled'] == true,
  shape: switch (p['shape']) {
    'pill' => ButtonShape.pill,
    'default' => ButtonShape.standard,
    _ => null,
  },
);

List<LayerName> _layers(Object? v) => [
  for (final n in v as List? ?? const []) LayerName.values.byName(n as String),
];

void main() {
  final frames = (_fixture('button')['frames'] as List)
      .cast<Map<String, dynamic>>();
  for (final c in frames) {
    test(c['name'], () {
      final params = _params(c['params'] as Map<String, dynamic>);
      final knobs = c['knobs'] as Map<String, dynamic>;
      final frame = runRecipe(
        buttonRecipe,
        RunRequest(
          box: Box(_d(c['w']), _d(c['h'])),
          params: params,
          seed: c['seed'] as String,
          tier: Tier.values.byName(c['tier'] as String),
          density: Density.values.byName(c['density'] as String),
          dir: Dir.ltr,
          knobs: Knobs(
            wobble: _d(knobs['wobble']),
            misreg: _d(knobs['misreg']),
            bleed: _d(knobs['bleed']),
            width: _d(knobs['width']),
          ),
          lazy: _layers(c['lazy']),
          lazyOnly: c['lazyOnly'] == true,
          pad: switch (c['pad']) {
            final num p => p.toDouble(),
            _ => null,
          },
        ),
      );
      final out = c['out'] as Map<String, dynamic>;
      expect(stableStringify(params.toJson()), c['key']);
      expect(frame.layers.map((l) => l.name), out['layers']);
      expect(frame.lazyLayers.map((l) => l.name), out['lazyLayers']);
      expect([frame.pad, frame.w, frame.h], [out['pad'], out['w'], out['h']]);
      final parts = out['parts'] as Map<String, dynamic>;
      expect(frame.parts.keys.map((k) => k.name), parts.keys);
      for (final MapEntry(:key, :value) in parts.entries) {
        expect(frame.parts[LayerName.values.byName(key)], value, reason: key);
      }
    });
  }
}
