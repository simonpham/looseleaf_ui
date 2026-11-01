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

Map<String, Object?> _json(dynamic p) =>
    (p as dynamic).toJson() as Map<String, Object?>;

T? _enum<T extends Enum>(List<T> values, Object? v, String Function(T) id) {
  for (final value in values) {
    if (id(value) == v) return value;
  }
  return null;
}

_Check<P> _c<P>(Recipe<P> recipe, P Function(_Json p) parse) =>
    _Check<P>(recipe, parse, _json);

final Map<String, _Check<Object?>> _checks = {
  'checkbox': _c<CheckboxParams>(
    checkboxRecipe,
    (p) =>
        CheckboxParams(disabled: _b(p['disabled']), invalid: _b(p['invalid'])),
  ),
  'radio-group': _c<RadioParams>(
    radioRecipe,
    (p) => RadioParams(disabled: _b(p['disabled']), invalid: _b(p['invalid'])),
  ),
  'switch': _c<SwitchParams>(
    switchRecipe,
    (p) => SwitchParams(disabled: _b(p['disabled']), invalid: _b(p['invalid'])),
  ),
  'switch-thumb': _c<SwitchThumbParams>(
    switchThumbRecipe,
    (p) => SwitchThumbParams(disabled: _b(p['disabled'])),
  ),
  'toggle': _c<ToggleParams>(
    toggleRecipe,
    (p) => ToggleParams(
      variant: ToggleVariant.values.firstWhere((v) => v.id == p['variant']),
      disabled: _b(p['disabled']),
      tone: _enum(ToggleTone.values, p['tone'], (t) => t.name),
      joined: _b(p['joined']),
      vertical: _b(p['vertical']),
      invalid: _b(p['invalid']),
    ),
  ),
  'toggle-group': _c<ToggleGroupParams>(
    toggleGroupRecipe,
    (p) => ToggleGroupParams(
      joined: _b(p['joined']),
      disabled: _b(p['disabled']),
      invalid: _b(p['invalid']),
    ),
  ),
  'slider-track': _c<SliderTrackParams>(
    sliderTrackRecipe,
    (p) => SliderTrackParams(
      vertical: _b(p['vertical']),
      ticks: (p['ticks'] as num?)?.toInt(),
      disabled: _b(p['disabled']),
      invalid: _b(p['invalid']),
    ),
  ),
  'slider-range': _c<SliderRangeParams>(
    sliderRangeRecipe,
    (p) => SliderRangeParams(
      vertical: _b(p['vertical']),
      tone: _enum(SliderTone.values, p['tone'], (t) => t.id),
      disabled: _b(p['disabled']),
    ),
  ),
  'slider-thumb': _c<SliderThumbParams>(
    sliderThumbRecipe,
    (p) => SliderThumbParams(
      disabled: _b(p['disabled']),
      invalid: _b(p['invalid']),
    ),
  ),
  'progress': _c<NoParams>(progressRecipe, (_) => const NoParams()),
  'progress-fill': _c<ProgressFillParams>(
    progressFillRecipe,
    (p) => ProgressFillParams(
      tone: _enum(ProgressTone.values, p['tone'], (t) => t.name),
      indeterminate: _b(p['indeterminate']),
    ),
  ),
};

_Json _load(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync()) as _Json;

void main() {
  for (final c in (_load('controls_toggles')['frames'] as List).cast<_Json>()) {
    test(c['name'], () {
      final check = _checks[c['recipe']];
      if (check == null) fail('no check for ${c['recipe']}');
      check.run(c);
    });
  }

  final extra = _load('controls_toggles_extra');
  for (final s in (extra['spinners'] as List).cast<_Json>()) {
    test('spinnerMark ${s['seed']}', () {
      final res = spinnerMark(
        s['seed'] as String,
        _d(s['px']),
        shape: _enum(SpinnerShape.values, s['shape'], (v) => v.name),
        w: _od(s['w']),
        h: _od(s['h']),
        tier: _enum(Tier.values, s['tier'], (v) => v.name),
        calm: switch (s['calm']) {
          final bool calm => calm,
          _ => null,
        },
      );
      final out = s['out'] as _Json;
      expect([res.w, res.h, res.pad], [out['w'], out['h'], out['pad']]);
      expect(res.layers.map((l) => l.name), out['layers']);
      expect(res.svg, out['svg']);
      final parts = out['parts'] as _Json;
      expect(res.parts.keys.map((k) => k.name), parts.keys);
      for (final MapEntry(:key, :value) in parts.entries) {
        expect(res.parts[LayerName.values.byName(key)], value, reason: key);
      }
    });
  }
  test('skeleton tiles', () {
    final css = extra['skeletonCss'] as String;
    for (var f = 0; f < skeletonFrames; f++) {
      final t = skeletonTiles(f);
      expect(
        css,
        contains(
          '--ll-sk-eh$f:${t.edgeH};--ll-sk-ev$f:${t.edgeV};'
          '--ll-sk-ha$f:${t.hatch};--ll-sk-ci$f:${t.circle};',
        ),
      );
    }
    expect(css, contains('${skeletonBoilSeconds}s steps(1,end)'));
  });
  test('item tiles', () {
    final css = extra['itemCss'] as String;
    for (var f = 0; f < itemFrames; f++) {
      final t = itemTiles(f);
      expect(
        css,
        contains(
          '--ll-it-eh$f:${t.edgeH};--ll-it-ev$f:${t.edgeV};--ll-it-ru$f:${t.rule};',
        ),
      );
    }
  });
}
