import 'dart:math' as math;

import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/paper/paper.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Marquee band recipe params.
///
/// Mirrors `MarqueeBandParams` in `src/lib/ink/recipes/marquee-ink.ts`.
final class MarqueeBandParams {
  /// Params.
  const MarqueeBandParams({this.kind, this.color});

  /// The tape; [TapeKind.washiStripes] when null.
  final TapeKind? kind;

  /// The washi colour.
  final Accent? color;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    if (kind case final TapeKind k) 'kind': k.id,
    if (color case final Accent c) 'color': c.name,
  };
}

/// The marquee's band: a strip of tape the size of the box.
///
/// Mirrors `marqueeBandRecipe` in `src/lib/ink/recipes/marquee-ink.ts`.
final Recipe<MarqueeBandParams> marqueeBandRecipe =
    defineRecipe<MarqueeBandParams>(
      id: 'marquee-band',
      kind: 'marquee-band',
      layers: const [LayerName.rest],
      pad: 4,
      draw: (ink, size, params, ctx) {
        final t = tape(
          '${ctx.seed}|tape',
          kind: params.kind ?? TapeKind.washiStripes,
          color: params.color,
          length: size.w,
          height: size.h,
          tier: ctx.tier,
          calm: ctx.calm,
        );
        ink.layer(LayerName.rest, () => ink.raw(t.svg, Material.top));
      },
    );

/// Marquee play/pause control recipe params.
///
/// Mirrors `MarqueeControlParams` in `src/lib/ink/recipes/marquee-ink.ts`.
final class MarqueeControlParams {
  /// Params.
  const MarqueeControlParams({required this.paused});

  /// Shows a play triangle instead of pause bars.
  final bool paused;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'paused': paused};
}

/// The marquee's round play/pause button, with a ring on hover and a lazy
/// focus ring.
///
/// Mirrors `marqueeControlRecipe` in `src/lib/ink/recipes/marquee-ink.ts`.
final Recipe<MarqueeControlParams> marqueeControlRecipe =
    defineRecipe<MarqueeControlParams>(
      id: 'marquee-control',
      kind: 'marquee-control',
      layers: const [LayerName.rest, LayerName.hover, LayerName.focus],
      lazy: const [LayerName.focus],
      pad: 12,
      draw: (ink, size, params, ctx) {
        final Box(:w, :h) = size;
        final cx = w / 2, cy = h / 2;
        final r = math.min(w, h) / 2 - 2;
        ctx.lazy(
          LayerName.focus,
          (f) => focusRing(f, 0, 0, w, h, shape: FocusShape.ellipse),
        );
        if (ctx.lazyOnly) return;
        ink.layer(LayerName.rest, () {
          blobFill(
            ink,
            ellipsePoly(cx, cy, r - 1, r - 1.4, 18),
            PaintKey.photo,
            alpha: 0.92,
            mis: 0.6,
            material: Material.wash,
          );
          loop(ink, cx, cy, r, r * 0.97, pen: PenName.inkFine, turns: 1.07);
          final k = clamp(r * 0.36, 2.4, 5);
          if (params.paused) {
            ink.lines(
              [
                Line(
                  [
                    (cx - k * 0.5, cy - k),
                    (cx + k * 0.9, cy),
                    (cx - k * 0.5, cy + k),
                    (cx - k * 0.5, cy - k),
                  ],
                  o: const StrokeOpts(poly: true, round: 0.5),
                ),
              ],
              PenName.ink,
              const StrokeOpts(width: 0.9),
            );
            return;
          }
          const soft = StrokeOpts(start: StrokeStart.soft, end: StrokeEnd.soft);
          ink.lines(
            [
              Line([(cx - k * 0.55, cy - k), (cx - k * 0.5, cy + k)], o: soft),
              Line([(cx + k * 0.55, cy - k), (cx + k * 0.6, cy + k)], o: soft),
            ],
            PenName.ink,
            const StrokeOpts(width: 1.1),
          );
        });
        ink.layer(LayerName.hover, () {
          loop(ink, cx, cy, r + 2.2, r + 2, pen: PenName.inkFine, turns: 1.05);
        });
      },
    );
