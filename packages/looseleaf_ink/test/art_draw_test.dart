import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/src/art/art.dart';
import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:test/test.dart';

List<Map<String, dynamic>> _chunks(String name) {
  final files =
      Directory('test/fixtures')
          .listSync()
          .whereType<File>()
          .where((f) => RegExp('${name}_\\d+\\.json\$').hasMatch(f.path))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  return [
    for (final f in files)
      jsonDecode(f.readAsStringSync()) as Map<String, dynamic>,
  ];
}

List<Map<String, dynamic>> _cases(String name) => [
  for (final chunk in _chunks(name))
    ...(chunk['cases'] as List).cast<Map<String, dynamic>>(),
];

double? _d(Object? v) => switch (v) {
  final num n => n.toDouble(),
  _ => null,
};

Object _seed(Object? v) => switch (v) {
  final num n => n,
  _ => '$v',
};

T? _enum<T extends Enum>(List<T> values, Object? v) => switch (v) {
  final String name => values.byName(name),
  _ => null,
};

PaintKey? _paint(Object? v) => switch (v) {
  final String id => PaintKey.byId(id),
  _ => null,
};

bool? _bool(Object? v) => switch (v) {
  final bool b => b,
  _ => null,
};

DrawOpts _drawOpts(Map<String, dynamic> o) => DrawOpts(
  tone: _enum(ArtTone.values, o['tone']),
  tier: _enum(Tier.values, o['tier']),
  ink: _paint(o['ink']),
  accent: _enum(ArtAccent.values, o['accent']),
  crisp: _bool(o['crisp']),
  calm: _bool(o['calm']),
  grain: _bool(o['grain']),
);

DieCutOpts _dieCutOpts(Map<String, dynamic> o) => DieCutOpts(
  tier: _enum(Tier.values, o['tier']),
  shadow: _bool(o['shadow']),
  peel: switch (o['peel']) {
    true => const Peel.auto(),
    final num size => Peel(size.toDouble()),
    _ => null,
  },
);

void _expectResult(InkResult r, Map<String, dynamic> out) {
  expect(r.svg, out['svg']);
  expect([r.pad, r.w, r.h], [out['pad'], out['w'], out['h']]);
  expect(r.layers.map((l) => l.name), out['layers']);
  expect(r.bbox.toList(), out['bbox']);
}

void _expectSkeleton(SkeletonResult r, Map<String, dynamic> out) {
  _expectResult(r.result, out);
  expect([r.variant.name, r.nib, r.k], [out['variant'], out['nib'], out['k']]);
  if (r case DieCutResult(:final off, :final border)) {
    expect([off, border], [out['off'], out['border']]);
  }
}

void _drawGroup(
  String name,
  Map<String, ArtDef> defs, {
  String fixture = '',
}) {
  group(name, () {
    for (final c in _cases(fixture)) {
      final id = c['id'] as String;
      final o = c['o'] as Map<String, dynamic>;
      test('$id ${c['size']} $o', () {
        final def = defs[id];
        if (def == null) fail('no $name "$id"');
        final r = drawSkeleton(
          def,
          _d(c['size']) ?? 0,
          _seed(c['seed']),
          _drawOpts(o),
        );
        _expectSkeleton(r, c['out'] as Map<String, dynamic>);
      });
    }
  });
}

void main() {
  _drawGroup('icons', icons, fixture: 'art_icons');
  _drawGroup('doodles', doodles, fixture: 'art_doodles');

  group('stickers', () {
    for (final c in _cases('art_stickers')) {
      final id = c['id'] as String;
      final o = c['o'] as Map<String, dynamic>;
      test('$id ${c['size']} $o', () {
        final def = stickers[id];
        if (def == null) fail('no sticker "$id"');
        final r = renderSticker(
          def,
          _d(c['size']) ?? 0,
          _seed(c['seed']),
          _dieCutOpts(o),
        );
        _expectResult(r, c['out'] as Map<String, dynamic>);
      });
    }
  });

  group('mascot', () {
    final tables = {
      'mascot': mascot,
      'props': mascotPropDefs,
      'frames': mascotFrames,
    };
    for (final c in _cases('art_mascot')) {
      final id = c['id'] as String;
      final o = c['o'] as Map<String, dynamic>;
      test('${c['table']} $id ${c['size']} $o', () {
        final def = tables[c['table']]?[id];
        if (def == null) fail('no ${c['table']} "$id"');
        final r = drawMascot(
          def,
          _d(c['size']) ?? 0,
          _seed(c['seed']),
          MascotDrawOpts(
            tier: _enum(Tier.values, o['tier']),
            idPrefix: o['idPrefix'] as String?,
            border: _d(o['border']),
            shadow: _bool(o['shadow']),
          ),
        );
        _expectSkeleton(r, c['out'] as Map<String, dynamic>);
      });
    }
    final skeletons = _chunks('art_mascot').first['skeletons'] as List;
    for (final c in skeletons.cast<Map<String, dynamic>>()) {
      test('skeleton ${c['id']}', () {
        final def = mascot[c['id']];
        if (def == null) fail('no pose ${c['id']}');
        final r = drawSkeleton(def, _d(c['size']) ?? 0, _seed(c['seed']));
        _expectSkeleton(r, c['out'] as Map<String, dynamic>);
      });
    }
  });

  group('scenes', () {
    for (final c in _cases('art_scenes')) {
      final id = c['id'] as String;
      test('$id ${c['size']}', () {
        final def = scenes[id];
        if (def == null) fail('no scene "$id"');
        final tier = switch (c['size']) {
          120 => Tier.hi,
          _ => null,
        };
        final r = drawSkeleton(
          def,
          _d(c['size']) ?? 0,
          _seed(c['seed']),
          DrawOpts(tier: tier),
        );
        _expectSkeleton(r, c['out'] as Map<String, dynamic>);
      });
    }
  });
}
