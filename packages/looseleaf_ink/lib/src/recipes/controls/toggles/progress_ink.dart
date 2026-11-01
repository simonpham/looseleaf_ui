import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/no_params.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// The progress track: a shaded slot in an inked box.
///
/// Mirrors `progressRecipe` in `src/lib/ink/recipes/progress-ink.ts`.
final Recipe<NoParams> progressRecipe = defineRecipe<NoParams>(
  id: 'progress',
  kind: 'progress',
  layers: const [LayerName.rest],
  pad: 12,
  draw: (ink, size, _, ctx) {
    final Box(:w, :h) = size;
    final r = clamp(h * 0.22, 1.5, 4);
    final body = roundRectPoly(1.2, 1.2, w - 2.4, h - 2.4, r);
    ink.layer(LayerName.rest, () {
      ink.poly(Material.under, body, PaintKey.slip, 0.85);
      solidFill(
        ink,
        body,
        PaintKey.paperShade,
        alpha: 1,
        material: Material.wash,
      );
      if (ctx.calm) {
        box(ink, 0, 0, w, h, pen: PenName.pencilFine, corner: r);
        return;
      }
      box(
        ink,
        0,
        0,
        w,
        h,
        pen: PenName.ink,
        corner: r,
        opts: StrokeOpts(width: 1.05, simple: w > 240),
      );
    });
  },
);

/// The progress fill's marker: its scribble pen and its fill paint.
enum ProgressTone {
  marker(PenName.terracotta, PaintKey.marker),
  hi(PenName.hi, PaintKey.hi),
  green(PenName.mGrass, PaintKey.grass),
  blue(PenName.mSky, PaintKey.sky);

  const ProgressTone(this.pen, this.paint);

  /// The pen of the indeterminate scribble.
  final PenName pen;

  /// The paint of the determinate fill.
  final PaintKey paint;
}

/// Progress fill params.
///
/// Mirrors `ProgressFillParams` in `src/lib/ink/recipes/progress-ink.ts`.
final class ProgressFillParams {
  /// Params.
  const ProgressFillParams({this.tone, this.indeterminate = false});

  /// The marker, [ProgressTone.marker] when null.
  final ProgressTone? tone;

  /// Draws a zigzag scribble instead of a solid fill.
  final bool indeterminate;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'tone': ?tone?.name,
    if (indeterminate) 'indeterminate': true,
  };
}

/// The progress fill: a solid marker bar, or a zigzag scribble when
/// indeterminate.
///
/// Mirrors `progressFillRecipe` in `src/lib/ink/recipes/progress-ink.ts`.
final Recipe<ProgressFillParams> progressFillRecipe =
    defineRecipe<ProgressFillParams>(
      id: 'progress-fill',
      kind: 'progress',
      layers: const [LayerName.rest],
      pad: 12,
      draw: _drawFill,
    );

void _drawFill(
  Ink ink,
  Box size,
  ProgressFillParams params,
  RecipeContext ctx,
) {
  final Box(:w, :h) = size;
  final tone = params.tone ?? ProgressTone.marker;
  ink.layer(LayerName.rest, () {
    if (params.indeterminate) {
      _scribble(ink, w, h, tone, ctx.calm);
      return;
    }
    ink.part('fill', () {
      solidFill(
        ink,
        roundRectPoly(1.6, 1.6, w - 3.2, h - 3.2, clamp(h * 0.22, 1.5, 4)),
        tone.paint,
        alpha: 0.95,
      );
      return InkOffset.zero;
    });
  });
}

void _scribble(Ink ink, double w, double h, ProgressTone tone, bool calm) {
  final rng = ink.next('scribble');
  final top = h * 0.16;
  final bot = h * 0.84;
  final step = clamp(w / 40, h * 0.75, 16);
  final pts = <Pt>[(-1, h / 2)];
  var up = false;
  for (double x = 2; x < w - 1; x += step, up = !up) {
    final px = math.min(x + rng.range(-1, 1), w - 1);
    final base = switch (up) {
      true => top,
      false => bot,
    };
    pts.add((px, base + rng.range(-0.8, 0.8)));
  }
  pts.add((w + 0.5, h / 2));
  ink.stroke(
    pts,
    tone.pen,
    StrokeOpts(
      width: switch (tone) {
        ProgressTone.hi => 0.36,
        ProgressTone.blue => 1.4,
        _ => clamp(h * 0.07, 0.5, 0.9),
      },
      alpha: 0.92,
      start: StrokeStart.pool,
      end: StrokeEnd.pool,
      wobble: 0.5,
      poly: true,
      round: 2,
      simple: w > 160 || calm,
    ),
  );
}
