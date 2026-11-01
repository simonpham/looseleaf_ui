import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Carousel tick recipe params.
///
/// Mirrors `CarouselTickParams` in `src/lib/ink/recipes/carousel-ink.ts`.
final class CarouselTickParams {
  /// Params.
  const CarouselTickParams({required this.slash, required this.pitch});

  /// Draws a long slash reaching back [pitch] ticks instead of a short tick.
  final bool slash;

  /// The distance between ticks.
  final double pitch;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'slash': slash, 'pitch': pitch};
}

/// The padding of a slashed carousel tick (room for the slash).
///
/// Mirrors `CAROUSEL_TICK_PAD` in `src/lib/ink/recipes/carousel-ink.ts`.
const double carouselTickPad = 108;

/// The padding a plain carousel tick needs.
///
/// Mirrors `CAROUSEL_TICK_PAD_PLAIN` in
/// `src/lib/ink/recipes/carousel-ink.ts`.
const double carouselTickPadPlain = 16;

/// A carousel position tick: a pencil tick at rest, a hover wash, a blue
/// tick (or slash) when checked and a lazy focus ring.
///
/// Mirrors `carouselTickRecipe` in `src/lib/ink/recipes/carousel-ink.ts`.
final Recipe<CarouselTickParams> carouselTickRecipe =
    defineRecipe<CarouselTickParams>(
      id: 'carousel-tick',
      kind: 'tick',
      layers: const [
        LayerName.rest,
        LayerName.hover,
        LayerName.checked,
        LayerName.focus,
      ],
      lazy: const [LayerName.focus],
      pad: carouselTickPad,
      draw: _draw,
    );

void _draw(Ink ink, Box size, CarouselTickParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final slash = params.slash;
  ctx.lazy(LayerName.focus, (f) => focusRing(f, 0, 0, w, h, r: 4));
  if (ctx.lazyOnly) return;
  final rtl = ctx.dir == Dir.rtl;
  final calm = ctx.calm;
  final len = math.min(h - 6, 22).toDouble();
  final cx = w / 2;
  final y0 = (h - len) / 2;
  void stroke(PenName pen, double grow, String name, double width) {
    final rng = ink.next(name);
    final dir = switch (rtl) {
      true => -1.0,
      false => 1.0,
    };
    final List<Pt> pts;
    if (slash) {
      final reach = 4 * params.pitch + rng.gauss(2, 1);
      pts = seg(
        cx - dir * reach,
        y0 + len * 0.86 + grow,
        cx + dir * (3 + rng.gauss(0, 0.5)),
        y0 + len * 0.14 - grow,
        rng.gauss(0, 0.6),
        9,
      );
    } else {
      final lean = dir * rng.range(0.6, 1.6);
      pts = seg(
        cx + lean + rng.gauss(0, 0.4),
        y0 - grow + rng.gauss(0, 0.4),
        cx - lean + rng.gauss(0, 0.5),
        y0 + len + grow + rng.gauss(0, 0.5),
        rng.gauss(0, 0.5),
        5,
      );
    }
    ink.stroke(
      pts,
      pen,
      StrokeOpts(
        start: StrokeStart.pool,
        end: StrokeEnd.flick,
        wobble: 0.5,
        width: width,
      ),
    );
  }

  ink
    ..layer(
      LayerName.rest,
      () => switch (calm) {
        true => stroke(PenName.pencilFine, 0, 'tk', 0.9),
        false => stroke(PenName.pencil, 0, 'tk', 1.3),
      },
    )
    ..layer(LayerName.hover, () {
      if (!slash) {
        wash(
          ink,
          roundRectPoly(1, 3, w - 2, h - 6, 3),
          PaintKey.hi,
          alpha: 0.6,
        );
        return;
      }
      wash(
        ink,
        roundRectPoly(cx - 9, y0 - 2, 18, len + 4, 3),
        PaintKey.hi,
        alpha: 0.6,
      );
    })
    ..layer(
      LayerName.checked,
      () => switch (calm) {
        true => stroke(PenName.blueFine, 2, 'ck', 1.2),
        false => stroke(PenName.blue, 2, 'ck', 2.1),
      },
    );
}
