import 'dart:math' as math;

import 'package:looseleaf_ink/src/art/art.dart';
import 'package:looseleaf_ink/src/core/core.dart';

final RegExp _separators = RegExp('[-_]+');
final RegExp _camel = RegExp('([a-z0-9])([A-Z])');

/// [name] as a label: separators to spaces, first letter capitalised.
///
/// Mirrors `stickerLabel` in `src/lib/ink/recipes/sticker-ink.ts`.
String stickerLabel(String name) {
  final words = name.replaceAll(_separators, ' ').trim();
  if (words.isEmpty) return words;
  return words[0].toUpperCase() + words.substring(1);
}

const Map<String, String> _categoryLabels = {
  'statusPointers': 'Status & pointers',
  'spaceWeather': 'Space & weather',
  'foodDrink': 'Food & drink',
  'officeDesk': 'Office & desk',
  'natureAnimals': 'Nature & animals',
  'facesCelebrate': 'Faces & celebrate',
  'badgesStamps': 'Badges & stamps',
};

/// The label of the sticker batch [key].
///
/// Mirrors `categoryLabel` in `src/lib/ink/recipes/sticker-ink.ts`.
String categoryLabel(String key) =>
    _categoryLabels[key] ??
    stickerLabel(
      key.replaceAllMapped(_camel, (m) => '${m[1]}-${m[2]}').toLowerCase(),
    );

/// One sticker in the catalog, with its batch and search tags.
///
/// Mirrors `StickerCatalogEntry` in `src/lib/ink/recipes/sticker-ink.ts`.
final class StickerCatalogEntry {
  /// An entry.
  const StickerCatalogEntry({
    required this.name,
    required this.label,
    required this.category,
    required this.categoryLabel,
    required this.tags,
  });

  /// The sticker's name, a key of [stickers].
  final String name;

  /// The display label.
  final String label;

  /// The batch key.
  final String category;

  /// The batch's display label.
  final String categoryLabel;

  /// Search tags.
  final List<String> tags;
}

/// Every sticker, by batch, with labels and tags (memoised).
///
/// Mirrors `stickerCatalog` in `src/lib/ink/recipes/sticker-ink.ts`.
List<StickerCatalogEntry> stickerCatalog() => memo(
  'sticker-catalog',
  () => [
    for (final MapEntry(key: category, value: defs) in stickerBatches.entries)
      for (final MapEntry(key: name, value: def) in defs.entries)
        StickerCatalogEntry(
          name: name,
          label: stickerLabel(name),
          category: category,
          categoryLabel: categoryLabel(category),
          tags: def.tags ?? const [],
        ),
  ],
  4,
);

/// Whether a sticker called [name] exists.
///
/// Mirrors `hasSticker` in `src/lib/ink/recipes/sticker-ink.ts`.
bool hasSticker(String name) => stickers.containsKey(name);

/// The outline a sticker is cut along: its die-cut silhouette, or a
/// rounded rectangle (stamps).
///
/// Mirrors `CutShape` in `src/lib/ink/recipes/sticker-ink.ts`.
sealed class CutShape {
  const CutShape();
}

/// A die-cut silhouette: fill outlines and stroke paths, the nib width [w]
/// and the white [border].
final class CutPath extends CutShape {
  /// A silhouette cut.
  const CutPath({
    required this.fills,
    required this.lines,
    required this.w,
    required this.border,
  });

  /// Closed fill outlines.
  final List<String> fills;

  /// Open stroke paths.
  final List<String> lines;

  /// The nib width (upstream `W`).
  final double w;

  /// The white border width.
  final double border;
}

/// A rounded rectangle cut.
final class CutRect extends CutShape {
  /// A rectangle cut.
  const CutRect();
}

/// A sticker's box inside its drawing.
typedef FaceBox = ({double x, double y, double w, double h});

/// A drawn sticker: its size, the tight [box] around the cut, the markup
/// and the [cut] outline.
///
/// Mirrors `StickerFace` in `src/lib/ink/recipes/sticker-ink.ts`.
final class StickerFace {
  /// A face.
  const StickerFace({
    required this.name,
    required this.w,
    required this.h,
    required this.box,
    required this.svg,
    required this.cut,
  });

  /// The sticker's name.
  final String name;

  /// Drawing width.
  final double w;

  /// Drawing height.
  final double h;

  /// The tight box around the silhouette and its border.
  final FaceBox box;

  /// The markup.
  final String svg;

  /// The cut outline.
  final CutShape cut;
}

String _peelKey(Peel? peel) => switch (peel) {
  Peel(size: null) => 'true',
  Peel(size: final double s) when s != 0 && !s.isNaN => JsMath.numberToString(
    s,
  ),
  _ => '',
};

Peel? _truthy(Peel? peel) => switch (peel) {
  Peel(size: null) => peel,
  Peel(size: final double s) when s != 0 && !s.isNaN => peel,
  _ => null,
};

/// Draws the sticker [name] at [px] pixels (at least 32), memoised; null
/// when there is no such sticker. [peel] curls a corner, [border] sets the
/// white border and [idPrefix] the silhouette def ids.
///
/// Mirrors `stickerFace` in `src/lib/ink/recipes/sticker-ink.ts`.
StickerFace? stickerFace(
  String name,
  double px,
  String seed, {
  Peel? peel,
  String? idPrefix,
  double? border,
}) {
  final def = stickers[name];
  if (def == null) return null;
  final size = math.max(32.0, JsMath.round(px));
  final borderKey = switch (border) {
    final b? => JsMath.numberToString(b),
    null => '',
  };
  final key =
      'face|$name|${JsMath.numberToString(size)}|$seed|${_peelKey(peel)}|'
      '$borderKey|${idPrefix ?? ''}';
  return memo(key, () {
    final o = DieCutOpts(
      peel: _truthy(peel),
      border: border,
      idPrefix: idPrefix,
    );
    final cut = switch (def) {
      BadgeGen(:final text, :final opts) => dieCut(
        badgeSkeleton(text, opts),
        size,
        seed,
        o,
      ),
      StampGen() => null,
      final ArtDef art => dieCut(art, size, seed, o),
    };
    final res = cut?.result ?? renderSticker(def, size, seed, o);
    return StickerFace(
      name: name,
      w: res.w,
      h: res.h,
      box: _tightBox(res.w, res.h, cut?.silhouette, cut?.border),
      svg: res.svg,
      cut: switch (cut) {
        final c? => CutPath(
          fills: c.silhouette.fills,
          lines: c.silhouette.lines,
          w: c.silhouette.w,
          border: c.border,
        ),
        null => const CutRect(),
      },
    );
  }, 400);
}

FaceBox _tightBox(double w, double h, Silhouette? sil, double? border) {
  if (sil == null || border == null || sil.pts.isEmpty) {
    return (x: 0, y: 0, w: w, h: h);
  }
  var x0 = double.infinity, y0 = double.infinity;
  var x1 = double.negativeInfinity, y1 = double.negativeInfinity;
  for (final (x, y) in sil.pts) {
    if (x < x0) x0 = x;
    if (x > x1) x1 = x;
    if (y < y0) y0 = y;
    if (y > y1) y1 = y;
  }
  final m = border + 1.5;
  x0 = math.max(0, (x0 - m).floorToDouble());
  y0 = math.max(0, (y0 - m).floorToDouble());
  x1 = math.min(w, (x1 + m).ceilToDouble());
  y1 = math.min(h, (y1 + m).ceilToDouble());
  return (x: x0, y: y0, w: x1 - x0, h: y1 - y0);
}

/// The kiss-cut line around [face]: a faint shadow of the shape and a
/// pencil ring with a light catch, masked under ids starting with [id].
///
/// Mirrors `kissCut` in `src/lib/ink/recipes/sticker-ink.ts`.
String kissCut(StickerFace face, String id) {
  final StickerFace(:w, :h, :cut) = face;
  const ring = 1.4;
  String shapeOf(String paint, double extra, [String more = '']) {
    switch (cut) {
      case CutRect():
        final r = math.min(w, h) * 0.08;
        final inset = 3.5 - extra / 2;
        return '<rect x="${n(inset)}" y="${n(inset)}" width="${n(w - 2 * inset)}" '
            'height="${n(h - 2 * inset)}" rx="${n(r)}" fill="$paint" $more/>';
      case CutPath(:final fills, :final lines, w: final nib, :final border):
        final sw = 2 * border + extra;
        final g =
            'fill="$paint" stroke="$paint" stroke-width="${n(sw)}" '
            'stroke-linejoin="round" stroke-linecap="round"';
        final open =
            'fill="none" stroke="$paint" stroke-width="${n(sw + nib)}" '
            'stroke-linejoin="round" stroke-linecap="round"';
        final fillPaths = fills.map((d) => '<path d="$d"/>').join();
        final linePaths = lines.map((d) => '<path d="$d"/>').join();
        return '<g $g $more>$fillPaths</g><g $open $more>$linePaths</g>';
    }
  }

  final mask =
      '<mask id="${id}m" maskUnits="userSpaceOnUse" x="-12" y="-12" '
      'width="${n(w + 24)}" height="${n(h + 24)}">'
      '${shapeOf('white', ring)}${shapeOf('black', 0)}</mask>';
  final catchLine =
      '<g transform="translate(.9 1)" opacity=".8"><rect x="-12" y="-12" '
      'width="${n(w + 24)}" height="${n(h + 24)}" fill="var(--ll-photo)" '
      'mask="url(#${id}m)"/></g>';
  final cutLine =
      '<rect x="-12" y="-12" width="${n(w + 24)}" height="${n(h + 24)}" '
      'fill="var(--ll-pencil)" opacity=".62" mask="url(#${id}m)"/>';
  return '<defs>$mask</defs><g opacity=".07">'
      '${shapeOf('var(--ll-ink)', 0)}</g>$catchLine$cutLine';
}
