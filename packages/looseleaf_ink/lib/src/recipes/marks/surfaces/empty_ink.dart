import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/controls.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

const StrokeOpts _tick = StrokeOpts(
  start: StrokeStart.soft,
  end: StrokeEnd.flick,
  simple: true,
);

/// The empty state's frame: a dashed box with crop ticks at two corners.
///
/// Mirrors `emptyFrameRecipe` in `src/lib/ink/recipes/empty-ink.ts`.
final Recipe<NoParams> emptyFrameRecipe = defineRecipe<NoParams>(
  id: 'empty-frame',
  kind: 'frame',
  layers: const [LayerName.rest],
  pad: 8,
  draw: _drawFrame,
);

void _drawFrame(
  Ink ink,
  Box size,
  NoParams params,
  RecipeContext ctx,
) {
  final Box(:w, :h) = size;
  ink.layer(LayerName.rest, () {
    final r = math.min(12, math.min(w, h) / 4).toDouble();
    dashedBox(
      ink,
      1,
      1,
      w - 2,
      h - 2,
      r: r,
      pen: switch (ctx.calm) {
        true => PenName.pencilFine,
        false => PenName.pencil,
      },
      dash: 9,
      gap: 6.5,
    );
    if (ctx.calm) return;
    const t = 7;
    final ticks = [
      Line(seg(-2, r + 2, -2, r + 2 - t, 0, 2), o: _tick),
      Line(seg(r + 2, -2, r + 2 - t, -2, 0, 2), o: _tick),
      Line(seg(w + 2, h - r - 2, w + 2, h - r - 2 + t, 0, 2), o: _tick),
      Line(seg(w - r - 2, h + 2, w - r - 2 + t, h + 2, 0, 2), o: _tick),
    ];
    ink.lines(ticks, PenName.pencilFine, const StrokeOpts(alpha: 0.7));
  });
}

/// The empty state's media tile: a slip, a yellow wash, an outline and
/// edge shading on the bottom and right.
///
/// Mirrors `emptyMediaRecipe` in `src/lib/ink/recipes/empty-ink.ts`.
final Recipe<NoParams> emptyMediaRecipe = defineRecipe<NoParams>(
  id: 'empty-media',
  kind: 'tile',
  layers: const [LayerName.rest],
  pad: 8,
  draw: _drawMedia,
);

void _drawMedia(
  Ink ink,
  Box size,
  NoParams params,
  RecipeContext ctx,
) {
  final Box(:w, :h) = size;
  final body = roundRectPoly(1.5, 1.5, w - 3, h - 3, 6);
  ink.layer(LayerName.rest, () {
    ink.poly(Material.under, body, PaintKey.slip, 0.98);
    wash(
      ink,
      body,
      PaintKey.hi,
      alpha: switch (ctx.calm) {
        true => 0.25,
        false => 0.35,
      },
    );
    box(
      ink,
      0,
      0,
      w,
      h,
      pen: switch (ctx.calm) {
        true => PenName.pencilFine,
        false => PenName.inkFine,
      },
      corner: 6,
    );
    if (ctx.calm) return;
    edgeBand(ink, 0, 0, w, h, EdgeSide.b, thick: 4);
    edgeBand(ink, 0, 0, w, h, EdgeSide.r, thick: 4);
  });
}
