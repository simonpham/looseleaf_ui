import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// The direction of a resizable handle's seam.
enum ResizableLine { vertical, horizontal }

/// Resizable handle params.
///
/// Mirrors `ResizableParams` in `src/lib/ink/recipes/resizable-ink.ts`.
final class ResizableParams {
  /// Params.
  const ResizableParams({
    required this.line,
    required this.grip,
    this.disabled = false,
  });

  /// The seam's direction.
  final ResizableLine line;

  /// Draws a grip tab in the middle.
  final bool grip;
  final bool disabled;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'line': line.name,
    'grip': grip,
    if (disabled) 'disabled': true,
  };
}

const double _tabLong = 32;
const double _tabShort = 18;

List<Line> _stitches(double len, double across, bool vertical, Pt? gap) {
  final c = across / 2;
  Pt at(double t) => switch (vertical) {
    true => (c, t),
    false => (t, c),
  };
  const dash = 9.0, space = 5.2;
  final count = math.max(
    1,
    JsMath.roundInt((len - 6 + space) / (dash + space)),
  );
  final step = (len - 6 + space) / count;
  final lines = <Line>[];
  final opts = ruler.merge(const StrokeOpts(simple: true));
  for (var i = 0; i < count; i++) {
    final y = 3 + i * step, y1 = y + step - space;
    if (gap == null || y1 < gap.x || y > gap.y) {
      lines.add(Line([at(y), at(y1)], o: opts));
    }
  }
  return lines;
}

/// A resizable panel seam: dashed pencil stitches with an optional grip
/// tab, darker on hover, a blue rule while dragged.
///
/// Mirrors `resizableRecipe` in `src/lib/ink/recipes/resizable-ink.ts`.
final Recipe<ResizableParams> resizableRecipe = defineRecipe<ResizableParams>(
  id: 'resizable',
  kind: 'seam',
  layers: const [
    LayerName.rest,
    LayerName.hover,
    LayerName.pressed,
    LayerName.focus,
    LayerName.disabled,
  ],
  lazy: const [LayerName.focus],
  pad: 12,
  draw: _draw,
);

void _draw(Ink ink, Box size, ResizableParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final grip = params.grip;
  final vertical = params.line == ResizableLine.vertical;
  final len = switch (vertical) {
    true => h,
    false => w,
  };
  final across = switch (vertical) {
    true => w,
    false => h,
  };
  final mid = len / 2;
  final tabLen = switch (grip) {
    true => _tabLong,
    false => 0.0,
  };
  final Pt? gap = switch (grip) {
    true => (mid - tabLen / 2 - 2, mid + tabLen / 2 + 2),
    false => null,
  };
  final cx = w / 2, cy = h / 2;
  final tabW = switch (vertical) {
    true => _tabShort,
    false => _tabLong,
  };
  final tabH = switch (vertical) {
    true => _tabLong,
    false => _tabShort,
  };

  if (params.disabled) {
    if (ctx.lazyOnly) return;
    ink.layer(
      LayerName.disabled,
      () => ink.lines(
        _stitches(len, across, vertical, null),
        PenName.pencilFine,
        const StrokeOpts(alpha: 0.4),
      ),
    );
    return;
  }

  final ringW = switch (vertical) {
    true => math.max(across, _tabShort),
    false => _tabLong + 4,
  };
  final ringH = switch (vertical) {
    true => _tabLong + 4,
    false => math.max(across, _tabShort),
  };
  ctx.lazy(
    LayerName.focus,
    (f) => focusRing(f, cx - ringW / 2, cy - ringH / 2, ringW, ringH, r: 4),
  );
  if (ctx.lazyOnly) return;

  final geometry = _stitches(len, across, vertical, gap);
  final calm = ctx.calm;
  void tab() {
    final x = cx - tabW / 2, y = cy - tabH / 2;
    ink.poly(
      Material.under,
      roundRectPoly(x + 0.8, y + 0.8, tabW - 1.6, tabH - 1.6, 3),
      PaintKey.slip,
      0.98,
    );
    box(
      ink,
      x,
      y,
      tabW,
      tabH,
      pen: switch (calm) {
        true => PenName.pencilFine,
        false => PenName.inkFine,
      },
      corner: 3,
    );
  }

  ink
    ..layer(LayerName.rest, () {
      ink.lines(
        geometry,
        switch (calm) {
          true => PenName.pencilFine,
          false => PenName.pencil,
        },
        StrokeOpts(
          alpha: 1,
          width: switch (calm) {
            true => 1.25,
            false => 1.3,
          },
        ),
      );
      if (grip) tab();
    })
    ..layer(LayerName.hover, () {
      ink.lines(
        geometry,
        PenName.inkFine,
        const StrokeOpts(alpha: 0.85, width: 1.3),
      );
      if (grip && !calm) {
        wash(
          ink,
          roundRectPoly(cx - tabW / 2, cy - tabH / 2, tabW, tabH, 3),
          PaintKey.hi,
          alpha: 0.6,
        );
      }
    })
    ..layer(LayerName.pressed, () {
      final Pt a = switch (vertical) {
        true => (cx, 1),
        false => (1, cy),
      };
      final Pt b = switch (vertical) {
        true => (cx, len - 1),
        false => (len - 1, cy),
      };
      ink.stroke(
        [a, b],
        PenName.blue,
        ruler.merge(const StrokeOpts(width: 1.15)),
      );
    });
}
