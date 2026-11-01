import 'package:looseleaf_ink/src/art/draw/die_cut.dart';
import 'package:looseleaf_ink/src/art/draw/draw_opts.dart';
import 'package:looseleaf_ink/src/art/gen/gen.dart';
import 'package:looseleaf_ink/src/art/model/model.dart';
import 'package:looseleaf_ink/src/builder/builder.dart';

/// Draws any sticker at [size] pixels: art and badges as die cuts, stamps
/// at their own size (a stamp ignores [size] and [o]).
///
/// Mirrors `renderSticker` in `src/lib/ink/art-draw.ts`.
InkResult renderSticker(
  StickerDef def,
  double size,
  Object seed, [
  DieCutOpts o = const DieCutOpts(),
]) => switch (def) {
  BadgeGen(:final text, :final opts) => dieCut(
    badgeSkeleton(text, opts),
    size,
    seed,
    o,
  ).result,
  StampGen(:final text, :final shape, :final opts) => stamp(
    text,
    shape,
    opts.withSeed(seed),
  ),
  final ArtDef art => dieCut(art, size, seed, o).result,
};
