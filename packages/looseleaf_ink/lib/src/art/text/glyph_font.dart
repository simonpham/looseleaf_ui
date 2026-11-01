/// A lettering font: cap height, advances and outlines, in units per
/// 1000 em, with y up from the baseline negative.
///
/// Mirrors `GlyphFont` in `src/lib/ink/art/glyphs.ts`.
final class GlyphFont {
  /// A font.
  const GlyphFont({required this.cap, required this.adv, required this.d});

  /// The cap height.
  final double cap;

  /// The advance width per character.
  final Map<String, double> adv;

  /// The outline (`M L Q Z`, absolute) per character.
  final Map<String, String> d;
}
