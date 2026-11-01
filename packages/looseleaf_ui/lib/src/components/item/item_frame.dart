import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';

/// One boil frame of the item's pencil tiles, parsed for painting: the
/// outline edges and the rule.
///
/// Upstream ships these as CSS mask images (`itemCss` in
/// `src/lib/ink/recipes/item-ink.ts`); here the same tile markup is painted
/// directly.
class ItemFrame {
  ItemFrame._(ItemTiles tiles)
    : edgeH = _document(tiles.edgeH),
      edgeV = _document(tiles.edgeV),
      rule = _document(tiles.rule);

  /// The frames, drawn on first use.
  static final List<ItemFrame> all = List.unmodifiable([
    for (var frame = 0; frame < itemFrames; frame++)
      ItemFrame._(itemTiles(frame)),
  ]);

  /// The frame a seed picks, like upstream `hashSeed(seed) % ITEM_FRAMES`.
  static ItemFrame of(String seed) => all[hashSeed(seed) % itemFrames];

  /// An [edgeLen] × [edgeTh] pencil rule.
  final InkDocument edgeH;

  /// An [edgeTh] × [edgeLen] pencil rule.
  final InkDocument edgeV;

  /// An [edgeLen] × [edgeTh] rule repeated under ruled rows and pencil
  /// separators.
  final InkDocument rule;

  static const String _prefix = 'url("data:image/svg+xml,';

  static InkDocument _document(String url) {
    final svg = Uri.decodeComponent(
      url.substring(_prefix.length, url.length - 2),
    );
    final body = svg.substring(svg.indexOf('>') + 1, svg.lastIndexOf('</svg>'));
    return InkDocument.parse(body);
  }
}
