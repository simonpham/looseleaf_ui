import 'dart:math' as math;

import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/paper/paper.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:looseleaf_ink/src/recipes/paper/paper.dart';

/// Where a page is punched.
///
/// Mirrors `PageHoles` in `src/lib/ink/recipes/page-ink.ts`.
enum PageHoles { none, start, top }

/// Page decor recipe params.
///
/// Mirrors `PageParams` in `src/lib/ink/recipes/page-ink.ts`.
final class PageParams {
  /// Params.
  const PageParams({
    required this.holes,
    required this.reinforce,
    required this.stain,
  });

  /// Where the punched holes go.
  final PageHoles holes;

  /// Reinforcement rings around the holes.
  final bool reinforce;

  /// A coffee ring near the bottom right.
  final bool stain;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'holes': holes.name,
    'reinforce': reinforce,
    'stain': stain,
  };
}

/// A page hole's inset from the edge and radius.
///
/// Mirrors `PAGE_HOLE` in `src/lib/ink/recipes/page-ink.ts`.
const ({double inset, double r}) pageHole = (inset: 22, r: 7.5);

/// The hole centres of a [w]×[h] page punched at [holes].
///
/// Mirrors `pageHoles` in `src/lib/ink/recipes/page-ink.ts`.
List<Pt> pageHoles(double w, double h, PageHoles holes) {
  switch (holes) {
    case PageHoles.none:
      return const [];
    case PageHoles.top:
      final gap = math.min(150, math.max(70, w * 0.2));
      return [
        (w / 2 - gap / 2, pageHole.inset),
        (w / 2 + gap / 2, pageHole.inset),
      ];
    case PageHoles.start:
      final x = pageHole.inset;
      if (h >= 380) {
        return [
          (x, math.max(48, h * 0.1136).toDouble()),
          (x, h / 2),
          (x, math.min(h - 48, h * 0.8864)),
        ];
      }
      if (h >= 190) return [(x, h * 0.3), (x, h * 0.7)];
      return [(x, h / 2)];
  }
}

/// A page's punched holes (with reinforcements) and coffee ring, mirrored
/// to the right edge in right-to-left layouts.
///
/// Mirrors `pageRecipe` in `src/lib/ink/recipes/page-ink.ts`.
final Recipe<PageParams> pageRecipe = defineRecipe<PageParams>(
  id: 'page-decor',
  kind: 'page',
  layers: const [LayerName.rest],
  pad: 0,
  draw: (ink, size, params, ctx) {
    final Box(:w, :h) = size;
    final r = ink.next('holes');
    ink.layer(LayerName.rest, () {
      final s = StringBuffer();
      if (params.stain) {
        final big = math
            .min(52, math.max(26, math.min(w, h) * 0.09))
            .toDouble();
        final ring = coffeeRing(
          '${ink.seed}|ring',
          radius: big,
          tier: ink.tier,
          calm: ctx.calm,
        );
        s.write(
          '<g transform="translate(${num10(w - big * 2 - math.min(36, w * 0.06))} '
          '${num10(h - big * 2 - math.min(64, h * 0.1))}) '
          'rotate(${num10(r.range(-30, 30))} ${num10(big)} ${num10(big)})">'
          '${ring.svg}</g>',
        );
      }
      final pts = pageHoles(w, h, params.holes);
      for (final (i, (x, y)) in pts.indexed) {
        final rr = pageHole.r * (1 + r.gauss(0, 0.025));
        final cx = x + r.gauss(0, 0.4);
        final cy = y + r.gauss(0, 0.5);
        if (params.reinforce) s.write(reinforcement(cx, cy, rr));
        s.write(
          holePunch(
            'll-pg${ink.seed.toRadixString(36)}h$i',
            cx,
            cy,
            rr,
            r.range(-30, 30),
          ),
        );
      }
      final mirrored = ctx.dir == Dir.rtl && params.holes == PageHoles.start;
      ink.raw(switch (mirrored) {
        true => mirrorX(w, '$s'),
        false => '$s',
      }, Material.top);
      if (pts.isNotEmpty) ink.grow(BBox(-2, -2, w + 2, h + 2));
    });
  },
);
