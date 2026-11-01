import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// One sticker placed on a board.
///
/// Mirrors `StickerBoardItem` in `src/lib/ink/recipes/sticker-board-ink.ts`.
final class StickerBoardItem {
  /// An item.
  const StickerBoardItem({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.rot,
    required this.scale,
    required this.z,
  });

  final String id;

  /// The sticker art's name.
  final String name;

  /// Centre, in board pixels.
  final double x;
  final double y;

  /// Rotation, in degrees.
  final double rot;
  final double scale;

  /// Stacking order.
  final double z;
}

double _finite(double v, double fallback) => switch (v.isFinite) {
  true => v,
  false => fallback,
};

/// [items] with non-finite positions, rotations, scales and depths mended
/// (the same list when nothing needed mending).
///
/// Mirrors `wholeItems` in `src/lib/ink/recipes/sticker-board-ink.ts`.
List<StickerBoardItem> wholeItems(List<StickerBoardItem> items) {
  if (items.every(_whole)) return items;
  return [
    for (final (i, s) in items.indexed)
      switch (_whole(s)) {
        true => s,
        false => _mended(s, i),
      },
  ];
}

bool _whole(StickerBoardItem s) =>
    s.x.isFinite &&
    s.y.isFinite &&
    s.rot.isFinite &&
    s.scale.isFinite &&
    s.scale > 0 &&
    s.z.isFinite;

StickerBoardItem _mended(StickerBoardItem s, int i) {
  final scale = _finite(s.scale, 1);
  return StickerBoardItem(
    id: s.id,
    name: s.name,
    x: _finite(s.x, 160),
    y: _finite(s.y, 120),
    rot: _finite(s.rot, 0),
    scale: switch (scale > 0) {
      true => scale,
      false => 1,
    },
    z: _finite(s.z, i.toDouble()),
  );
}

/// Sizes of the selection handles, in pixels.
///
/// Mirrors `HANDLE` in `src/lib/ink/recipes/sticker-board-ink.ts`.
abstract final class StickerHandle {
  /// How far above the frame the rotate ring sits.
  static const double rotateUp = 30;

  /// Rotate ring radius.
  static const double ring = 8;

  /// How far out the scale square sits.
  static const double scaleOut = 6;

  /// Scale square size.
  static const double scaleSize = 13;

  /// Hit target size.
  static const double hit = 28;
}

/// Sticker board item frame params.
///
/// Mirrors `ItemFrameParams` in `src/lib/ink/recipes/sticker-board-ink.ts`.
final class ItemFrameParams {
  /// Params.
  const ItemFrameParams({required this.selected, required this.handles});

  final bool selected;

  /// Draws the rotate and scale handles when selected.
  final bool handles;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'selected': selected, 'handles': handles};
}

/// The frame around a sticker on a board: a lazy hover outline and focus
/// ring, and when selected a blue dashed frame with corner ticks and
/// rotate/scale handles.
///
/// Mirrors `stickerBoardItemRecipe` in
/// `src/lib/ink/recipes/sticker-board-ink.ts`.
final Recipe<ItemFrameParams> stickerBoardItemRecipe =
    defineRecipe<ItemFrameParams>(
      id: 'sticker-board-item',
      kind: 'frame',
      layers: const [LayerName.rest, LayerName.hover, LayerName.focus],
      lazy: const [LayerName.hover, LayerName.focus],
      pad: 40,
      draw: _draw,
    );

const StrokeOpts _simple = StrokeOpts(simple: true);

void _draw(Ink ink, Box size, ItemFrameParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  const out = 5.0;
  ctx
    ..lazy(
      LayerName.focus,
      (f) => focusRing(f, -out, -out, w + 2 * out, h + 2 * out, r: 6, gap: 3),
    )
    ..lazy(
      LayerName.hover,
      (f) => dashedBox(
        f,
        -out,
        -out,
        w + 2 * out,
        h + 2 * out,
        r: 7,
        pen: PenName.pencil,
        opts: const StrokeOpts(alpha: 0.55),
      ),
    );
  if (ctx.lazyOnly || !params.selected) return;
  ink.layer(LayerName.rest, () {
    const x0 = -out, y0 = -out;
    final x1 = w + out, y1 = h + out;
    final dash = clamp((2 * (x1 - x0 + y1 - y0)) / 46, 7, 16);
    dashedBox(
      ink,
      x0,
      y0,
      x1 - x0,
      y1 - y0,
      r: 7,
      pen: PenName.bluepencil,
      dash: dash,
      gap: dash * 0.72,
      opts: StrokeOpts(
        width: switch (ctx.calm) {
          true => 1,
          false => 1.5,
        },
      ),
    );
    const t = 7.0;
    void tick(double cx, double cy, double sx, double sy) {
      line(
        ink,
        cx - sx * 2,
        cy,
        cx + sx * t,
        cy,
        pen: PenName.blueFine,
        opts: _simple,
      );
      line(
        ink,
        cx,
        cy - sy * 2,
        cx,
        cy + sy * t,
        pen: PenName.blueFine,
        opts: _simple,
      );
    }

    tick(x0 - 1, y0 - 1, 1, 1);
    tick(x1 + 1, y0 - 1, -1, 1);
    tick(x0 - 1, y1 + 1, 1, -1);
    if (!params.handles) return;
    final cx = w / 2;
    line(
      ink,
      cx,
      y0 - 1,
      cx,
      y0 - StickerHandle.rotateUp + StickerHandle.ring,
      pen: PenName.blueFine,
      opts: _simple,
    );
    loop(
      ink,
      cx,
      y0 - StickerHandle.rotateUp,
      StickerHandle.ring,
      StickerHandle.ring,
      pen: PenName.blue,
      opts: const StrokeOpts(simple: true, width: 1.2),
    );
    final sx = x1 + StickerHandle.scaleOut - StickerHandle.scaleSize / 2;
    final sy = y1 + StickerHandle.scaleOut - StickerHandle.scaleSize / 2;
    ink.part(
      'fill',
      () => blobFill(
        ink,
        roundRectPoly(
          sx,
          sy,
          StickerHandle.scaleSize,
          StickerHandle.scaleSize,
          2.5,
        ),
        PaintKey.inkYou,
        alpha: 0.9,
      ),
    );
    line(
      ink,
      x1 - 1,
      y1 + 1,
      x1 - t,
      y1 + 1,
      pen: PenName.blueFine,
      opts: _simple,
    );
  });
}
