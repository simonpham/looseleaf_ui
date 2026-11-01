import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/controls.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:looseleaf_ink/src/recipes/marks/tools/tools.dart';

const List<LayerName> _pickerLayers = [
  LayerName.rest,
  LayerName.hover,
  LayerName.checked,
  LayerName.focus,
];

/// Sketchpad tool button params.
///
/// Mirrors `SketchToolParams` in `src/lib/ink/recipes/sketchpad-ink.ts`.
final class SketchToolParams {
  /// Params.
  const SketchToolParams({required this.tool, required this.color});

  final SketchTool tool;
  final SketchColor color;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'tool': tool.name, 'color': color.id};
}

/// A sketchpad tool button: a sample stroke of the tool (or an eraser),
/// a hover underline and a highlighted, boxed checked state.
///
/// Mirrors `sketchToolRecipe` in `src/lib/ink/recipes/sketchpad-ink.ts`.
final Recipe<SketchToolParams> sketchToolRecipe =
    defineRecipe<SketchToolParams>(
      id: 'sketchpad-tool',
      kind: 'sketchpad-tool',
      layers: _pickerLayers,
      lazy: const [LayerName.focus],
      pad: 12,
      draw: _drawTool,
    );

void _drawTool(
  Ink ink,
  Box size,
  SketchToolParams params,
  RecipeContext ctx,
) {
  final Box(:w, :h) = size;
  ctx.lazy(LayerName.focus, (f) => focusRing(f, 0, 0, w, h, r: 5));
  if (ctx.lazyOnly) return;
  final cy = clamp(h * 0.34, 9, 20);
  final x0 = clamp(w * 0.16, 8, 16), x1 = w - x0;
  ink
    ..layer(LayerName.rest, () {
      final tool = params.tool.draw;
      if (tool == null) {
        _eraser(ink, w, cy);
        return;
      }
      final soft = tool == DrawTool.highlighter || tool == DrawTool.marker;
      final amp = switch (soft) {
        true => 1.6,
        false => 3.2,
      };
      final pts = <Pt>[
        for (var i = 0; i <= 12; i++)
          (
            x0 + ((x1 - x0) * i) / 12,
            cy +
                JsMath.sin((i / 12) * JsMath.pi * 2 + 0.4) * amp -
                (i / 12) * 1.5,
          ),
      ];
      final tp = toolPen(
        tool,
        switch (tool == DrawTool.highlighter && params.color.dark) {
          true => SketchColor.hi,
          false => params.color,
        },
      );
      ink.stroke(
        pts,
        tp.pen,
        StrokeOpts(
          color: tp.color,
          width:
              tool.base *
              switch (tool) {
                DrawTool.brush => 1.1,
                _ => 1,
              },
          wobble: 0.5,
          start: StrokeStart.pool,
          end: switch (soft) {
            true => StrokeEnd.soft,
            false => StrokeEnd.flick,
          },
        ),
      );
    })
    ..layer(LayerName.hover, () {
      ink.lines(
        [
          Line(
            seg(4, h - 1.5, w - 5, h - 1, 0.4, 5),
            o: const StrokeOpts(start: StrokeStart.soft, end: StrokeEnd.flick),
          ),
        ],
        PenName.pencilFine,
        const StrokeOpts(alpha: 0.7),
      );
    })
    ..layer(LayerName.checked, () {
      highlight(ink, 5, h - 21, w - 10, 17, pen: PenName.hi);
      box(ink, 1, 1, w - 2, h - 2, pen: PenName.inkFine, corner: 5);
    });
}

void _eraser(Ink ink, double w, double cy) {
  final bw = clamp(w * 0.5, 22, 36);
  const bh = 13.0;
  final x = w / 2 - bw / 2, y = cy - bh / 2;
  final body = roundRectPoly(x, y, bw, bh, 3);
  blobFill(ink, body, PaintKey.bubblegum, alpha: 0.85, mis: 1.6);
  blobFill(
    ink,
    roundRectPoly(x + bw * 0.62, y, bw * 0.38, bh, 3),
    PaintKey.paperShade,
    alpha: 0.9,
    mis: 1,
  );
  box(ink, x, y, bw, bh, pen: PenName.inkFine, corner: 3);
  ink
    ..dot(x - 6, cy + 5, 1.1, PenName.pencil)
    ..dot(x - 9.5, cy + 2, 0.8, PenName.pencil);
}

/// Sketchpad colour swatch params.
///
/// Mirrors `SketchSwatchParams` in `src/lib/ink/recipes/sketchpad-ink.ts`.
final class SketchSwatchParams {
  /// Params.
  const SketchSwatchParams({required this.color});

  final SketchColor color;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'color': color.id};
}

/// A colour swatch: an inked blot in a loop, a hover underline and a wider
/// loop when checked.
///
/// Mirrors `sketchSwatchRecipe` in `src/lib/ink/recipes/sketchpad-ink.ts`.
final Recipe<SketchSwatchParams> sketchSwatchRecipe =
    defineRecipe<SketchSwatchParams>(
      id: 'sketchpad-swatch',
      kind: 'sketchpad-swatch',
      layers: _pickerLayers,
      lazy: const [LayerName.focus],
      pad: 12,
      draw: (ink, size, params, ctx) {
        final Box(:w, :h) = size;
        final cx = w / 2, cy = h / 2;
        final r = math.min(w, h) * 0.3;
        ctx.lazy(
          LayerName.focus,
          (f) => focusRing(f, 0, 0, w, h, shape: FocusShape.ellipse),
        );
        if (ctx.lazyOnly) return;
        ink
          ..layer(LayerName.rest, () {
            ink.part(
              'fill',
              () => blobFill(
                ink,
                ellipsePoly(cx, cy, r, r * 0.94, 20),
                params.color.paint,
                alpha: switch (params.color) {
                  SketchColor.hi => 0.95,
                  _ => 0.9,
                },
                mis: 1.4,
              ),
            );
            loop(
              ink,
              cx,
              cy,
              r + 1.4,
              r + 0.8,
              pen: PenName.inkFine,
              turns: 1.06,
            );
          })
          ..layer(LayerName.hover, () {
            ink.lines(
              [
                Line(
                  seg(cx - r, cy + r + 2.5, cx + r + 1, cy + r + 2.2, 0.3, 4),
                  o: const StrokeOpts(
                    start: StrokeStart.soft,
                    end: StrokeEnd.flick,
                  ),
                ),
              ],
              PenName.inkFine,
              const StrokeOpts(alpha: 0.7),
            );
          })
          ..layer(LayerName.checked, () {
            loop(
              ink,
              cx,
              cy,
              r + 5.4,
              r + 5.6,
              pen: PenName.ink,
              turns: 1.12,
            );
          });
      },
    );

/// Sketchpad size picker params.
///
/// Mirrors `SketchSizeParams` in `src/lib/ink/recipes/sketchpad-ink.ts`.
final class SketchSizeParams {
  /// Params.
  const SketchSizeParams({required this.size});

  final SketchSizeName size;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'size': size.name};
}

/// A stroke size button: an ink dot of the size, a hover underline and a
/// loop when checked.
///
/// Mirrors `sketchSizeRecipe` in `src/lib/ink/recipes/sketchpad-ink.ts`.
final Recipe<SketchSizeParams> sketchSizeRecipe =
    defineRecipe<SketchSizeParams>(
      id: 'sketchpad-size',
      kind: 'sketchpad-size',
      layers: _pickerLayers,
      lazy: const [LayerName.focus],
      pad: 12,
      draw: (ink, size, params, ctx) {
        final Box(:w, :h) = size;
        final cx = w / 2, cy = h / 2;
        ctx.lazy(
          LayerName.focus,
          (f) => focusRing(f, 0, 0, w, h, shape: FocusShape.ellipse),
        );
        if (ctx.lazyOnly) return;
        ink
          ..layer(LayerName.rest, () {
            ink.dot(
              cx,
              cy,
              params.size.dotR,
              PenName.ink,
              const StrokeOpts(width: 1),
            );
          })
          ..layer(LayerName.hover, () {
            ink.lines(
              [
                Line(
                  seg(cx - 6, cy + 11, cx + 7, cy + 10.6, 0.3, 3),
                  o: const StrokeOpts(
                    start: StrokeStart.soft,
                    end: StrokeEnd.flick,
                  ),
                ),
              ],
              PenName.inkFine,
              const StrokeOpts(alpha: 0.7),
            );
          })
          ..layer(LayerName.checked, () {
            loop(
              ink,
              cx,
              cy,
              math.min(w, h) * 0.44,
              math.min(w, h) * 0.44,
              pen: PenName.inkFine,
              turns: 1.1,
            );
          });
      },
    );

/// The sketchpad canvas frame: a faint pencil box and a lazy focus ring.
///
/// Mirrors `canvasFrameRecipe` in `src/lib/ink/recipes/sketchpad-ink.ts`.
final Recipe<NoParams> canvasFrameRecipe = defineRecipe<NoParams>(
  id: 'sketchpad-canvas',
  kind: 'sketchpad-canvas',
  layers: const [LayerName.rest, LayerName.focus],
  lazy: const [LayerName.focus],
  pad: 12,
  draw: (ink, size, params, ctx) {
    final Box(:w, :h) = size;
    ctx.lazy(
      LayerName.focus,
      (f) => focusRing(f, -3, -3, w + 6, h + 6, r: 4),
    );
    if (ctx.lazyOnly) return;
    ink.layer(LayerName.rest, () {
      if (ctx.calm) return;
      box(
        ink,
        -2,
        -2,
        w + 4,
        h + 4,
        pen: PenName.pencilFine,
        opts: const StrokeOpts(alpha: 0.5),
      );
    });
  },
);
