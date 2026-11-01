import 'dart:ui';

/// A sticker peeled off, or stuck back on, a sticker sheet: which one, how
/// (by a [dragged] pull or a tap) and where the pointer let go.
///
/// Mirrors `StickerSheetPeel` in upstream
/// `src/components/ui/sticker-sheet.tsx`.
class StickerSheetPeel {
  const StickerSheetPeel({
    required this.id,
    required this.name,
    required this.label,
    required this.dragged,
    this.position,
  });

  /// The item's id (its name unless given).
  final String id;

  /// The sticker's name in the catalog.
  final String name;

  /// The sticker's display label.
  final String label;

  /// Pulled off by a drag rather than a tap or a key.
  final bool dragged;

  /// Where a drag let go, in global coordinates.
  final Offset? position;
}
