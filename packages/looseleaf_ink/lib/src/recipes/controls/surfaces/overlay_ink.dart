import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// The ink of a close mark.
enum CloseMarkTone { ink, red }

/// Close mark params.
///
/// Mirrors `CloseMarkParams` in `src/lib/ink/recipes/overlay-ink.ts`.
final class CloseMarkParams {
  /// Params.
  const CloseMarkParams({this.tone});

  /// The cross's ink, [CloseMarkTone.ink] when null.
  final CloseMarkTone? tone;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'tone': ?tone?.name};
}

/// The close button of dialogs and sheets: an inked cross, a highlighter
/// swipe on hover and a round focus ring (lazy).
///
/// Mirrors `closeMarkRecipe` in `src/lib/ink/recipes/overlay-ink.ts`.
final Recipe<CloseMarkParams> closeMarkRecipe = defineRecipe<CloseMarkParams>(
  id: 'overlay-close',
  kind: 'close',
  layers: const [LayerName.rest, LayerName.hover, LayerName.focus],
  lazy: const [LayerName.focus],
  pad: 12,
  draw: (ink, size, params, ctx) {
    final Box(:w, :h) = size;
    final cx = w / 2;
    final cy = h / 2;
    ctx.lazy(
      LayerName.focus,
      (f) => focusRing(
        f,
        cx - 12,
        cy - 12,
        24,
        24,
        shape: FocusShape.ellipse,
        gap: 1.5,
      ),
    );
    if (ctx.lazyOnly) return;
    final calm = ctx.calm;
    final s = switch (calm) {
      true => 11.0,
      false => 12.5,
    };
    ink
      ..layer(LayerName.rest, () {
        cross(
          ink,
          cx - s / 2,
          cy - s / 2,
          s,
          pen: switch ((params.tone, calm)) {
            (CloseMarkTone.red, _) => PenName.redfelt,
            (_, true) => PenName.inkFine,
            (_, false) => PenName.ink,
          },
          opts: StrokeOpts(
            width: switch (calm) {
              true => 1.1,
              false => 1.35,
            },
            start: StrokeStart.soft,
          ),
        );
      })
      ..layer(LayerName.hover, () {
        highlight(
          ink,
          cx - 12,
          cy - 8.5,
          24,
          17,
          pen: PenName.hi,
          opts: const StrokeOpts(alpha: 0.85),
        );
      });
  },
);

/// The hand-drawn arrow pointing at a popover's anchor, [w] × [h]
/// (22 × 20 by default), padded by 3.
///
/// Mirrors `pointerMark` in `src/lib/ink/recipes/overlay-ink.ts`.
InkResult pointerMark(
  Object seed, {
  double? w,
  double? h,
  Tier? tier,
  bool? calm,
}) {
  final width = w ?? 22;
  final height = h ?? 20;
  final ink = Ink(seed, tier: tier, calm: calm);
  final r = ink.next('pointer');
  final x = width / 2 + r.gauss(0, 0.5);
  final x2 = x + r.range(-0.4, 1);
  final curve = r.range(0.1, 0.17);
  arrow(
    ink,
    x - 0.6,
    0.6,
    x2,
    height - 1.8,
    pen: PenName.ink,
    head: ArrowHead.v,
    headLen: math.min(10.5, height * 0.56),
    curve: curve,
    opts: const StrokeOpts(width: 1.6),
  );
  ink.grow(BBox(0, 0, width, height));
  return ink.toSvg(w: width, h: height, pad: 3);
}
