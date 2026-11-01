import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:test/test.dart';

typedef _Json = Map<String, dynamic>;

_Json _load(String name) =>
    jsonDecode(File('test/fixtures/$name').readAsStringSync()) as _Json;

double _d(Object? v) => (v as num).toDouble();

double? _od(Object? v) => switch (v) {
  final num x => x.toDouble(),
  _ => null,
};

Tier? _tier(Object? v) => switch (v) {
  final String t => Tier.values.byName(t),
  _ => null,
};

PaintKey? _paint(Object? v) => switch (v) {
  final String id => PaintKey.byId(id),
  _ => null,
};

Accent? _accent(Object? v) => switch (v) {
  final String a when Accent.values.any((x) => x.name == a) =>
    Accent.values.byName(a),
  _ => null,
};

StockName _stock(Object? v) => StockName.byId(v as String?) ?? StockName.paper;

EdgeKind _kind(Object? v) => switch (v) {
  final String k => EdgeKind.values.byName(k),
  _ => EdgeKind.cut,
};

EdgeSpec _edge(Object? v) => switch (v) {
  final String kind => EdgeSpec.all(EdgeKind.values.byName(kind)),
  final Map<String, dynamic> m => EdgeSpec(
    top: _kind(m['top']),
    right: _kind(m['right']),
    bottom: _kind(m['bottom']),
    left: _kind(m['left']),
  ),
  _ => const EdgeSpec(),
};

List<double>? _doubles(Object? v) => switch (v) {
  final List<dynamic> l => [for (final x in l) _d(x)],
  _ => null,
};

List<List<double>> _pts(List<Pt> pts) => [
  for (final (x, y) in pts) [x, y],
];

Map<String, Object?> _res(InkResult r, {bool parts = false}) => {
  'svg': r.svg,
  'w': r.w,
  'h': r.h,
  'pad': r.pad,
  'layers': [for (final l in r.layers) l.name],
  if (parts) 'parts': {for (final e in r.parts.entries) e.key.name: e.value},
};

SheetParams _sheet(_Json p) => SheetParams(
  stock: _stock(p['stock']),
  edge: _edge(p['edge']),
  chamfer: _od(p['chamfer']),
  shadow: switch (p['shadow']) {
    final String s when s != 'none' => SheetShadowKind.values.byName(s),
    _ => null,
  },
  noShadow: p['shadow'] == 'none',
);

SealParams _seal(_Json p) => SealParams(
  variant: SealVariant.values.byName(p['variant'] as String),
  text: p['text'] as String?,
  sub: p['sub'] as String?,
  mark: switch (p['mark']) {
    final String m => SealMark.values.byName(m),
    _ => null,
  },
  tone: _paint(p['tone']),
  ribbon: _paint(p['ribbon']),
  ring: p['ring'] as String?,
  deco: switch (p['deco']) {
    final String d => BadgeDeco.values.byName(d),
    _ => null,
  },
  textColor: _paint(p['textColor']),
);

Object? _call(String fn, List<dynamic> a) {
  _Json o(int i) => a[i] as _Json? ?? const {};
  return switch (fn) {
    'paperSheet' => _res(
      paperSheet(
        a[0] as String,
        _d(a[1]),
        _d(a[2]),
        _sheet(a[3] as _Json),
        tier: _tier(o(4)['tier']),
        calm: o(4)['calm'] as bool?,
        tiles: (o(4)['faces'] as _Json?)?['tiles'] == true,
        faceId: (o(4)['faces'] as _Json?)?['id'] as String?,
      ),
      parts: true,
    ),
    'sheetPad' => sheetPad(_edge(a[0])),
    'ellipseD' => ellipseD(_d(a[0]), _d(a[1]), _d(a[2]), _d(a[3])),
    'circleD' => circleD(_d(a[0]), _d(a[1]), _d(a[2])),
    'polyD' => polyD([
      for (final p in a[0] as List<dynamic>) (_d(p[0]), _d(p[1])),
    ], a[1] as bool),
    'mirrorX' => mirrorX(_d(a[0]), a[1] as String),
    'MIRROR' => mirrorTransform(_d(a[0])),
    'litEdge' => switch (_od(a[1])) {
      final double op => litEdge(a[0] as String, op),
      null => litEdge(a[0] as String),
    },
    'holePunch' => holePunch(
      a[0] as String,
      _d(a[1]),
      _d(a[2]),
      _d(a[3]),
      _d(a[4]),
    ),
    'reinforcement' => reinforcement(_d(a[0]), _d(a[1]), _d(a[2])),
    'paperFill' => paperFill(
      a[0] as int,
      a[1] as String,
      stock: _stock(o(2)['stock']),
      id: o(2)['id'] as String?,
      edge: _od(o(2)['edge']),
      evenodd: o(2)['evenodd'] == true,
      shadow: o(2)['shadow'] != null && o(2)['shadow'] != false,
      shadowKind: switch (o(2)['shadow']) {
        final String s => SheetShadowKind.values.byName(s),
        _ => null,
      },
      far: o(2)['far'] != false,
      inset: _doubles(o(2)['inset']),
    ),
    'stackSvg' => switch (a[5]) {
      [final String f0, final String f1] => stackSvg(
        _d(a[0]),
        _d(a[1]),
        a[2] as int,
        Rng(a[3] as String),
        a[4] as String,
        (f0, f1),
      ),
      _ => stackSvg(
        _d(a[0]),
        _d(a[1]),
        a[2] as int,
        Rng(a[3] as String),
        a[4] as String,
      ),
    },
    'pageHoles' => _pts(
      pageHoles(_d(a[0]), _d(a[1]), PageHoles.values.byName(a[2] as String)),
    ),
    'notebookHoles' => notebookHoles(
      _d(a[0]),
      NotebookBinding.values.byName(a[1] as String),
    ),
    'perfRectD' => perfRectD(
      _d(a[0]),
      _d(a[1]),
      _d(a[2]),
      _d(a[3]),
      _d(a[4]),
      _d(a[5]),
    ),
    'stampBox' => switch (stampBox(_d(a[0]))) {
      (:final sw, :final sh, :final x, :final y) => {
        'sw': sw,
        'sh': sh,
        'x': x,
        'y': y,
      },
    },
    'tabPoints' => _pts(
      tabPoints(_d(a[0]), _d(a[1]), _d(a[2]), Rng(a[3] as String), _d(a[4])),
    ),
    'ribbonPoly' => _pts(ribbonPoly(_d(a[0]), _d(a[1]))),
    'tagHole' => _pts([
      tagHole(_d(a[0]), _d(a[1]), TagShape.values.byName(a[2] as String)),
    ]).first,
    'tagPath' => tagPath(
      _d(a[0]),
      _d(a[1]),
      TagShape.values.byName(a[2] as String),
      Rng(a[3] as String),
      a[4] as bool,
    ),
    'ticketPath' => switch (ticketPath(_d(a[0]), _d(a[1]), _d(a[2]), [
      for (final p in a[3] as List<dynamic>) (_d(p[0]), _d(p[1])),
    ])) {
      (:final d, :final holesD) => {'d': d, 'holesD': holesD},
    },
    'clipboardClip' => _res(
      clipboardClip(
        a[0] as String,
        width: _od(o(1)['width']),
        tier: _tier(o(1)['tier']),
        calm: o(1)['calm'] as bool?,
      ),
    ),
    'pencil' => _res(
      pencilProp(
        a[0] as String,
        length: _od(o(1)['length']),
        color: _accent(o(1)['color']),
        tier: _tier(o(1)['tier']),
        calm: o(1)['calm'] as bool?,
      ),
    ),
    'typedSignature' => switch (typedSignature(
      a[0] as String,
      _d(a[1]),
      _d(a[2]),
      a[3] as String,
      _paint(a[4]) ?? PaintKey.inkYou,
    )) {
      (:final svg, :final size) => {'svg': svg, 'size': size},
    },
    'sealArt' => _res(
      sealArt(
        _seal(a[0] as _Json),
        _d(a[1]),
        a[2] as String,
        Tier.values.byName(a[3] as String),
      ),
    ),
    _ => throw ArgumentError('unknown $fn'),
  };
}

void _calls(String fixture) {
  for (final (i, c)
      in (_load(fixture)['calls'] as List).cast<_Json>().indexed) {
    test('${c['fn']} #$i', () {
      expect(_call(c['fn'] as String, c['args'] as List<dynamic>), c['out']);
    });
  }
}

void main() {
  group('helpers', () => _calls('paper_recipes_helpers.json'));
  group('seals', () => _calls('paper_seals.json'));
  group('faces', () {
    final faces = (_load('paper_recipes_helpers.json')['faces'] as List)
        .cast<_Json>();
    for (final c in faces) {
      test(c['name'], () {
        final parts = {
          for (final MapEntry(:key, :value) in (c['parts'] as _Json).entries)
            LayerName.values.byName(key): value as String,
        };
        final split = c['split'] as _Json;
        final specs = <FaceSpec>[];
        final layers = [
          for (final l in c['layers'] as List)
            LayerName.values.byName(l as String),
        ];
        for (final key in layers) {
          final pieces = splitFaces(parts[key] ?? '');
          final want = (split[key.name] as List).cast<_Json>();
          expect(pieces, hasLength(want.length), reason: key.name);
          for (final (i, piece) in pieces.indexed) {
            switch (piece) {
              case FaceMarkup(:final markup):
                expect(markup, want[i]['markup']);
              case final FaceSpec spec:
                expect(spec.toJsonString(), want[i]['face']);
                specs.add(spec);
            }
          }
        }
        expect(specs, isNotEmpty);
        final (:pieces, :casts) = sheetPieces(layers, parts);
        final papers = [
          for (final p in pieces)
            if (p case SheetFace(:final spec)) spec,
        ];
        expect(
          papers.map((s) => s.toJsonString()),
          specs.where((s) => s.paper).map((s) => s.toJsonString()),
        );
        expect(
          casts.map((s) => s.toJsonString()),
          specs.where((s) => s.cast != null).map((s) => s.toJsonString()),
        );
        expect(pieces.last, isA<SheetSvg>());
        final markup = [
          for (final p in pieces)
            if (p case SheetSvg(:final groups))
              for (final (_, m) in groups) m,
        ].join();
        expect(markup, isNot(contains('<!--ll-face:')));
      });
    }
  });
}
