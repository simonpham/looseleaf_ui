import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/src/art/art.dart';
import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:test/test.dart';

final Map<String, dynamic> _fixture = jsonDecode(
  File('test/fixtures/art_core_1.json').readAsStringSync(),
) as Map<String, dynamic>;

List<Map<String, dynamic>> _list(Object? v) =>
    (v as List).cast<Map<String, dynamic>>();

double? _d(Object? v) => switch (v) {
  final num n => n.toDouble(),
  _ => null,
};

T? _enum<T extends Enum>(List<T> values, Object? v) => switch (v) {
  final String name => values.byName(name),
  _ => null,
};

PaintKey? _paint(Object? v) => switch (v) {
  final String id => PaintKey.byId(id),
  _ => null,
};

double? _json(double v) => switch (v.isFinite) {
  true => v,
  false => null,
};

List<Object> _pts(List<Pt> pts) => [
  for (final (x, y) in pts) [_json(x), _json(y)],
];

Object? _colour(ArtColour? c) => c?.id;

Object _hand(Hand h) => {
  if (h.start case final start?) 'start': start.name,
  if (h.end case final end?) 'end': end.name,
  'taper': ?h.taper,
};

List<Object?> _trim(List<Object?> v) {
  final out = [...v];
  while (out.isNotEmpty && out.last == null) {
    out.removeLast();
  }
  return out;
}

List<Object?> _part(ArtPart p) => switch (p) {
  FillPart(:final colour, :final d, :final mis) => _trim([
    'f',
    _colour(colour),
    d,
    mis,
  ]),
  StrokePart(:final d, :final width, :final hand) => _trim([
    's',
    d,
    width,
    switch (hand) {
      final h? => _hand(h),
      null => null,
    },
  ]),
  ColourStrokePart(:final colour, :final d, :final width, :final hand) => _trim(
    [
      'c',
      _colour(colour),
      d,
      width,
      switch (hand) {
        final h? => _hand(h),
        null => null,
      },
    ],
  ),
  DotPart(:final x, :final y, :final r) => _trim(['d', x, y, r]),
  HighlightPart(:final d, :final width) => _trim(['h', d, width]),
  TextPart(
    :final text,
    :final x,
    :final y,
    :final size,
    :final colour,
    :final font,
  ) =>
    _trim(['t', text, x, y, size, _colour(colour), font?.name]),
};

Map<String, Object?> _def(ArtDef def) => {
  'grid': switch (def.grid.pair) {
    true => [def.grid.w, def.grid.h],
    false => def.grid.w,
  },
  'nibK': def.nibK,
  'parts': def.parts.map(_part).toList(),
  if (def.small case final small?) 'small': small.map(_part).toList(),
  'kind': def.kind?.name,
  'tags': ?def.tags,
};

BadgeOpts _badgeOpts(Map<String, dynamic> o) => BadgeOpts(
  shape: _enum(BadgeShape.values, o['shape']),
  color: _paint(o['color']),
  sub: o['sub'] as String?,
  deco: _enum(BadgeDeco.values, o['deco']),
  textColor: _paint(o['textColor']),
  bumps: switch (o['bumps']) {
    final int b => b,
    _ => null,
  },
  amp: _d(o['amp']),
  tags: (o['tags'] as List?)?.cast<String>(),
  fill: switch (o['fill']) {
    final String id => ArtColour.parse(id),
    _ => null,
  },
);

StampOpts _stampOpts(Map<String, dynamic> o) => StampOpts(
  seed: o['seed'],
  tilt: _d(o['tilt']),
  sub: o['sub'] as String?,
  ring: o['ring'] as String?,
  ink: switch (o['ink']) {
    final String id => StampPadInk.values.firstWhere((i) => i.paint.id == id),
    _ => null,
  },
  ghost: o['ghost'] as bool?,
  dashed: o['dashed'] as bool?,
  w: _d(o['w']),
  h: _d(o['h']),
  stars: o['stars'] as int?,
  grain: o['grain'] as bool?,
);

void _expectResult(InkResult r, Map<String, dynamic> out) {
  expect(r.svg, out['svg']);
  expect([r.pad, r.w, r.h], [out['pad'], out['w'], out['h']]);
  expect(r.layers.map((l) => l.name), out['layers']);
  expect(r.bbox.toList(), out['bbox']);
}

void main() {
  final dsl = _fixture['dsl'] as Map<String, dynamic>;

  group('dsl', () {
    test('tokenize', () {
      for (final c in _list(dsl['tokenize'])) {
        final r = tokenize(c['d'] as String);
        final out = c['out'] as Map<String, dynamic>;
        expect([r.tok, r.bad], [out['tok'], out['bad']], reason: c['d']);
      }
    });
    test('parsePath', () {
      for (final c in _list(dsl['parse'])) {
        final rnd = switch (c['seed']) {
          final String seed => Rng(seed).call,
          _ => null,
        };
        final subs = parsePath(
          c['d'] as String,
          step: _d(c['step']) ?? 0.6,
          rnd: rnd,
        );
        final got = [
          for (final s in subs)
            {
              'pts': _pts(s.pts),
              'closed': s.closed,
              'anchor': s.anchor,
              'shape': s.shape,
            },
        ];
        expect(got, c['out'], reason: '${c['d']} ${c['seed']}');
      }
    });
    test('polygonsOf', () {
      for (final c in _list(dsl['polygons'])) {
        final polys = polygonsOf(
          c['d'] as String,
          rnd: Rng(c['seed'] as String).call,
        );
        expect(polys.map(_pts).toList(), c['out'], reason: c['d']);
      }
    });
  });

  final text = _fixture['text'] as Map<String, dynamic>;
  group('lettering', () {
    test('measureText', () {
      for (final c in _list(text['measure'])) {
        final font = LetterFont.values.byName(c['font'] as String);
        final w = measureText(
          font,
          c['t'] as String,
          _d(c['size']) ?? 0,
          _d(c['spacing']) ?? 0,
        );
        expect(w, c['out'], reason: '${c['t']} ${c['font']}');
      }
    });
    test('capHeight', () {
      for (final c in _list(text['cap'])) {
        final font = LetterFont.values.byName(c['font'] as String);
        expect(capHeight(font, _d(c['size']) ?? 0), c['out']);
      }
    });
    test('hasGlyph', () {
      for (final c in _list(text['glyphs'])) {
        expect(
          hasGlyph(c['font'] as String, c['ch'] as String),
          c['out'],
          reason: '${c['font']} ${c['ch']}',
        );
      }
    });
    test('textPath', () {
      for (final c in _list(text['paths'])) {
        final o = c['o'] as Map<String, dynamic>;
        final r = textPath(
          c['t'] as String,
          _d(c['x']) ?? 0,
          _d(c['y']) ?? 0,
          _d(c['em']) ?? 0,
          Rng(c['seed'] as String),
          TextOpts(
            font: _enum(LetterFont.values, o['font']),
            anchor: _enum(TextAnchor.values, o['anchor']),
            spacing: _d(o['spacing']),
            jitter: _d(o['jitter']),
            rot: _d(o['rot']),
            squeeze: _d(o['squeeze']),
            q: o['q'] as int?,
          ),
        );
        final out = c['out'] as Map<String, dynamic>;
        final reason = '${c['t']} $o';
        expect(r.d, out['d'], reason: reason);
        expect(r.width, out['width'], reason: reason);
        expect(r.bbox.toList(), out['bbox'], reason: reason);
      }
    });
  });

  group('badges', () {
    final badges = _list(_fixture['badges']);
    for (final c in badges) {
      test('${c['text']} ${c['o']}', () {
        final def = badgeSkeleton(
          c['text'] as String,
          _badgeOpts(c['o'] as Map<String, dynamic>),
        );
        expect(_def(def), c['def']);
      });
    }
    for (final c in _list(_fixture['cases'])) {
      test('die cut ${c['i']}', () {
        final b = badges[c['i'] as int];
        final def = badgeSkeleton(
          b['text'] as String,
          _badgeOpts(b['o'] as Map<String, dynamic>),
        );
        final r = dieCut(def, _d(c['size']) ?? 0, c['seed'] as String);
        _expectResult(r.result, c['out'] as Map<String, dynamic>);
      });
    }
  });

  group('stamps', () {
    for (final c in _list(_fixture['stamps'])) {
      test('${c['text']} ${c['shape']} ${c['o']}', () {
        final r = stamp(
          c['text'] as String,
          StampShape.values.firstWhere((s) => s.id == c['shape']),
          _stampOpts(c['o'] as Map<String, dynamic>),
        );
        _expectResult(r, c['out'] as Map<String, dynamic>);
      });
    }
  });

  final meta = _fixture['meta'] as Map<String, dynamic>;
  group('catalog', () {
    test('variantFor', () {
      for (final c in _list(meta['variants'])) {
        final kind = ArtKind.values.byName(c['kind'] as String);
        expect(variantFor(kind, _d(c['size']) ?? 0).name, c['out']);
      }
      for (final c in _list(meta['mascotVariants'])) {
        expect(mascotVariant(_d(c['size']) ?? 0).name, c['out']);
      }
    });
    test('partsFor', () {
      for (final c in _list(meta['partCounts'])) {
        final def = icons[c['id']];
        if (def == null) fail('no icon ${c['id']}');
        expect([
          for (final v in Variant.values) partsFor(def, v).length,
        ], c['out']);
      }
    });
    test('kindOfDef', () {
      ArtGrid grid(Object? g) => switch (g) {
        24 => ArtGrid.icon,
        64 => ArtGrid.doodle,
        [final num w, final num h] => ArtGrid(w.toDouble(), h.toDouble()),
        _ => ArtGrid.doodle,
      };
      for (final c in _list(meta['kinds'])) {
        final def = ArtDef(grid: grid(c['grid']), parts: const []);
        expect(kindOfDef(def).name, c['out']);
      }
    });
    test('icon names', () {
      for (final c in _list(meta['names'])) {
        final name = c['name'] as String;
        expect(kebabIconName(name), c['kebab'], reason: name);
        expect(resolveIconName(name), c['out'], reason: name);
      }
      expect(iconNamed('LucideHome'), same(icons['house']));
    });
    test('ids', () {
      final ids = meta['ids'] as Map<String, dynamic>;
      Map<String, List<String>> keysOf<T>(Map<String, Map<String, T>> m) => {
        for (final MapEntry(:key, :value) in m.entries)
          key: value.keys.toList(),
      };
      expect(icons.keys, ids['icons']);
      expect(keysOf(iconBatches), ids['iconBatches']);
      expect(doodles.keys, ids['doodles']);
      expect(stickers.keys, ids['stickers']);
      expect(keysOf(stickerBatches), ids['stickerBatches']);
      expect(mascot.keys, ids['mascot']);
      expect(mascotPropDefs.keys, ids['mascotProps']);
      expect(mascotFrames.keys, ids['mascotFrames']);
      expect(scenes.keys, ids['scenes']);
    });
  });
}
