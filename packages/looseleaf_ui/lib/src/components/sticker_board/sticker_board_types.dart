import 'package:looseleaf_ink/looseleaf_ink.dart';

/// How a sticker is kept on its board while it moves.
///
/// Mirrors `BoundsMode` in upstream `src/components/ui/sticker-board.tsx`.
enum StickerBoardBounds {
  /// Its centre stays on the board.
  center,

  /// All of it stays on the board.
  inside,

  /// It can go anywhere.
  none,
}

/// Where a sticker moves in its board's stack.
///
/// Mirrors `Reorder` in upstream `src/components/ui/sticker-board.tsx`.
enum StickerReorder {
  /// On top of every other.
  front('brought to the front'),

  /// Under every other.
  back('sent to the back'),

  /// One step up.
  forward('brought forward'),

  /// One step down.
  backward('sent backward');

  const StickerReorder(this.said);

  /// How the move is announced.
  final String said;
}

/// The buttons a `StickerBoardToolbar` can show.
///
/// Mirrors `ToolbarAction` in upstream `src/components/ui/sticker-board.tsx`.
enum StickerBoardAction { turn, size, layer, duplicate, delete, export }

/// Changing one field of a [StickerBoardItem].
extension StickerBoardItemCopy on StickerBoardItem {
  /// This item with the given fields replaced.
  StickerBoardItem copyWith({
    String? id,
    double? x,
    double? y,
    double? rot,
    double? scale,
    double? z,
  }) => StickerBoardItem(
    id: id ?? this.id,
    name: name,
    x: x ?? this.x,
    y: y ?? this.y,
    rot: rot ?? this.rot,
    scale: scale ?? this.scale,
    z: z ?? this.z,
  );

  /// The item as upstream's JSON object.
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'x': x,
    'y': y,
    'rot': rot,
    'scale': scale,
    'z': z,
  };
}
