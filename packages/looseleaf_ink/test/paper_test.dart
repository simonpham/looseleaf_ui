import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:test/test.dart';

final Map<String, dynamic> _fx =
    jsonDecode(
          File('test/fixtures/paper.json').readAsStringSync(),
        )
        as Map<String, dynamic>;

List<Map<String, dynamic>> _list(String key) =>
    (_fx[key] as List).cast<Map<String, dynamic>>();

double _d(Object? v) => (v as num).toDouble();

StockName _stock(Object? v) => StockName.byId(v as String) ?? StockName.paper;

RuleName _rule(Object? v) => RuleName.values.firstWhere((r) => r.id == v);

EdgeSpec _edge(Object? v) => switch (v) {
  final String kind => EdgeSpec.all(EdgeKind.values.byName(kind)),
  final Map<String, dynamic> m => EdgeSpec(
    top: EdgeKind.values.byName(m['top'] as String? ?? 'cut'),
    right: EdgeKind.values.byName(m['right'] as String? ?? 'cut'),
    bottom: EdgeKind.values.byName(m['bottom'] as String? ?? 'cut'),
    left: EdgeKind.values.byName(m['left'] as String? ?? 'cut'),
  ),
  _ => const EdgeSpec(),
};

Object _seed(Object? v) => switch (v) {
  final num n => n.toDouble(),
  _ => v as String,
};

List<List<double>> _pts(List<Pt> pts) => [
  for (final (x, y) in pts) [x, y],
];

Object? _piece(FacePiece p) => switch (p) {
  FaceMarkup(:final markup) => markup,
  final FaceSpec spec => jsonDecode(spec.toJsonString()),
};

void main() {
  group('stocks', () {
    for (final c in _list('stocks')) {
      test(c['name'], () {
        final s = stockOf(_stock(c['name']));
        expect(s.name.id, c['name']);
        expect(s.label, c['label']);
        expect(s.color, c['color']);
        expect(s.base, c['base']);
        expect(switch (s.tint) {
          (final t, final share) => [t, share],
          null => null,
        }, c['tint']);
        expect(s.stockClass, c['stockClass']);
        expect(s.tooth.name, c['tooth']);
        expect(s.toothClass, c['toothClass']);
        expect(s.shadow.name, c['shadow']);
        expect(s.shadowClass, c['shadowClass']);
        expect(edgeSides(s.edge).map((k) => k.name), c['edge']);
        expect(s.rules.id, c['rules']);
        expect(s.tilt, c['tilt']);
        expect(s.gum, c['gum']);
        expect([
          for (final lift in [1.0, 1.5, 0.6]) stockShadow(s.name, lift),
        ], c['shadows']);
      });
    }
    test('names', () {
      expect(
        stockNames.map((s) => s.id),
        _list('stocks').map((c) => c['name']),
      );
    });
  });

  test('rules', () {
    for (final c in _list('rules')) {
      final o = c['o'] as Map<String, dynamic>;
      final kind = _rule(c['kind']);
      final calm = o['calm'] == true;
      final first = switch (o['first']) {
        final num f => f.toDouble(),
        _ => null,
      };
      final g = ruleGeometry(kind, calm: calm, first: first);
      final geo = c['geo'] as Map<String, dynamic>;
      final where = '${c['kind']} $o';
      expect(g.kind.id, geo['kind'], reason: where);
      expect(
        [g.pitch, g.first, g.offset, g.margin, g.major],
        [
          geo['pitch'],
          geo['first'],
          geo['offset'],
          geo['margin'],
          geo['major'],
        ],
        reason: where,
      );
      expect(
        switch (g.cols) {
          (final a, final b) => [a, b],
          null => null,
        },
        geo['cols'],
        reason: where,
      );
      final layer = rulesLayer(kind, calm: calm, first: first);
      expect(
        switch (layer) {
          final l? => {'pitch': l.pitch, 'style': l.style},
          null => null,
        },
        c['layer'],
        reason: where,
      );
    }
    for (final c in _list('offsets')) {
      expect(ruleOffsetFor(_d(c['p']), _d(c['fs'])), c['out']);
    }
  });

  test('shadows', () {
    for (final c in _list('shadows')) {
      final kind = SheetShadowKind.values.byName(c['kind'] as String);
      expect([
        for (final lift in [1.0, 0.5, 1.4, 2.2, 0.0]) sheetShadow(kind, lift),
      ], c['sheet']);
      expect(switch (contactShadow(kind)) {
        final s? => {'dy': s.dy, 'a': s.a},
        null => null,
      }, c['contact']);
      expect(farShadow(kind), c['far']);
      expect(farShadow(kind, true), c['farAll']);
    }
    for (final c in _list('drops')) {
      final kind = DropKind.values.byName(c['kind'] as String);
      expect([
        for (final lift in [1.0, 0.5, 1.7]) dropShadow(kind, lift),
      ], c['out']);
    }
    for (final c in _list('tilts')) {
      expect(tiltFor(_seed(c['seed']), _d(c['max'])), c['out'], reason: '$c');
    }
    for (final c in _list('limits')) {
      expect(
        tiltLimit(_d(c['w']), _d(c['h']), _d(c['shift']), _d(c['cap'])),
        c['out'],
        reason: '$c',
      );
    }
    for (final c in _list('tex')) {
      final sizes = [
        for (final s in c['sizes'] as List) (_d(s[0]), _d(s[1])),
      ];
      expect(tileOffsets(_seed(c['seed']), sizes), c['out']);
    }
    expect(tiltVars(1.25), _fx['tiltVars']);
    for (final c in _list('asin')) {
      expect(jsAsin(_d(c['x'])), c['out'], reason: '${c['x']}');
    }
  });

  test('edge specs', () {
    for (final c in _list('edgeInfo')) {
      final e = _edge(c['edge']);
      expect(edgeSides(e).map((k) => k.name), c['sides']);
      expect(isCutEdge(e), c['cut']);
      expect(edgeName(e).name, c['name']);
      expect(edgeInset(e), c['inset']);
    }
  });

  group('outlines', () {
    for (final c in _list('outlines')) {
      test('${c['seed']} ${c['edge']} ${c['o']}', () {
        final o = c['o'] as Map<String, dynamic>;
        final w = _d(c['w']), h = _d(c['h']);
        final chamfer = switch (o['chamfer']) {
          final num v => v.toDouble(),
          _ => null,
        };
        final out = sheetOutline(
          Rng(c['seed'] as String),
          w,
          h,
          _edge(c['edge']),
          amp: switch (o['amp']) {
            final num v => v.toDouble(),
            _ => null,
          },
          chamfer: chamfer,
        );
        expect(_pts(out.pts), c['pts']);
        expect(_pts(out.rim), c['rim']);
        expect(out.crisp, c['crisp']);
        expect(out.reach, c['reach']);
        expect(out.fibrous, c['fibrous']);
        expect([
          for (final s in out.sides)
            {'kind': s.kind.name, 'from': s.from, 'to': s.to},
        ], c['sides']);
        expect(outlinePath(out, OutlineRing.body), c['bodyLo']);
        expect(outlinePath(out, OutlineRing.body, Tier.hi), c['bodyHi']);
        expect(outlinePath(out, OutlineRing.rim), c['rimLo']);
        expect(sideInsets(out, w, h, chamfer ?? 0), c['insets']);
      });
    }
  });

  group('faces', () {
    final specs = [
      for (final m in _list('marks'))
        FaceSpec.fromJson(m['spec'] as Map<String, dynamic>),
    ];
    test('marks', () {
      for (final (i, m) in _list('marks').indexed) {
        expect(faceMark(specs[i]), m['mark']);
      }
      final shadows = _fx['shadowMarks'] as List;
      expect(shadowMark(SheetShadowKind.lift, [11, 11, 11, 11]), shadows[0]);
      expect(
        shadowMark(SheetShadowKind.lift, [3, 9, 9, 3], [0.5, 1, 1, 0]),
        shadows[1],
      );
    });
    test('split', () {
      final split = _fx['split'] as Map<String, dynamic>;
      final markup = split['markup'] as String;
      expect(hasFace(markup), split['has']);
      expect(hasFace('<g/>'), split['plainHas']);
      expect(splitFaces(markup).map(_piece).toList(), split['pieces']);
    });
    test('looks', () {
      for (final c in _list('looks')) {
        final look = faceLook(
          _stock(c['stock']),
          c['seed'] as String,
          c['veil'] as bool,
        );
        expect({
          'className': look.className,
          'vars': look.vars,
        }, c['out']);
      }
    });
    test('tiles', () {
      for (final c in _list('tiles')) {
        final names = [for (final s in c['stocks'] as List) _stock(s)];
        expect(tilesOf(names).map((t) => t.name), c['out']);
      }
    });
    test('paths', () {
      for (final c in _list('paths')) {
        final d = c['d'] as String;
        expect(
          [
            translatePath(d, 0, 0),
            translatePath(d, 3, -2.5),
            translatePath(d, 0.333, 1.666),
          ],
          c['moved'],
          reason: d,
        );
        expect(pathBox(d), c['box'], reason: d);
      }
    });
    test('clips and svg', () {
      final clips = _fx['clips'] as List;
      final svgs = _fx['svgs'] as List;
      for (final (i, spec) in specs.indexed) {
        expect([
          faceClip(spec),
          faceClip(spec, 4, 4),
          faceClip(spec, 0, 2.5),
        ], clips[i]);
        expect(faceSvg(spec), svgs[i * 3]);
        expect(faceSvg(spec, tiles: true), svgs[i * 3 + 1]);
        expect(faceSvg(spec, tiles: true, id: 'x-'), svgs[i * 3 + 2]);
      }
      final markup = (_fx['split'] as Map<String, dynamic>)['markup'] as String;
      final rendered = _fx['rendered'] as List;
      expect(renderFaces(markup), rendered[0]);
      expect(renderFaces(markup, tiles: true, id: 'r'), rendered[1]);
      expect(renderFaces('<g/>'), rendered[2]);
    });
    test('sheet pieces', () {
      final markup = (_fx['split'] as Map<String, dynamic>)['markup'] as String;
      final out = sheetPieces(
        [LayerName.rest, LayerName.hover],
        {LayerName.rest: markup, LayerName.hover: '<g h="1"/>'},
      );
      expect(out.pieces.map((p) => p.runtimeType.toString()), [
        'SheetSvg',
        'SheetFace',
        'SheetSvg',
        'SheetFace',
        'SheetSvg',
      ]);
      expect(out.casts.length, 2);
      final last = out.pieces.last;
      expect(
        switch (last) {
          SheetSvg(:final groups) => groups,
          SheetFace() => null,
        },
        [(LayerName.rest, '<g/>'), (LayerName.hover, '<g h="1"/>')],
      );
    });
  });
}
