import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/paper/face_path.dart';
import 'package:looseleaf_ink/src/paper/face_spec.dart';
import 'package:looseleaf_ink/src/paper/shadows.dart';
import 'package:looseleaf_ink/src/paper/stocks.dart';

String _num(double v) => JsMath.numberToString(JsMath.round(v * 100) / 100);

String _tok(String name) => 'var(--ll-$name)';

/// A face drawn as plain SVG: the stock colour, optional tooth tiles
/// ([tiles], referencing `#ll-tex-<tile>-img`) and the sheen, clipped to
/// the face; ids start with [id] (default `ll-fc`).
///
/// Mirrors `faceSvg` in `src/lib/ink/paper/faces.ts`.
String faceSvg(FaceSpec spec, {bool tiles = false, String? id}) {
  if (!spec.paper) return '';
  final s = stockOf(spec.stock);
  final gid = '${id ?? 'll-fc'}${spec.seed.toRadixString(36)}';
  final [x0, y0, x1, y1] = pathBox(spec.d);
  final r =
      'x="${_num(x0 - 2)}" y="${_num(y0 - 2)}" width="${_num(x1 - x0 + 4)}" height="${_num(y1 - y0 + 4)}"';
  final defs = StringBuffer();
  final inner = StringBuffer('<rect $r fill="${_tok(s.base)}"/>');
  if (s.tint case (final token, final share)) {
    inner.write(
      '<rect $r fill="${_tok(token)}" fill-opacity="${JsMath.numberToString(share)}"/>',
    );
  }
  if (tiles) {
    final names = toothTiles[s.tooth] ?? const [];
    final offs = tileOffsetList(spec.seed, toothTileSizes(s.tooth));
    for (final (i, tile) in names.indexed) {
      final (ox, oy) = offs[i];
      defs.write(
        '<pattern id="${gid}t$i" width="${JsMath.numberToString(tile.cssWidth)}" '
        'height="${JsMath.numberToString(tile.cssHeight)}" patternUnits="userSpaceOnUse" '
        'patternTransform="translate(${_num(ox.toDouble())} ${_num(oy.toDouble())})">'
        '<use href="#ll-tex-${tile.name}-img"/></pattern>',
      );
      inner.write('<rect $r fill="url(#${gid}t$i)"/>');
    }
  }
  defs.write(
    '<linearGradient id="${gid}l" x1="0" y1="0" x2="1" y2="1">'
    '<stop offset="0" stop-color="${_tok('photo')}" stop-opacity=".38"/>'
    '<stop offset=".42" stop-color="${_tok('photo')}" stop-opacity="0"/>'
    '<stop offset="1" stop-color="${_tok('ink')}" stop-opacity=".035"/>'
    '</linearGradient>',
  );
  inner.write('<rect $r fill="url(#${gid}l)"/>');
  if (s.gum && spec.veil) {
    inner.write(
      '<rect $r fill="${_tok(s.base)}" fill-opacity="${JsMath.numberToString(stickyVeil)}"/>',
    );
  }
  final rule = switch (spec.evenodd) {
    true => ' clip-rule="evenodd"',
    false => '',
  };
  return '<defs>$defs<clipPath id="${gid}c"><path d="${spec.d}"$rule/></clipPath></defs>'
      '<g clip-path="url(#${gid}c)">$inner</g>';
}

/// [markup] with every face mark replaced by its [faceSvg].
///
/// Mirrors `renderFaces` in `src/lib/ink/paper/faces.ts`.
String renderFaces(String markup, {bool tiles = false, String? id}) {
  if (!hasFace(markup)) return markup;
  return splitFaces(markup)
      .map(
        (p) => switch (p) {
          FaceMarkup(:final markup) => markup,
          final FaceSpec spec => faceSvg(spec, tiles: tiles, id: id),
        },
      )
      .join();
}
