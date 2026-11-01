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

double _num(Object? v) => switch (v) {
  final num x => x.toDouble(),
  'NaN' => double.nan,
  'Infinity' => double.infinity,
  '-Infinity' => double.negativeInfinity,
  _ => throw ArgumentError('not a number: $v'),
};

Object _out(double v) => switch (v.isFinite) {
  true => v,
  false => JsMath.numberToString(v),
};

bool? _ob(Object? v) => v as bool?;

final Map<String, _Entry<Object?>> _entries = {
  'sketchpad-tool': _Entry<SketchToolParams>(
    sketchToolRecipe,
    (p) => SketchToolParams(
      tool: SketchTool.values.byName(p['tool'] as String),
      color: _by(SketchColor.values, p['color'], (c) => c.id),
    ),
    (p) => p.toJson(),
  ),
  'sketchpad-swatch': _Entry<SketchSwatchParams>(
    sketchSwatchRecipe,
    (p) => SketchSwatchParams(
      color: _by(SketchColor.values, p['color'], (c) => c.id),
    ),
    (p) => p.toJson(),
  ),
  'sketchpad-size': _Entry<SketchSizeParams>(
    sketchSizeRecipe,
    (p) => SketchSizeParams(
      size: SketchSizeName.values.byName(p['size'] as String),
    ),
    (p) => p.toJson(),
  ),
  'sketchpad-canvas': _Entry<NoParams>(
    canvasFrameRecipe,
    (p) => const NoParams(),
    (p) => p.toJson(),
  ),
  'sticker-board-item': _Entry<ItemFrameParams>(
    stickerBoardItemRecipe,
    (p) => ItemFrameParams(
      selected: p['selected'] as bool,
      handles: p['handles'] as bool,
    ),
    (p) => p.toJson(),
  ),
  'sticker-sheet': _Entry<StickerSheetParams>(
    stickerSheetRecipe,
    (p) => StickerSheetParams(top: _d(p['top'])),
    (p) => p.toJson(),
  ),
  'sticker-slot': _Entry<NoParams>(
    stickerSlotRecipe,
    (p) => const NoParams(),
    (p) => p.toJson(),
  ),
  'stepper': _Entry<StepperParams>(
    stepperRecipe,
    (p) => StepperParams(
      disabled: _ob(p['disabled']),
      invalid: _ob(p['invalid']),
      plain: _ob(p['plain']),
    ),
    (p) => p.toJson(),
  ),
  'stepper-tally': _Entry<StepperTallyParams>(
    stepperTallyRecipe,
    (p) => StepperTallyParams(count: p['count'] as int),
    (p) => p.toJson(),
  ),
  'tear-off-seam': _Entry<TearSeamParams>(
    tearSeamRecipe,
    (p) => TearSeamParams(scissors: _ob(p['scissors']), inset: _od(p['inset'])),
    (p) => p.toJson(),
  ),
  'tear-off-hint': _Entry<TearHintParams>(
    tearHintRecipe,
    (p) =>
        TearHintParams(toward: TearToward.values.byName(p['toward'] as String)),
    (p) => p.toJson(),
  ),
  'tear-off-stub': _Entry<NoParams>(
    tearStubRecipe,
    (p) => const NoParams(),
    (p) => p.toJson(),
  ),
  'typewriter-caret': _Entry<CaretParams>(
    typewriterCaretRecipe,
    (p) => CaretParams(shape: CaretShape.values.byName(p['shape'] as String)),
    (p) => p.toJson(),
  ),
  'typing-indicator': _Entry<TypingParams>(
    typingIndicatorRecipe,
    (p) => TypingParams(
      variant: TypingVariant.values.byName(p['variant'] as String),
      pen: switch (p['pen']) {
        final String pen => TypingPen.values.byName(pen),
        _ => null,
      },
      pencil: _ob(p['pencil']),
    ),
    (p) => p.toJson(),
  ),
};

SketchStroke _stroke(_Json s) => SketchStroke(
  id: s['id'] as String,
  tool: DrawTool.values.byName(s['tool'] as String),
  color: _by(SketchColor.values, s['color'], (c) => c.id),
  size: _d(s['size']),
  pts: [
    for (final p in (s['pts'] as List).cast<List>())
      (
        _num(p[0]),
        _num(p[1]),
        switch (p.length) {
          3 => _num(p[2]),
          _ => null,
        },
      ),
  ],
);

List<List<double>> _pts(List<Pt> pts) => [
  for (final (x, y) in pts) [x, y],
];

List<Object> _item(StickerBoardItem s) => [
  s.id,
  s.name,
  _out(s.x),
  _out(s.y),
  _out(s.rot),
  _out(s.scale),
  _out(s.z),
];

List<Object?> _itemJson(_Json s) => [
  s['id'],
  s['name'],
  for (final k in ['x', 'y', 'rot', 'scale', 'z'])
    switch (s[k]) {
      final num v => v.toDouble(),
      final other => other,
    },
];

StickerBoardItem _itemOf(_Json s) => StickerBoardItem(
  id: s['id'] as String,
  name: s['name'] as String,
  x: _num(s['x']),
  y: _num(s['y']),
  rot: _num(s['rot']),
  scale: _num(s['scale']),
  z: _num(s['z']),
);

void main() {
  final fixture = jsonDecode(
    File('test/fixtures/marks_tools.json').readAsStringSync(),
  ) as _Json;
  group('frames', () {
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
  });

  final strokes = {
    for (final s in (fixture['strokes'] as List).cast<_Json>())
      s['id'] as String: _stroke(s),
  };
  SketchStroke strokeOf(Object? id) =>
      strokes[id] ?? (throw StateError('no stroke $id'));

  test('cleanPoints', () {
    for (final c in (fixture['cleanPoints'] as List).cast<_Json>()) {
      final out = c['out'] as _Json;
      final (:pts, :pressure) = cleanPoints(strokeOf(c['id']).pts);
      expect(_pts(pts), out['pts'], reason: c['id'] as String);
      expect(pressure, out['pressure'], reason: c['id'] as String);
    }
  });

  test('strokeMarkup', () {
    clearStrokeCache();
    for (final c in (fixture['strokeMarkup'] as List).cast<_Json>()) {
      final out = c['out'] as _Json;
      final m = strokeMarkup(
        strokeOf(c['id']),
        tier: Tier.values.byName(c['tier'] as String),
        live: c['live'] as bool,
      );
      final reason = '${c['id']} ${c['tier']} ${c['live']}';
      expect(m.svg, out['svg'], reason: reason);
      expect(m.centre, out['centre'], reason: reason);
      expect(m.length, out['length'], reason: reason);
      final (x0, y0, x1, y1) = m.bbox;
      expect([x0, y0, x1, y1], out['bbox'], reason: reason);
    }
    expect(strokeCacheStats().entries, greaterThan(0));
    clearStrokeCache();
    expect(strokeCacheStats().entries, 0);
  });

  test('strokeBounds and strokeHit', () {
    for (final c in (fixture['bounds'] as List).cast<_Json>()) {
      final (x0, y0, x1, y1) = strokeBounds(strokeOf(c['id']));
      expect([x0, y0, x1, y1], c['out'], reason: c['id'] as String);
    }
    for (final c in (fixture['hits'] as List).cast<_Json>()) {
      expect(
        strokeHit(strokeOf(c['id']), _d(c['x']), _d(c['y']), _d(c['r'])),
        c['out'],
        reason: '${c['id']} ${c['x']} ${c['y']} ${c['r']}',
      );
    }
  });

  test('cursorMarkup and svgDataUrl', () {
    for (final c in (fixture['cursor'] as List).cast<_Json>()) {
      expect(cursorMarkup(c['seed'] as String), c['out']);
    }
    for (final c in (fixture['dataUrl'] as List).cast<_Json>()) {
      expect(svgDataUrl(c['svg'] as String), c['out']);
    }
  });

  test('typingPlan', () {
    for (final c in (fixture['typingPlan'] as List).cast<_Json>()) {
      final o = c['o'] as _Json;
      final plan = typingPlan(
        (c['phrases'] as List).cast<String>(),
        TypingOptions(
          speed: _d(o['speed']),
          pause: _d(o['pause']),
          mode: TypingMode.values.byName(o['mode'] as String),
          seed: o['seed'] as String,
          loop: o['loop'] == true,
        ),
      );
      final out = c['out'] as _Json;
      expect(plan.total, out['total']);
      expect(
        [
          for (final s in plan.steps) [s.at, s.text],
        ],
        [
          for (final s in (out['steps'] as List).cast<_Json>())
            [s['at'], s['text']],
        ],
      );
    }
  });

  test('typingGeometry, tallyWidth, wholeItems', () {
    for (final c in (fixture['typingGeometry'] as List).cast<_Json>()) {
      final g = typingGeometry(
        _d(c['w']),
        _d(c['h']),
        TypingVariant.values.byName(c['variant'] as String),
      );
      final out = c['out'] as _Json;
      expect(
        [g.y, g.xs, g.x0, g.x1, g.span],
        [
          out['y'],
          out['xs'],
          out['x0'],
          out['x1'],
          out['span'],
        ],
      );
    }
    for (final c in (fixture['tallyWidth'] as List).cast<_Json>()) {
      final count = c['count'] as int;
      final w = switch (c['gh']) {
        final num gh => tallyWidth(count, gh.toDouble()),
        _ => tallyWidth(count),
      };
      expect(w, c['out']);
    }
    for (final c in (fixture['wholeItems'] as List).cast<_Json>()) {
      final items = [
        for (final s in (c['items'] as List).cast<_Json>()) _itemOf(s),
      ];
      final out = wholeItems(items);
      expect(out.map(_item), [
        for (final s in (c['out'] as List).cast<_Json>()) _itemJson(s),
      ]);
      expect(identical(out, items), c['same']);
    }
  });
}
