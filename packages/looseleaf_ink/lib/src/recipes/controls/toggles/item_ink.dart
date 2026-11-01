import 'package:looseleaf_ink/src/recipes/controls/pencil_tiles_ink.dart';

/// How many boil frames an item outline cycles through.
///
/// Mirrors `ITEM_FRAMES` in `src/lib/ink/recipes/item-ink.ts`.
const int itemFrames = 3;

/// The pencil tiles of one item frame, as CSS `url(...)` values: the
/// horizontal and vertical outline edges and the rule under ruled items and
/// pencil separators.
final class ItemTiles {
  /// Tiles.
  const ItemTiles({
    required this.edgeH,
    required this.edgeV,
    required this.rule,
  });

  final String edgeH;
  final String edgeV;
  final String rule;
}

/// The tiles of item [frame] (`0 <= frame < itemFrames`).
///
/// Mirrors the frames built in `itemCss` in
/// `src/lib/ink/recipes/item-ink.ts`.
ItemTiles itemTiles(int frame) => ItemTiles(
  edgeH: edgeTile('item|edge-h|$frame', false),
  edgeV: edgeTile('item|edge-v|$frame', true),
  rule: edgeTile('item|rule|$frame', false),
);
