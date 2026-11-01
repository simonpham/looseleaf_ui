import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:test/test.dart';

typedef _Json = Map<String, dynamic>;

double _d(Object? v) => (v as num).toDouble();

double? _od(Object? v) => switch (v) {
  final num n => n.toDouble(),
  _ => null,
};

bool _b(Object? v) => v == true;

List<LayerName> _layers(Object? v) => [
  for (final n in v as List? ?? const []) LayerName.values.byName(n as String),
];

final class _Check<P> {
  const _Check(this.recipe, this.parse, this.toJson);

  final Recipe<P> recipe;
  final P Function(_Json p) parse;
  final Map<String, Object?> Function(P p) toJson;

  void run(_Json c) {
    final params = parse(c['params'] as _Json);
    final knobs = c['knobs'] as _Json;
    final frame = runRecipe(
      recipe,
      RunRequest(
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
        lazyOnly: _b(c['lazyOnly']),
        pad: _od(c['pad']),
      ),
    );
    final out = c['out'] as _Json;
    expect(stableStringify(toJson(params)), c['key']);
    expect(frame.layers.map((l) => l.name), out['layers']);
    expect(frame.lazyLayers.map((l) => l.name), out['lazyLayers']);
    expect([frame.pad, frame.w, frame.h], [out['pad'], out['w'], out['h']]);
    final parts = out['parts'] as _Json;
    expect(frame.parts.keys.map((k) => k.name), parts.keys);
    for (final MapEntry(:key, :value) in parts.entries) {
      expect(frame.parts[LayerName.values.byName(key)], value, reason: key);
    }
  }
}

SelectParams _select(_Json p) => SelectParams(
  disabled: _b(p['disabled']),
  invalid: _b(p['invalid']),
  cell: _od(p['cell']),
);

Map<String, Object?> _selectJson(SelectParams p) => p.toJson();

final Map<String, _Check<Object?>> _checks = {
  'input': _Check<InputParams>(
    inputRecipe,
    (p) => InputParams(
      disabled: _b(p['disabled']),
      invalid: _b(p['invalid']),
      readOnly: _b(p['readOnly']),
    ),
    (p) => p.toJson(),
  ),
  'textarea': _Check<TextareaParams>(
    textareaRecipe,
    (p) => TextareaParams(
      disabled: _b(p['disabled']),
      invalid: _b(p['invalid']),
      readOnly: _b(p['readOnly']),
      ruled: _b(p['ruled']),
      lineHeight: _od(p['lineHeight']),
      ruleTop: _od(p['ruleTop']),
      grip: _b(p['grip']),
    ),
    (p) => p.toJson(),
  ),
  'select': _Check<SelectParams>(selectRecipe, _select, _selectJson),
  'native-select': _Check<SelectParams>(
    nativeSelectRecipe,
    _select,
    _selectJson,
  ),
  'date-picker': _Check<SelectParams>(datePickerRecipe, _select, _selectJson),
  'combobox-trigger': _Check<SelectParams>(
    comboboxTriggerRecipe,
    _select,
    _selectJson,
  ),
  'combobox-chips': _Check<ComboboxChipsParams>(
    comboboxChipsRecipe,
    (p) => ComboboxChipsParams(
      disabled: _b(p['disabled']),
      invalid: _b(p['invalid']),
    ),
    (p) => p.toJson(),
  ),
  'combobox-chip': _Check<ComboboxChipParams>(
    comboboxChipRecipe,
    (p) => ComboboxChipParams(
      tone: ChipTone.values.byName(p['tone'] as String),
      disabled: _b(p['disabled']),
    ),
    (p) => p.toJson(),
  ),
};

void main() {
  final fixture =
      jsonDecode(
            File('test/fixtures/controls_fields.json').readAsStringSync(),
          )
          as _Json;
  for (final c in (fixture['frames'] as List).cast<_Json>()) {
    test(c['name'], () {
      final check = _checks[c['recipe']];
      if (check == null) fail('no check for ${c['recipe']}');
      check.run(c);
    });
  }
}
