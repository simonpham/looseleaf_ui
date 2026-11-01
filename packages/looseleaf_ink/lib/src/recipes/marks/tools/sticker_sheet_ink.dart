import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/controls.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Sticker sheet params.
///
/// Mirrors `StickerSheetParams` in
/// `src/lib/ink/recipes/sticker-sheet-ink.ts`.
final class StickerSheetParams {
  /// Params.
  const StickerSheetParams({required this.top});

  /// Space above the printed area (for a header), in pixels.
  final double top;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'top': top};
}

/// The printed sheet behind stickers: a dashed rounded frame and crop marks.
///
/// Mirrors `stickerSheetRecipe` in `src/lib/ink/recipes/sticker-sheet-ink.ts`.
final Recipe<StickerSheetParams> stickerSheetRecipe =
    defineRecipe<StickerSheetParams>(
      id: 'sticker-sheet',
      kind: 'print',
      layers: const [LayerName.rest],
      pad: 10,
      draw: _drawSheet,
    );

void _drawSheet(
  Ink ink,
  Box size,
  StickerSheetParams params,
  RecipeContext ctx,
) {
  final Box(:w, :h) = size;
  const x0 = 6.0;
  final x1 = w - 6, y0 = 6 + params.top, y1 = h - 6;
  if (x1 - x0 < 24 || y1 - y0 < 24) return;
  ink.layer(LayerName.rest, () {
    final dash = clamp((2 * (x1 - x0 + y1 - y0)) / 60, 6, 14);
    dashedBox(
      ink,
      x0,
      y0,
      x1 - x0,
      y1 - y0,
      r: 14,
      pen: PenName.pencil,
      dash: dash,
      gap: dash * 0.75,
      opts: const StrokeOpts(alpha: 0.6, width: 1.1),
    );
    if (ctx.calm) return;
    const t = 7, g = 4;
    void mark(double cx, double cy, double sx, double sy) {
      line(
        ink,
        cx - sx * g,
        cy,
        cx - sx * (g + t),
        cy,
        pen: PenName.pencilFine,
        opts: const StrokeOpts(alpha: 0.75, simple: true),
      );
      line(
        ink,
        cx,
        cy - sy * g,
        cx,
        cy - sy * (g + t),
        pen: PenName.pencilFine,
        opts: const StrokeOpts(alpha: 0.75, simple: true),
      );
    }

    mark(x0, y0, 1, 1);
    mark(x1, y0, -1, 1);
    mark(x0, y1, 1, -1);
    mark(x1, y1, -1, -1);
  });
}

/// The focus ring of one sticker slot on the sheet.
///
/// Mirrors `stickerSlotRecipe` in `src/lib/ink/recipes/sticker-sheet-ink.ts`.
final Recipe<NoParams> stickerSlotRecipe = defineRecipe<NoParams>(
  id: 'sticker-slot',
  kind: 'frame',
  layers: const [LayerName.focus],
  lazy: const [LayerName.focus],
  pad: 12,
  draw: (ink, size, params, ctx) {
    final Box(:w, :h) = size;
    ctx.lazy(
      LayerName.focus,
      (f) => focusRing(f, 1, 1, w - 2, h - 2, r: 10),
    );
  },
);
