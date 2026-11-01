import 'package:looseleaf_ink/src/core/core.dart';

/// The grain kinds, in mask order.
///
/// Mirrors `GRAINS` in `src/lib/ink/builder.ts` (and `GRAIN_KINDS` in
/// `textures.ts`).
const List<GrainKind> grains = GrainKind.values;

/// How many phase variants each grain mask has (`MASK_VARIANTS`).
const int maskVariants = 6;

int _wrapVariant(int variant) =>
    ((variant % maskVariants) + maskVariants) % maskVariants;

/// The mask id for [grain] in phase [variant], e.g. `ll-felt-3`.
///
/// Mirrors `maskId` in `src/lib/ink/builder.ts`.
String maskId(GrainKind grain, int variant) =>
    'll-${grain.name}-${_wrapVariant(variant)}';

/// Every mask id (`MASK_IDS`).
final List<String> maskIds = [
  for (final grain in grains)
    for (var v = 0; v < maskVariants; v++) maskId(grain, v),
];

/// A grain tile's offset (fractions of the tile) and rotation for a variant.
final class MaskPhase {
  /// A phase.
  const MaskPhase(this.x, this.y, this.rot);

  /// Horizontal offset, `[0, 1)`.
  final double x;

  /// Vertical offset, `[0, 1)`.
  final double y;

  /// Rotation in degrees: 0, 90, 180 or 270.
  final int rot;
}

const List<int> _rots = [0, 90, 180, 270, 0, 180];

/// The tile phase for [variant].
///
/// Mirrors `maskPhase` in `src/lib/ink/builder.ts` and `grainPhase` in
/// `textures.ts`.
MaskPhase maskPhase(int variant) {
  final v = _wrapVariant(variant);
  return MaskPhase((v * 0.618034) % 1, (v * 0.381966 + 0.17) % 1, _rots[v]);
}

/// The id of a grain mask, with an optional phase [variant] and id [prefix].
///
/// Mirrors `grainMaskId` in `src/lib/ink/textures.ts`.
String grainMaskId(GrainKind kind, {int? variant, String? prefix}) {
  final p = prefix ?? 'll';
  if (variant == null) return '$p-${kind.name}';
  return '$p-${kind.name}-${_wrapVariant(variant)}';
}

/// `url(#<grainMaskId>)`.
///
/// Mirrors `grainMaskUrl` in `src/lib/ink/textures.ts`.
String grainMaskUrl(GrainKind kind, {int? variant, String? prefix}) =>
    'url(#${grainMaskId(kind, variant: variant, prefix: prefix)})';

/// The grain variant for a seed.
///
/// Mirrors `grainVariantFor` in `src/lib/ink/textures.ts`.
int grainVariantFor(int seed) =>
    (JsMath.imul(seed, 0x9e3779b1) >> 7) % maskVariants;
