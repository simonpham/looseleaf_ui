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

Map<String, Object?> _none(NoParams p) => p.toJson();

NoParams _noParams(_Json p) => const NoParams();

ScrollBarParams _scroll(_Json p) => ScrollBarParams(
  orientation: ScrollOrientation.values.byName(p['orientation'] as String),
);

final Map<String, _Check<Object?>> _checks = {
  'calendar-grid': _Check<CalendarGridParams>(
    calendarGridRecipe,
    (p) => CalendarGridParams(
      rows: (p['rows'] as num).toInt(),
      weekNumbers: _b(p['weekNumbers']),
    ),
    (p) => p.toJson(),
  ),
  'calendar-dropdown': _Check<CalendarDropdownParams>(
    calendarDropdownRecipe,
    (p) => CalendarDropdownParams(disabled: _b(p['disabled'])),
    (p) => p.toJson(),
  ),
  'command-input': _Check<NoParams>(commandInputRecipe, _noParams, _none),
  'menubar': _Check<NoParams>(menubarRecipe, _noParams, _none),
  'navigation-menu-tab': _Check<NavTabParams>(
    navTabRecipe,
    (p) => NavTabParams(
      role: NavTabRole.values.byName(p['role'] as String),
      disabled: _b(p['disabled']),
    ),
    (p) => p.toJson(),
  ),
  'navigation-menu-baseline': _Check<NoParams>(
    navBaselineRecipe,
    _noParams,
    _none,
  ),
  'resizable': _Check<ResizableParams>(
    resizableRecipe,
    (p) => ResizableParams(
      line: ResizableLine.values.byName(p['line'] as String),
      grip: _b(p['grip']),
      disabled: _b(p['disabled']),
    ),
    (p) => p.toJson(),
  ),
  'scroll-track': _Check<ScrollBarParams>(
    scrollTrackRecipe,
    _scroll,
    (p) => p.toJson(),
  ),
  'scroll-thumb': _Check<ScrollBarParams>(
    scrollThumbRecipe,
    _scroll,
    (p) => p.toJson(),
  ),
  'sidebar-mark': _Check<SidebarMarkParams>(
    sidebarMarkRecipe,
    (p) => SidebarMarkParams(
      active: _b(p['active']),
      outline: _b(p['outline']),
    ),
    (p) => p.toJson(),
  ),
  'sidebar-rule': _Check<NoParams>(sidebarRuleRecipe, _noParams, _none),
  'tabs': _Check<TabsParams>(
    tabsRecipe,
    (p) => TabsParams(
      variant: TabsVariant.values.firstWhere((v) => v.id == p['variant']),
      orientation: TabsOrientation.values.byName(p['orientation'] as String),
      disabled: _b(p['disabled']),
    ),
    (p) => p.toJson(),
  ),
};

_Json _read(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync()) as _Json;

void main() {
  for (final c
      in (_read('controls_navigation')['frames'] as List).cast<_Json>()) {
    test(c['name'], () {
      final check = _checks[c['recipe']];
      if (check == null) fail('no check for ${c['recipe']}');
      check.run(c);
    });
  }

  final tiles = _read('controls_navigation_tiles');
  List<_Json> cases(String key) => (tiles[key] as List).cast<_Json>();
  group('calendar tiles', () {
    for (final c in cases('ring')) {
      test('ring ${c['seed']}', () {
        expect(ringTile(c['seed'] as String), c['out']);
      });
    }
    for (final c in cases('wash')) {
      test('wash ${c['seed']}', () {
        expect(washTile(c['seed'] as String), c['out']);
      });
    }
    for (final c in cases('underline')) {
      test('underline ${c['seed']} ${c['double']}', () {
        expect(underlineTile(c['seed'] as String, _b(c['double'])), c['out']);
      });
    }
    for (final c in cases('focus')) {
      test('focus ${c['seed']}', () {
        expect(focusTile(c['seed'] as String), c['out']);
      });
    }
    for (final c in cases('band')) {
      test('band ${c['seed']} ${c['left']} ${c['right']}', () {
        expect(
          bandTile(c['seed'] as String, _b(c['left']), _b(c['right'])),
          c['out'],
        );
      });
    }
  });
  for (final c in cases('underlineMark')) {
    test('underlineMark ${c['seed']}', () {
      final o = c['o'] as _Json;
      final res = underlineMark(
        c['seed'] as Object,
        w: _od(o['w']),
        h: _od(o['h']),
        tier: switch (o['tier']) {
          final String t => Tier.values.byName(t),
          _ => null,
        },
        calm: switch (o['calm']) {
          final bool v => v,
          _ => null,
        },
      );
      final out = c['out'] as _Json;
      expect(res.svg, out['svg']);
      expect([res.w, res.h, res.pad], [out['w'], out['h'], out['pad']]);
      expect(res.layers.map((l) => l.name), out['layers']);
    });
  }
}
