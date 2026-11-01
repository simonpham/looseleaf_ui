import 'package:looseleaf_ink/src/art/model/model.dart';

/// The size variant drawn for [kind] at [size] pixels.
///
/// Mirrors `variantFor` in `src/lib/ink/art-draw.ts`.
Variant variantFor(ArtKind kind, double size) => switch (kind) {
  ArtKind.icon when size <= 13 => Variant.micro,
  ArtKind.icon when size <= 19 => Variant.small,
  ArtKind.icon when size <= 40 => Variant.master,
  ArtKind.icon => Variant.hi,
  ArtKind.doodle when size < 72 => Variant.small,
  ArtKind.doodle when size < 120 => Variant.master,
  ArtKind.doodle => Variant.hi,
  ArtKind.sticker when size < 80 => Variant.small,
  ArtKind.sticker when size < 120 => Variant.master,
  ArtKind.sticker => Variant.hi,
  ArtKind.mascot when size < 40 => Variant.micro,
  ArtKind.mascot when size < 72 => Variant.small,
  ArtKind.mascot when size < 140 => Variant.master,
  ArtKind.mascot => Variant.hi,
  _ => Variant.master,
};

/// The parts of [def] drawn for [variant], falling back to bigger variants.
///
/// Mirrors `partsFor` in `src/lib/ink/art-draw.ts`.
List<ArtPart> partsFor(ArtDef def, Variant variant) => switch (variant) {
  Variant.micro => def.micro ?? def.small ?? def.parts,
  Variant.small => def.small ?? def.parts,
  Variant.hi => switch (def.hi) {
    final hi? => [...def.parts, ...hi],
    null => def.parts,
  },
  Variant.master => def.parts,
};

/// The variant of a mascot drawn at [size] pixels by `drawMascot`.
///
/// Mirrors `mascotVariant` in `src/lib/ink/art/mascot-draw.ts`.
Variant mascotVariant(double size) {
  if (size < 28) return Variant.micro;
  if (size < 56) return Variant.small;
  if (size < 140) return Variant.master;
  return Variant.hi;
}
