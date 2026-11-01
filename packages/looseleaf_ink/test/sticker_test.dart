import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:test/test.dart';

typedef _Json = Map<String, dynamic>;

final _Json _fx =
    jsonDecode(File('test/fixtures/sticker.json').readAsStringSync()) as _Json;

List<_Json> _list(Object? v) => (v as List).cast<_Json>();

Peel? _peel(Object? v) => switch (v) {
  true => const Peel.auto(),
  final num size => Peel(size.toDouble()),
  _ => null,
};

Object? _cut(CutShape cut) => switch (cut) {
  CutRect() => {'kind': 'rect'},
  CutPath(:final fills, :final lines, :final w, :final border) => {
    'kind': 'path',
    'fills': fills,
    'lines': lines,
    'W': w,
    'border': border,
  },
};

void main() {
  test('stickerLabel, categoryLabel, hasSticker', () {
    for (final c in _list(_fx['labels'])) {
      expect(stickerLabel(c['name'] as String), c['out']);
    }
    for (final c in _list(_fx['categories'])) {
      expect(categoryLabel(c['key'] as String), c['out']);
    }
    for (final c in _list(_fx['has'])) {
      expect(hasSticker(c['name'] as String), c['out']);
    }
  });

  test('stickerCatalog', () {
    expect([
      for (final e in stickerCatalog())
        {
          'name': e.name,
          'label': e.label,
          'category': e.category,
          'categoryLabel': e.categoryLabel,
          'tags': e.tags,
        },
    ], _fx['catalog']);
  });

  group('stickerFace and kissCut', () {
    for (final c in _list(_fx['faces'])) {
      final o = c['o'] as _Json;
      test('${c['name']} ${c['px']} ${jsonEncode(o)}', () {
        final face = stickerFace(
          c['name'] as String,
          (c['px'] as num).toDouble(),
          c['seed'] as String,
          peel: _peel(o['peel']),
          idPrefix: o['idPrefix'] as String?,
          border: (o['border'] as num?)?.toDouble(),
        );
        if (face == null) {
          expect(c['out'], isNull);
          return;
        }
        final out = c['out'] as _Json;
        final FaceBox(:x, :y, :w, :h) = face.box;
        expect(
          {
            'name': face.name,
            'w': face.w,
            'h': face.h,
            'box': {'x': x, 'y': y, 'w': w, 'h': h},
            'cut': _cut(face.cut),
          },
          {
            'name': out['name'],
            'w': out['w'],
            'h': out['h'],
            'box': out['box'],
            'cut': out['cut'],
          },
        );
        expect(face.svg, out['svg']);
        expect(kissCut(face, 'k-${c['seed']}'), c['kiss']);
      });
    }
  });
}
