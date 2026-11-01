/// The drawing grid of a definition: 24 (icons), 64 (doodles, stickers) or
/// a `[w, h]` pair (mascots, scenes).
///
/// Mirrors `ArtDef.grid` in `src/lib/ink/art/types.ts`.
final class ArtGrid {
  /// A `[w, h]` grid.
  const ArtGrid(this.w, this.h) : pair = true;

  const ArtGrid._square(double size) : w = size, h = size, pair = false;

  /// The 24 grid of icons.
  static const ArtGrid icon = ArtGrid._square(24);

  /// The 64 grid of doodles and stickers.
  static const ArtGrid doodle = ArtGrid._square(64);

  /// The width.
  final double w;

  /// The height.
  final double h;

  /// Whether the grid was given as a `[w, h]` pair.
  final bool pair;
}
