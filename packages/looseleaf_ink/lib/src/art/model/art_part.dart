import 'package:looseleaf_ink/src/art/model/art_colour.dart';
import 'package:looseleaf_ink/src/art/model/art_enums.dart';
import 'package:looseleaf_ink/src/art/model/hand.dart';

/// One drawing instruction of an art definition, in grid units. Paths use
/// the art DSL (`M L l Q C O E Z`, see `parsePath`).
///
/// Mirrors `Part` in `src/lib/ink/art/types.ts`.
sealed class ArtPart {
  const ArtPart();
}

/// `['f', colour, d, mis?]`: a flat fill of each closed sub-path.
final class FillPart extends ArtPart {
  /// A fill.
  const FillPart(this.colour, this.d, [this.mis]);

  /// The fill colour.
  final ArtColour colour;

  /// The path.
  final String d;

  /// The misregistration multiplier (validated, not drawn).
  final double? mis;
}

/// `['s', d, widthMul?, hand?]`: an ink outline in the drawing's ink.
final class StrokePart extends ArtPart {
  /// An outline.
  const StrokePart(this.d, [this.width, this.hand]);

  /// The path.
  final String d;

  /// The nib width multiplier, 1 when null.
  final double? width;

  /// Start, end and taper.
  final Hand? hand;
}

/// `['c', colour, d, widthMul?, hand?]`: a brush stroke in a colour.
final class ColourStrokePart extends ArtPart {
  /// A coloured stroke.
  const ColourStrokePart(this.colour, this.d, [this.width, this.hand]);

  /// The stroke colour.
  final ArtColour colour;

  /// The path.
  final String d;

  /// The nib width multiplier, 1 when null.
  final double? width;

  /// Start, end and taper.
  final Hand? hand;
}

/// `['d', x, y, r?]`: a blot of ink.
final class DotPart extends ArtPart {
  /// A blot.
  const DotPart(this.x, this.y, [this.r]);

  /// The centre x.
  final double x;

  /// The centre y.
  final double y;

  /// The radius in grid units, 1.4 when null.
  final double? r;
}

/// `['h', d, widthMul?]`: a highlight path (validated, not drawn).
final class HighlightPart extends ArtPart {
  /// A highlight.
  const HighlightPart(this.d, [this.width]);

  /// The path.
  final String d;

  /// The width multiplier.
  final double? width;
}

/// `['t', text, x, y, size, colour?, font?]`: lettering centred on `x`
/// with its baseline at `y`.
final class TextPart extends ArtPart {
  /// Lettering.
  const TextPart(
    this.text,
    this.x,
    this.y,
    this.size, [
    this.colour,
    this.font,
  ]);

  /// The text, drawn upper case.
  final String text;

  /// The centre x.
  final double x;

  /// The baseline y.
  final double y;

  /// The em size in grid units.
  final double size;

  /// The colour; the drawing's ink when null.
  final ArtColour? colour;

  /// The lettering; [LetterFont.hand] when null.
  final LetterFont? font;
}
