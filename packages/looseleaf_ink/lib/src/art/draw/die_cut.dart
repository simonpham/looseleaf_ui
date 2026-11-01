import 'dart:math' as math;

import 'package:looseleaf_ink/src/art/draw/draw_opts.dart';
import 'package:looseleaf_ink/src/art/draw/draw_skeleton.dart';
import 'package:looseleaf_ink/src/art/draw/paint_skeleton.dart';
import 'package:looseleaf_ink/src/art/draw/peel_corner.dart';
import 'package:looseleaf_ink/src/art/draw/skeleton_result.dart';
import 'package:looseleaf_ink/src/art/model/model.dart';
import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';

/// Draws [def] as a die-cut sticker at [size] pixels: the art over a white
/// (photo paper) silhouette with a pencil edge, an optional shadow and an
/// optional peeled corner.
///
/// Mirrors `dieCut` in `src/lib/ink/art-draw.ts`.
DieCutResult dieCut(
  ArtDef def,
  double size,
  Object seed, [
  DieCutOpts o = const DieCutOpts(),
]) {
  final kind = o.kind ?? ArtKind.sticker;
  final border = o.border ?? clamp(size * 0.075, 3.5, 8);
  final off = (border + 2).ceilToDouble();
  final (gw, gh) = artGridSize(def);
  final k = size / math.max(gw, gh);
  final width = gw * k + 2 * off, height = gh * k + 2 * off;
  final tier =
      o.tier ??
      switch (size >= 96) {
        true => Tier.hi,
        false => Tier.lo,
      };
  final text = artSeedText(seed);
  final ink = Ink(
    'die:$text',
    tier: tier,
    grain: o.grain,
    calm: o.calm,
    knobs: o.knobs,
  );
  final id =
      o.idPrefix ??
      'll-sil-${hashSeed('$text:${JsMath.numberToString(size)}:${def.parts.length}:${JsMath.numberToString(width)}').toRadixString(36)}';
  final art = paintSkeleton(
    ink,
    def,
    size,
    drawOptsWith(
      o,
      kind,
      tone: o.tone ?? ArtTone.doodle,
      nib: o.nib ?? clamp(size * (def.nibK ?? 0.055), 1.8, 4.6),
      silAll: o.silAll ?? true,
    ),
    (off, off),
  );
  final s = art.silhouette;
  final bw = 2 * border;
  final fills = s.fills.map((d) => '<path d="$d"/>').join();
  final lines = s.lines.map((d) => '<path d="$d" fill="none"/>').join();
  final defs =
      '<defs><g id="${id}f">$fills</g><g id="${id}l">$lines</g></defs>';
  String layer(
    String fill,
    String stroke,
    double extra,
    double op, [
    double dx = 0,
    double dy = 0,
  ]) {
    final t = switch (dx != 0 || dy != 0) {
      true => ' transform="translate(${n(dx)} ${n(dy)})"',
      false => '',
    };
    final opa = switch (op < 1) {
      true => ' opacity="${n(op, 100)}"',
      false => '',
    };
    return '<g$t$opa><use href="#${id}f" fill="$fill" stroke="$stroke" '
        'stroke-width="${n(bw + extra)}" stroke-linejoin="round"/>'
        '<use href="#${id}l" stroke="$stroke" '
        'stroke-width="${n(bw + extra + s.w)}" stroke-linejoin="round" '
        'stroke-linecap="round"/></g>';
  }

  var under = defs;
  if (o.shadow ?? false) {
    under +=
        layer('var(--ll-ink)', 'var(--ll-ink)', 1, 0.1, 0.4, 3.4) +
        layer('var(--ll-ink)', 'var(--ll-ink)', 0.4, 0.2, 0.2, 1.1);
  }
  under += layer('var(--ll-pencil-mark)', 'var(--ll-pencil-mark)', 1.3, 0.55);
  under += layer('var(--ll-photo)', 'var(--ll-photo)', 0, 1);
  ink
    ..raw(under, Material.under)
    ..grow(BBox(0, 0, width, height));
  var res = ink.toSvg(w: width, h: height, pad: o.pad ?? 2);
  final peel = switch (o.peel) {
    Peel(size: null) => clamp(size * 0.2, 12, 26),
    Peel(size: final double fold) when fold != 0 && !fold.isNaN => fold,
    _ => null,
  };
  if (peel != null) {
    res = InkResult(
      svg: peelCorner(res.svg, s, id, border, width, height, peel, text),
      w: res.w,
      h: res.h,
      pad: res.pad,
      layers: res.layers,
      parts: res.parts,
      bbox: res.bbox,
    );
  }
  return DieCutResult(
    result: res,
    variant: art.variant,
    kind: kind,
    nib: art.nib,
    k: art.k,
    silhouette: s,
    off: off,
    border: border,
  );
}
