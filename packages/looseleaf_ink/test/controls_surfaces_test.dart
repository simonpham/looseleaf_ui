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

T _byId<T extends Enum>(List<T> values, Object? id, String Function(T) idOf) =>
    values.firstWhere((v) => idOf(v) == id);

Map<String, Object?> _none(NoParams p) => p.toJson();

NoParams _noParams(_Json p) => const NoParams();

final Map<String, _Check<Object?>> _checks = {
  'accordion-rule': _Check<NoParams>(accordionRuleRecipe, _noParams, _none),
  'accordion-trigger': _Check<AccordionTriggerParams>(
    accordionTriggerRecipe,
    (p) => AccordionTriggerParams(disabled: _b(p['disabled'])),
    (p) => p.toJson(),
  ),
  'alert': _Check<AlertParams>(
    alertRecipe,
    (p) => AlertParams(tone: _byId(AlertTone.values, p['tone'], (t) => t.id)),
    (p) => p.toJson(),
  ),
  'alert-media': _Check<AlertMediaParams>(
    alertMediaRecipe,
    (p) => AlertMediaParams(
      tone: _byId(AlertMediaTone.values, p['tone'], (t) => t.id),
    ),
    (p) => p.toJson(),
  ),
  'avatar-ring': _Check<AvatarRingParams>(
    avatarRingRecipe,
    (p) =>
        AvatarRingParams(ring: AvatarRing.values.byName(p['ring'] as String)),
    (p) => p.toJson(),
  ),
  'avatar-fallback': _Check<AvatarFallbackParams>(
    avatarFallbackRecipe,
    (p) => AvatarFallbackParams(
      tone: AvatarTone.values.byName(p['tone'] as String),
    ),
    (p) => p.toJson(),
  ),
  'avatar-badge': _Check<AvatarBadgeParams>(
    avatarBadgeRecipe,
    (p) => AvatarBadgeParams(
      status: AvatarStatus.values.byName(p['status'] as String),
    ),
    (p) => p.toJson(),
  ),
  'avatar-count': _Check<NoParams>(avatarCountRecipe, _noParams, _none),
  'badge': _Check<BadgeParams>(
    badgeRecipe,
    (p) => BadgeParams(
      variant: _byId(BadgeVariant.values, p['variant'], (v) => v.id),
      size: _byId(BadgeSize.values, p['size'], (s) => s.id),
      tone: switch (p['tone']) {
        final String t => BadgeTone.values.byName(t),
        _ => null,
      },
      tally: switch (p['tally']) {
        final num t => t.toInt(),
        _ => null,
      },
      hoverable: _b(p['hoverable']),
    ),
    (p) => p.toJson(),
  ),
  'breadcrumb-page': _Check<NoParams>(breadcrumbPageRecipe, _noParams, _none),
  'button-group-text': _Check<NoParams>(
    buttonGroupTextRecipe,
    _noParams,
    _none,
  ),
  'card-rule': _Check<CardRuleParams>(
    cardRuleRecipe,
    (p) => CardRuleParams(
      edge: CardRuleEdge.values.byName(p['edge'] as String),
      style: CardRuleStyle.values.byName(p['style'] as String),
    ),
    (p) => p.toJson(),
  ),
  'hover-card-media': _Check<NoParams>(hoverCardMediaRecipe, _noParams, _none),
  'kbd': _Check<NoParams>(kbdRecipe, _noParams, _none),
  'overlay-close': _Check<CloseMarkParams>(
    closeMarkRecipe,
    (p) => CloseMarkParams(
      tone: switch (p['tone']) {
        final String t => CloseMarkTone.values.byName(t),
        _ => null,
      },
    ),
    (p) => p.toJson(),
  ),
  'sheet-binding': _Check<SheetBindingParams>(
    sheetBindingRecipe,
    (p) => SheetBindingParams(
      edge: BindingEdge.values.byName(p['edge'] as String),
      kind: BindingKind.values.byName(p['kind'] as String),
    ),
    (p) => p.toJson(),
  ),
};

_Json _load(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync()) as _Json;

void main() {
  final fixture = _load('controls_surfaces');
  for (final c in (fixture['frames'] as List).cast<_Json>()) {
    test(c['name'], () {
      final check = _checks[c['recipe']];
      if (check == null) fail('no check for ${c['recipe']}');
      check.run(c);
    });
  }

  final helpers = _load('controls_surfaces_helpers');
  group('avatar names', () {
    for (final c in (helpers['names'] as List).cast<_Json>()) {
      test('"${c['name']}"', () {
        final name = c['name'] as String;
        expect(avatarTone(name).name, c['tone']);
        expect(avatarInitials(name), c['initials']);
      });
    }
  });
  test('badgeTallyWidth', () {
    for (final c in (helpers['tally'] as List).cast<_Json>()) {
      expect(
        badgeTallyWidth(c['count'] as int, _d(c['h'])),
        c['out'],
        reason: '${c['count']} @ ${c['h']}',
      );
    }
  });
  for (final c in (helpers['pointer'] as List).cast<_Json>()) {
    test('pointerMark ${c['seed']}', () {
      final res = pointerMark(
        c['seed'] as Object,
        w: _od(c['w']),
        h: _od(c['h']),
        tier: switch (c['tier']) {
          final String t => Tier.values.byName(t),
          _ => null,
        },
        calm: switch (c['calm']) {
          final bool b => b,
          _ => null,
        },
      );
      final out = c['out'] as _Json;
      expect(
        [res.svg, res.w, res.h, res.pad],
        [
          out['svg'],
          out['w'],
          out['h'],
          out['pad'],
        ],
      );
    });
  }
  test('tableTiles', () {
    final tiles = tableTiles();
    final out = helpers['table'] as _Json;
    expect(tiles.rule, out['rule']);
    expect(tiles.head, out['head']);
    expect(tiles.capStart, out['capStart']);
    expect(tiles.capEnd, out['capEnd']);
  });
}
