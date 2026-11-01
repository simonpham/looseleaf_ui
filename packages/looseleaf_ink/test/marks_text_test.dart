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

bool? _ob(Object? v) => v as bool?;

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
  'strike': _Entry<StrikeParams>(
    strikeRecipe,
    (p) => StrikeParams(
      line: _line(p),
      kind: _by(StrikeKind.values, p['kind']),
      tone: _tone(p['tone']),
      weight: _weight(p['weight']),
    ),
    (p) => p.toJson(),
  ),
  'scribble': _Entry<ScribbleParams>(
    scribbleRecipe,
    (p) => ScribbleParams(
      line: _line(p),
      tone: _tone(p['tone']),
      weight: _weight(p['weight']),
    ),
    (p) => p.toJson(),
  ),
  'highlight': _Entry<HighlightParams>(
    highlightRecipe,
    (p) => HighlightParams(
      line: _line(p),
      tone: _by(HighlightTone.values, p['tone'], (t) => t.id),
      fat: _od(p['fat']),
      cover: switch (p['cover']) {
        final String c => HighlightCover.values.byName(c),
        _ => null,
      },
    ),
    (p) => p.toJson(),
  ),
  'tally': _Entry<TallyParams>(
    tallyRecipe,
    (p) => TallyParams(
      count: p['count'] as int,
      gh: _d(p['gh']),
      tone: _tone(p['tone']),
      weight: _weight(p['weight']),
      rtl: _ob(p['rtl']),
    ),
    (p) => p.toJson(),
  ),
  'arrow': _Entry<ArrowParams>(
    arrowRecipe,
    (p) => ArrowParams(
      direction: _by(ArrowDirection.values, p['direction'], (d) => d.id),
      curve: _by(ArrowCurve.values, p['curve']),
      head: _by(ArrowHead.values, p['head']),
      tone: _tone(p['tone']),
      weight: _weight(p['weight']),
      bend: _by(ArrowBend.values, p['bend']),
      mirror: p['mirror'] as bool,
      dx: _od(p['dx']),
      dy: _od(p['dy']),
      animate: _ob(p['animate']),
    ),
    (p) => p.toJson(),
  ),
  'bracket': _Entry<BracketParams>(
    bracketRecipe,
    (p) => BracketParams(
      kind: _by(BracketKind.values, p['kind']),
      side: _by(BracketSide.values, p['side']),
      tone: _tone(p['tone']),
      weight: _weight(p['weight']),
      inset: _d(p['inset']),
      animate: _ob(p['animate']),
    ),
    (p) => p.toJson(),
  ),
  'circled': _Entry<CircledParams>(
    circledRecipe,
    (p) => CircledParams(
      line: _line(p),
      shape: _by(CircledShape.values, p['shape']),
      tone: _tone(p['tone']),
      weight: _weight(p['weight']),
      bleed: _od(p['bleed']),
    ),
    (p) => p.toJson(),
  ),
  'quote': _Entry<QuoteParams>(
    quoteRecipe,
    (p) => QuoteParams(
      tone: _tone(p['tone']),
      weight: _weight(p['weight']),
      size: _d(p['size']),
      rule: p['rule'] as bool,
      animate: _ob(p['animate']),
    ),
    (p) => p.toJson(),
  ),
  'signature': _Entry<SignatureParams>(
    signatureRecipe,
    (p) => SignatureParams(
      flourish: _by(SignatureFlourish.values, p['flourish']),
      tone: _tone(p['tone']),
      weight: _weight(p['weight']),
      fs: _d(p['fs']),
      animate: _ob(p['animate']),
    ),
    (p) => p.toJson(),
  ),
  'squiggle': _Entry<SquiggleParams>(
    squiggleRecipe,
    (p) => SquiggleParams(
      kind: _by(SquiggleKind.values, p['kind']),
      orientation: _by(SquiggleOrientation.values, p['orientation']),
      tone: _tone(p['tone']),
      weight: _weight(p['weight']),
      animate: _ob(p['animate']),
    ),
    (p) => p.toJson(),
  ),
  'margin-bracket': _Entry<MarginBracketParams>(
    marginBracketRecipe,
    (p) => MarginBracketParams(kind: _by(BracketKind.values, p['kind'])),
    (p) => p.toJson(),
  ),
  'marker-rule': _Entry<MarkerRuleParams>(
    markerRuleRecipe,
    (p) => MarkerRuleParams(
      side: _by(MarkerSide.values, p['side']),
      tone: _by(MarkerTone.values, p['tone'], (t) => t.id),
      style: switch (p['style']) {
        final String s => MarkerStyle.values.byName(s),
        _ => null,
      },
    ),
    (p) => p.toJson(),
  ),
};

double? _bleed(Object? v) => switch (v) {
  '__NaN' => double.nan,
  final num x => x.toDouble(),
  _ => null,
};

Map<String, Object?> _knobs(Knobs k) => k.toJson();

void _helpers(_Json h) {
  group('helpers', () {
    test('lineMetrics', () {
      for (final c in (h['lineMetrics'] as List).cast<_Json>()) {
        final r = switch (c['r']) {
          final _Json r => FontRatios(
            asc: _d(r['asc']),
            desc: _d(r['desc']),
            xh: _d(r['xh']),
            cap: _d(r['cap']),
            pdesc: _d(r['pdesc']),
          ),
          _ => guessRatios,
        };
        expect(lineMetrics(_d(c['h']), _d(c['fs']), r).toJson(), c['out']);
      }
    });
    test('markPen', () {
      for (final c in (h['markPen'] as List).cast<_Json>()) {
        final (:pen, :width, :dry) = markPen(
          _tone(c['tone']),
          _weight(c['weight']),
          _d(c['fs']),
          pencil: c['pencil'] as bool,
        );
        final out = c['out'] as _Json;
        expect([pen.id, width, dry], [out['pen'], out['width'], out['dry']]);
      }
    });
    test('overshoot', () {
      for (final c in (h['overshoot'] as List).cast<_Json>()) {
        expect(overshoot(_d(c['fs'])), c['out']);
      }
    });
    test('tallyBox', () {
      for (final c in (h['tallyBox'] as List).cast<_Json>()) {
        final box = tallyBox(c['count'] as int, _d(c['gh']));
        final out = c['out'] as _Json;
        expect([box.w, box.h], [out['w'], out['h']]);
      }
    });
    test('arrowReach', () {
      for (final c in (h['arrowReach'] as List).cast<_Json>()) {
        final p = c['p'] as _Json;
        expect(arrowReach(dx: _od(p['dx']), dy: _od(p['dy'])), c['out']);
      }
    });
    test('bleedOf', () {
      for (final c in (h['bleedOf'] as List).cast<_Json>()) {
        expect(bleedOf(_bleed(c['bleed'])), c['out']);
      }
    });
    test('circledReach', () {
      for (final c in (h['circledReach'] as List).cast<_Json>()) {
        expect(
          circledReach(
            _d(c['w']),
            _d(c['h']),
            _d(c['fs']),
            _od(c['bleed']),
          ),
          c['out'],
        );
      }
    });
    test('loopRadii', () {
      for (final c in (h['loopRadii'] as List).cast<_Json>()) {
        final (rx, ry) = loopRadii(
          _d(c['tw']),
          _d(c['th']),
          _d(c['fs']),
          _d(c['ch']),
          _od(c['bleed']),
          _d(c['h']),
        );
        expect([rx, ry], c['out']);
      }
    });
    test('boilKnobs', () {
      for (final c in (h['boilKnobs'] as List).cast<_Json>()) {
        expect(
          _knobs(boilKnobs(c['frame'] as int, _d(c['strength']))),
          c['out'],
        );
      }
    });
    test('boilSeed', () {
      for (final c in (h['boilSeed'] as List).cast<_Json>()) {
        expect(boilSeed(c['seed'] as Object, c['frame'] as int), c['out']);
      }
    });
  });
}

void main() {
  final fixture = jsonDecode(
    File('test/fixtures/marks_text.json').readAsStringSync(),
  ) as _Json;
  _helpers(fixture['helpers'] as _Json);
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
