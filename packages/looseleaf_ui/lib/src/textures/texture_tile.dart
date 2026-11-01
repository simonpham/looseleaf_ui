/// One tiling texture: a base64 PNG and the CSS size it tiles at (the
/// bitmaps are drawn at 2× density).
class TextureTile {
  const TextureTile({
    required this.base64,
    required this.cssWidth,
    required this.cssHeight,
  });

  final String base64;
  final double cssWidth;
  final double cssHeight;
}
