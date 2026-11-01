import 'package:looseleaf_ink/looseleaf_ink.dart';

/// How a [SignaturePad] takes the signature.
enum SignatureMode {
  /// Drawn on the pad.
  draw,

  /// Typed and set in hand lettering.
  type,
}

/// The pen a [SignaturePad] draws with.
enum SignaturePen {
  /// The brush, which swells with pen pressure.
  brush(SketchTool.brush, 0.95),

  /// The felt tip, an even line.
  felt(SketchTool.felt, 1.2);

  const SignaturePen(this.tool, this.size);

  /// The sketchpad tool.
  final SketchTool tool;

  /// The width multiplier upstream gives the pen.
  final double size;
}

/// The image format a [SignaturePad]'s value is encoded in.
enum SignatureFormat {
  /// An SVG `data:` URL.
  svg,

  /// A PNG `data:` URL, rendered at twice the pad's size.
  png,
}

/// What a [SignaturePad]'s value was made from.
///
/// Mirrors `SignatureDetail` in upstream
/// `src/components/ui/signature-pad.tsx`.
class SignatureDetail {
  const SignatureDetail({
    required this.mode,
    required this.strokes,
    required this.text,
  });

  final SignatureMode mode;

  /// The drawn strokes (kept while typing, so switching back restores them).
  final List<SketchStroke> strokes;

  /// The typed name.
  final String text;
}
