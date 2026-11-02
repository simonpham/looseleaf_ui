import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:test/test.dart';

final Map<String, dynamic> _fx =
    jsonDecode(
          File('test/fixtures/paper_textures.json').readAsStringSync(),
        )
        as Map<String, dynamic>;

String _uri(String name) => '{tile:$name}';

Object? _seed(Object? v) => switch (v) {
  final num n => n.toDouble(),
  _ => v,
};

Map<String, String> _style(TextureStyle s) => {
  'backgroundColor': s.backgroundColor,
  'backgroundImage': s.backgroundImage,
  'backgroundSize': s.backgroundSize,
  'backgroundPosition': s.backgroundPosition,
  'backgroundRepeat': s.backgroundRepeat,
};

List<PaperTileName> _tiles(List<dynamic> v) => [
  for (final t in v) PaperTileName.values.byName(t as String),
];

void main() {
  test('def tiles', () {
    expect(paperDefTiles, _tiles(_fx['defTiles'] as List));
  });

  test('paper backgrounds', () {
    for (final c in (_fx['paper'] as List).cast<Map<String, dynamic>>()) {
      final o = c['o'] as Map<String, dynamic>;
      final layers = {
        for (final MapEntry(:key, :value)
            in (o['layers'] as Map<String, dynamic>? ?? {}).entries)
          PaperTileName.values.byName(key): value as bool,
      };
      final tooth = switch (o['tooth']) {
        final String t => Tooth.values.byName(t),
        _ => null,
      };
      final stock = c['stock'] as String? ?? 'paper';
      final style = paperBackground(
        _uri,
        stock: stock,
        tooth: tooth,
        seed: _seed(o['seed']),
        layers: layers,
      );
      expect(_style(style), c['out'], reason: '$c');
      expect(style.toCss(), c['css']);
    }
  });

  test('desk backgrounds', () {
    for (final c in (_fx['desk'] as List).cast<Map<String, dynamic>>()) {
      final o = c['o'] as Map<String, dynamic>;
      final vignette = (o['vignette'] as num?)?.toDouble() ?? 0.05;
      final style = deskBackground(
        _uri,
        vignette: vignette,
        seed: _seed(o['seed']),
      );
      expect(_style(style), c['out']);
      expect(
        deskCss(_uri, vignette: vignette, seed: _seed(o['seed'])),
        c['css'],
      );
    }
  });

  test('css vars and defs', () {
    final vars = _fx['vars'] as List;
    expect(textureCssVars(_uri), vars[0]);
    expect(
      textureCssVars(_uri, [PaperTileName.cloud, PaperTileName.linen]),
      vars[1],
    );
    final patterns = _fx['patterns'] as List;
    expect(svgPatternDefs(_uri), patterns[0]);
    expect(
      svgPatternDefs(_uri, tiles: paperDefTiles, prefix: 'pp'),
      patterns[1],
    );
    final masks = _fx['masks'] as List;
    expect(svgMaskDefs(_uri), masks[0]);
    expect(
      svgMaskDefs(
        _uri,
        kinds: [GrainKind.felt, GrainKind.stamp],
        prefix: 'q',
        region: const MaskRegion.bbox(),
      ),
      masks[1],
    );
    expect(
      svgMaskDefs(
        _uri,
        kinds: [GrainKind.marker],
        region: const MaskRegion(-10, -20, 300.5, 400),
      ),
      masks[2],
    );
    final defs = _fx['defs'] as List;
    expect(inkDefsSvg(_uri), defs[0]);
    expect(
      inkDefsSvg(_uri, paper: true, prefix: 'z', kinds: [GrainKind.waxy]),
      defs[1],
    );
  });
}
