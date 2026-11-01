import 'package:looseleaf_ink/src/art/art.dart';
import 'package:looseleaf_ink/src/core/core.dart';

/// The look of a seal.
///
/// Mirrors `SealVariant` in `src/lib/ink/recipes/seal-ink.ts`.
enum SealVariant {
  scallop,
  starburst,
  rosette,
  medal,
  shield,
  plate,
  ticket,
  tag,
  ring,
  wax,
}

/// Every seal variant, in upstream order (`sealVariantList`).
const List<SealVariant> sealVariants = SealVariant.values;

/// A mark drawn in place of a seal's text.
///
/// Mirrors `SealMark` in `src/lib/ink/recipes/seal-ink.ts`.
enum SealMark { check, star }

/// Every seal mark, in upstream order (`sealMarkList`).
const List<SealMark> sealMarks = SealMark.values;

/// A seal's look and lettering.
///
/// Mirrors `SealParams` in `src/lib/ink/recipes/seal-ink.ts`.
final class SealParams {
  /// Params.
  const SealParams({
    required this.variant,
    this.text,
    this.sub,
    this.mark,
    this.tone,
    this.ribbon,
    this.ring,
    this.deco,
    this.textColor,
  });

  /// The look.
  final SealVariant variant;

  /// The lettering.
  final String? text;

  /// A second line (not on tickets).
  final String? sub;

  /// A check or star in place of the text.
  final SealMark? mark;

  /// The seal's colour (not [PaintKey.current]).
  final PaintKey? tone;

  /// The ribbon colour of a rosette or medal.
  final PaintKey? ribbon;

  /// Text set around a large ring seal.
  final String? ring;

  /// A decoration on a badge seal.
  final BadgeDeco? deco;

  /// The lettering colour.
  final PaintKey? textColor;
}
