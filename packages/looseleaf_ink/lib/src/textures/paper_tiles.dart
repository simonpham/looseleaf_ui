/// A paper tile: the CSS size it tiles at (the bitmaps are drawn at 2×).
///
/// Mirrors `PaperTileName` and the tile sizes of `PAPER_TILES` in
/// `src/lib/ink/textures-paper.generated.ts`; the image data lives in the
/// Flutter package.
enum PaperTileName {
  relief(192, 192),
  slip(128, 128),
  fibre(240, 240),
  cloud(720, 720),
  mottle(720, 720),
  linen(160, 160),
  kraft(192, 96);

  const PaperTileName(this.cssWidth, this.cssHeight);

  /// Tile width in CSS px.
  final double cssWidth;

  /// Tile height in CSS px.
  final double cssHeight;
}

/// A grain mask tile size in CSS px, by grain kind name.
///
/// Mirrors the `css` sizes of `GRAIN_TILES` in
/// `src/lib/ink/textures.generated.ts`.
const Map<String, double> grainTileCss = {
  'felt': 112,
  'marker': 128,
  'graphite': 112,
  'waxy': 112,
  'stamp': 160,
};

/// Resolves a tile name (paper tile or grain kind) to its image URI.
typedef TileUri = String Function(String name);
