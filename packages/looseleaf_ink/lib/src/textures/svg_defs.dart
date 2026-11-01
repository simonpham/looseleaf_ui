import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/textures/paper_tiles.dart';

/// The paper tiles a page defines for faces (`PAPER_DEF_TILES`).
///
/// Mirrors `PAPER_DEF_TILES` in `src/lib/ink/paper/defs.tsx`.
const List<PaperTileName> paperDefTiles = [
  PaperTileName.fibre,
  PaperTileName.relief,
  PaperTileName.slip,
  PaperTileName.kraft,
  PaperTileName.cloud,
];

/// The translations of the extra paper patterns (`PATTERN_OFFSETS`).
const List<(int, int)> patternOffsets = [
  (0, 0),
  (67, 113),
  (131, 29),
  (23, 171),
];

/// The area grain masks cover: a user-space box, or each element's own
/// bounding box ([MaskRegion.bbox]).
///
/// Mirrors `MaskDefsOptions['region']` in `src/lib/ink/textures.ts`.
final class MaskRegion {
  /// A user-space box.
  const MaskRegion(this.x, this.y, this.width, this.height) : bbox = false;

  /// The element's bounding box.
  const MaskRegion.bbox()
    : x = -4000,
      y = -4000,
      width = 9000,
      height = 9000,
      bbox = true;

  /// Left.
  final double x;

  /// Top.
  final double y;

  /// Width.
  final double width;

  /// Height.
  final double height;

  /// Whether masks use the element's bounding box.
  final bool bbox;
}

String _num(double v) => JsMath.numberToString(JsMath.round(v * 100) / 100);

String _js(num v) => JsMath.numberToString(v);

/// `<image>`, `<pattern>` and `<mask>` defs for the grain [kinds], ids
/// prefixed by [prefix]. Tile images come from [uri].
///
/// Mirrors `svgMaskDefs` in `src/lib/ink/textures.ts`.
String svgMaskDefs(
  TileUri uri, {
  List<GrainKind> kinds = GrainKind.values,
  String? prefix,
  MaskRegion region = const MaskRegion(-2048, -2048, 8192, 8192),
}) {
  final p = prefix ?? 'll';
  final maskAttrs = switch (region.bbox) {
    true => 'x="-0.1" y="-0.1" width="1.2" height="1.2"',
    false =>
      'maskUnits="userSpaceOnUse" x="${_js(region.x)}" y="${_js(region.y)}" width="${_js(region.width)}" height="${_js(region.height)}"',
  };
  final s = StringBuffer();
  for (final kind in kinds) {
    final css = grainTileCss[kind.name] ?? 0;
    s.write(
      '<image id="$p-${kind.name}-img" width="${_js(css)}" height="${_js(css)}" href="${uri(kind.name)}"/>',
    );
    for (var v = 0; v < maskVariants; v++) {
      final ph = maskPhase(v);
      final rot = switch (ph.rot) {
        0 => '',
        final deg => ' rotate($deg)',
      };
      s.write(
        '<pattern id="$p-${kind.name}-pat-$v" width="${_js(css)}" height="${_js(css)}" patternUnits="userSpaceOnUse"'
        ' patternTransform="translate(${_num(ph.x * css)} ${_num(ph.y * css)})$rot"><use href="#$p-${kind.name}-img"/></pattern>',
      );
    }
    String rect(int v) =>
        '<rect x="${_js(region.x)}" y="${_js(region.y)}" width="${_js(region.width)}" height="${_js(region.height)}" fill="url(#$p-${kind.name}-pat-$v)"/>';
    s.write('<mask id="$p-${kind.name}" $maskAttrs>${rect(0)}</mask>');
    for (var v = 0; v < maskVariants; v++) {
      s.write('<mask id="$p-${kind.name}-$v" $maskAttrs>${rect(v)}</mask>');
    }
  }
  return '$s';
}

/// `<image>` and `<pattern>` defs for paper [tiles] (four offsets each),
/// ids prefixed by [prefix]. Tile images come from [uri].
///
/// Mirrors `svgPatternDefs` in `src/lib/ink/textures.ts`.
String svgPatternDefs(
  TileUri uri, {
  List<PaperTileName> tiles = PaperTileName.values,
  String? prefix,
}) {
  final p = prefix ?? 'll';
  final s = StringBuffer();
  for (final t in tiles) {
    final w = _js(t.cssWidth), h = _js(t.cssHeight);
    s.write(
      '<image id="$p-tex-${t.name}-img" width="$w" height="$h" href="${uri(t.name)}"/>',
    );
    for (final (i, (x, y)) in patternOffsets.indexed) {
      final id = switch (i) {
        0 => '$p-tex-${t.name}',
        _ => '$p-tex-${t.name}-$i',
      };
      final tf = switch (i) {
        0 => '',
        _ => ' patternTransform="translate($x $y)"',
      };
      s.write(
        '<pattern id="$id" width="$w" height="$h" patternUnits="userSpaceOnUse"$tf><use href="#$p-tex-${t.name}-img"/></pattern>',
      );
    }
  }
  return '$s';
}

/// A hidden `<svg>` holding the grain masks and, with [paper], the paper
/// patterns.
///
/// Mirrors `inkDefsSvg` in `src/lib/ink/textures.ts`.
String inkDefsSvg(
  TileUri uri, {
  List<GrainKind> kinds = GrainKind.values,
  String? prefix,
  MaskRegion region = const MaskRegion(-2048, -2048, 8192, 8192),
  bool paper = false,
}) {
  final masks = svgMaskDefs(uri, kinds: kinds, prefix: prefix, region: region);
  final patterns = switch (paper) {
    true => svgPatternDefs(uri, prefix: prefix),
    false => '',
  };
  return '<svg xmlns="http://www.w3.org/2000/svg" width="0" height="0" style="position:absolute" aria-hidden="true" focusable="false"><defs>$masks$patterns</defs></svg>';
}
