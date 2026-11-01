import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';

/// The table's mask tiles from `tableTiles`, parsed for painting: the
/// pencil row rule, the double header rule and the band's rounded caps.
///
/// Upstream ships them as CSS mask images (`src/components/ui/table.tsx`);
/// here the same markup is painted and the color laid through it.
class TableTileDocuments {
  TableTileDocuments._(TableTiles tiles)
    : rule = _parse(tiles.rule),
      head = _parse(tiles.head),
      capStart = _parse(tiles.capStart),
      capEnd = _parse(tiles.capEnd);

  /// The tiles, parsed on first use.
  static final TableTileDocuments instance = TableTileDocuments._(
    tableTiles(),
  );

  /// A [tableTileW] × [tableRuleH] row rule.
  final InkDocument rule;

  /// A [tableTileW] × [tableHeadH] header rule.
  final InkDocument head;

  /// The [tableCapW] × 40 rounded start of the band.
  final InkDocument capStart;

  /// The [tableCapW] × 40 rounded end of the band.
  final InkDocument capEnd;

  static const String _prefix = 'url("data:image/svg+xml,';

  static InkDocument _parse(String url) {
    final svg = Uri.decodeFull(url.substring(_prefix.length, url.length - 2));
    return InkDocument.parse(
      svg.substring(svg.indexOf('>') + 1, svg.lastIndexOf('</svg>')),
    );
  }
}
