import 'package:looseleaf_ink/src/recipes/controls/pencil_tiles_ink.dart';

/// How many boil frames a skeleton cycles through.
///
/// Mirrors `SKELETON_FRAMES` in `src/lib/ink/recipes/skeleton-ink.ts`.
const int skeletonFrames = 3;

/// The length of one skeleton boil cycle, in seconds.
///
/// Mirrors `SKELETON_BOIL_S` in `src/lib/ink/recipes/skeleton-ink.ts`.
const double skeletonBoilSeconds = 1.08;

/// The pencil tiles of one skeleton boil frame, as CSS `url(...)` values:
/// the horizontal and vertical outline edges, the hatch fill and the
/// circle outline of round skeletons.
final class SkeletonTiles {
  /// Tiles.
  const SkeletonTiles({
    required this.edgeH,
    required this.edgeV,
    required this.hatch,
    required this.circle,
  });

  final String edgeH;
  final String edgeV;
  final String hatch;
  final String circle;
}

/// The tiles of skeleton boil [frame] (`0 <= frame < skeletonFrames`).
///
/// Mirrors the frames built in `skeletonCss` in
/// `src/lib/ink/recipes/skeleton-ink.ts`.
SkeletonTiles skeletonTiles(int frame) => SkeletonTiles(
  edgeH: edgeTile('skeleton|edge-h|$frame', false),
  edgeV: edgeTile('skeleton|edge-v|$frame', true),
  hatch: hatchTile('skeleton|hatch|$frame'),
  circle: circleTile('skeleton|circle|$frame'),
);
