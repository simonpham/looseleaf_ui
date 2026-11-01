import 'dart:math' as math;

import 'package:looseleaf_ink/src/art/draw/silhouette.dart';
import 'package:looseleaf_ink/src/core/core.dart';

/// Folds the bottom-right corner of a die-cut sticker back by [s] pixels:
/// clips the art at the fold and draws the mirrored back of the flap with a
/// shading gradient and a pencil crease.
///
/// Mirrors `peelCorner` in `src/lib/ink/art-draw.ts`.
String peelCorner(
  String svg,
  Silhouette sil,
  String id,
  double border,
  double width,
  double height,
  double s,
  String seed,
) {
  const r = math.sqrt1_2;
  double along(Pt p) => (p.x + p.y) * r;
  var dmax = double.negativeInfinity;
  Pt tip = (width, height);
  for (final p in sil.pts) {
    if (along(p) > dmax) {
      dmax = along(p);
      tip = p;
    }
  }
  dmax += border + 1;
  final fold = dmax - s;
  const big = 4000.0;
  Pt at(double dd, double tt) => ((dd + tt) * r, (dd - tt) * r);
  String half(double dd0, double dd1) {
    final a = at(dd0, -big), b = at(dd0, big);
    final c = at(dd1, big), e = at(dd1, -big);
    return 'M${n(a.x)} ${n(a.y)}L${n(b.x)} ${n(b.y)}'
        'L${n(c.x)} ${n(c.y)}L${n(e.x)} ${n(e.y)}Z';
  }

  final tag = hashSeed('peel:$seed').toRadixString(36);
  final keep = '${id}k$tag', cut = '${id}r$tag', grad = '${id}g$tag';
  final tt = (tip.x - tip.y) * r;
  final edge = at(fold, tt);
  final far = at(fold + s * 0.95, tt);
  final m = math.sqrt2 * fold;
  final flap =
      '<g transform="matrix(0 -1 -1 0 ${n(m)} ${n(m)})"><g clip-path="url(#$cut)">'
      '<use href="#${id}f" fill="url(#$grad)" stroke="url(#$grad)" '
      'stroke-width="${n(2 * border)}" stroke-linejoin="round"/>'
      '<use href="#${id}l" stroke="url(#$grad)" '
      'stroke-width="${n(2 * border + sil.w)}" stroke-linejoin="round" '
      'stroke-linecap="round"/></g></g>';
  final c0 = at(fold, tt - s * 1.6), c1 = at(fold, tt + s * 1.6);
  final crease =
      '<path d="M${n(c0.x)} ${n(c0.y)}L${n(c1.x)} ${n(c1.y)}" '
      'stroke="var(--ll-pencil-mark)" stroke-opacity=".35" '
      'stroke-width=".8" stroke-linecap="round"/>';
  final defs =
      '<defs><clipPath id="$keep"><path d="${half(-big, fold)}"/></clipPath>'
      '<clipPath id="$cut"><path d="${half(fold, big)}"/></clipPath>'
      '<linearGradient id="$grad" gradientUnits="userSpaceOnUse" '
      'x1="${n(edge.x)}" y1="${n(edge.y)}" x2="${n(far.x)}" y2="${n(far.y)}">'
      '<stop offset="0" stop-color="var(--ll-pencil-mark)" stop-opacity=".55"/>'
      '<stop offset=".3" stop-color="var(--ll-paper)"/>'
      '<stop offset="1" stop-color="var(--ll-photo)"/></linearGradient></defs>';
  return '$defs<g clip-path="url(#$keep)">$svg</g>$flap$crease';
}
