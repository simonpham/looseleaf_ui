import 'package:looseleaf_ink/src/art/draw/draw_opts.dart';
import 'package:looseleaf_ink/src/art/draw/paint_skeleton.dart';
import 'package:looseleaf_ink/src/art/draw/skeleton_result.dart';
import 'package:looseleaf_ink/src/art/dsl/dsl.dart';
import 'package:looseleaf_ink/src/art/model/model.dart';
import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';

/// `${seed}` for a string or number seed.
String artSeedText(Object seed) => switch (seed) {
  final num v => JsMath.numberToString(v),
  _ => '$seed',
};

/// Draws [def] at [size] pixels with [seed] (string or number). Doodles and
/// mascots of 128 pixels or more use the `hi` tier.
///
/// Mirrors `drawSkeleton` in `src/lib/ink/art-draw.ts`.
SkeletonResult drawSkeleton(
  ArtDef def,
  double size,
  Object seed, [
  DrawOpts o = const DrawOpts(),
]) {
  final kind = o.kind ?? kindOfDef(def);
  final big = size >= 128 && (kind == ArtKind.doodle || kind == ArtKind.mascot);
  final tier =
      o.tier ??
      switch (big) {
        true => Tier.hi,
        false => Tier.lo,
      };
  final ink = Ink(
    artSeedText(seed),
    tier: tier,
    grain: o.grain,
    calm: o.calm,
    knobs: o.knobs,
  );
  final r = paintSkeleton(ink, def, size, drawOptsWith(o, kind));
  final res = ink.toSvg(w: r.w, h: r.h, pad: o.pad);
  return SkeletonResult(
    result: res,
    variant: r.variant,
    kind: kind,
    nib: r.nib,
    k: r.k,
    silhouette: r.silhouette,
  );
}

/// [o] with its fields, and [kind], [tone], [nib] and [silAll] over them
/// when given.
DrawOpts drawOptsWith(
  DrawOpts o,
  ArtKind kind, {
  ArtTone? tone,
  double? nib,
  bool? silAll,
}) => DrawOpts(
  tone: tone ?? o.tone,
  tier: o.tier,
  ink: o.ink,
  accent: o.accent,
  kind: kind,
  variant: o.variant,
  nib: nib ?? o.nib,
  shade: o.shade,
  grain: o.grain,
  crisp: o.crisp,
  calm: o.calm,
  knobs: o.knobs,
  silAll: silAll ?? o.silAll,
  pad: o.pad,
);
