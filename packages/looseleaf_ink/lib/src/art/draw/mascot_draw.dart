import 'dart:math' as math;

import 'package:looseleaf_ink/src/art/draw/die_cut.dart';
import 'package:looseleaf_ink/src/art/draw/draw_opts.dart';
import 'package:looseleaf_ink/src/art/draw/skeleton_result.dart';
import 'package:looseleaf_ink/src/art/draw/variant.dart';
import 'package:looseleaf_ink/src/art/model/model.dart';
import 'package:looseleaf_ink/src/core/core.dart';

/// Options of [drawMascot].
///
/// Mirrors `MascotDrawOpts` in `src/lib/ink/art/mascot-draw.ts`.
final class MascotDrawOpts {
  /// Mascot options.
  const MascotDrawOpts({this.tier, this.idPrefix, this.border, this.shadow});

  /// The tier; `lo` when null.
  final Tier? tier;

  /// The id prefix of the silhouette defs.
  final String? idPrefix;

  /// The border width.
  final double? border;

  /// A drop shadow.
  final bool? shadow;
}

/// Draws a mascot pose as a die-cut sticker that fits [size] pixels,
/// border included, with crisp strokes and no grain.
///
/// Mirrors `drawMascot` in `src/lib/ink/art/mascot-draw.ts`.
DieCutResult drawMascot(
  ArtDef def,
  double size,
  Object seed, [
  MascotDrawOpts o = const MascotDrawOpts(),
]) {
  final px = math.max(16, JsMath.roundInt(size)).toDouble();
  final border =
      o.border ??
      switch (px < 28) {
        true => 1.0,
        false => clamp(px * 0.065, 1.8, 6.5),
      };
  final art = math.max(8.0, px - 2 * (border + 2).ceil());
  final nib = clamp(art * (def.nibK ?? 0.05), 1.05, 4.6);
  return dieCut(
    def,
    art,
    seed,
    DieCutOpts(
      border: border,
      nib: nib,
      tier: o.tier ?? Tier.lo,
      variant: mascotVariant(px),
      idPrefix: o.idPrefix,
      shadow: o.shadow,
      silAll: false,
      crisp: true,
      grain: false,
    ),
  );
}
