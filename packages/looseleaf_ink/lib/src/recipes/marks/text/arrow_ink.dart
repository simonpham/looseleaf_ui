import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:looseleaf_ink/src/recipes/marks/marks.dart';

/// Where an arrow points; `id` is the upstream name, ([ux], [uy]) its unit.
enum ArrowDirection {
  right('right', 1, 0),
  left('left', -1, 0),
  up('up', 0, -1),
  down('down', 0, 1),
  upRight('up-right', 1, -1),
  upLeft('up-left', -1, -1),
  downRight('down-right', 1, 1),
  downLeft('down-left', -1, 1);

  const ArrowDirection(this.id, this.ux, this.uy);

  /// The upstream name.
  final String id;
  final int ux;
  final int uy;

  /// The direction mirrored left to right.
  ArrowDirection get flipped => switch (this) {
    right => left,
    left => right,
    up => up,
    down => down,
    upRight => upLeft,
    upLeft => upRight,
    downRight => downLeft,
    downLeft => downRight,
  };
}

/// The arrow's shaft: straight, bowed or with a curl.
enum ArrowCurve { straight, curved, curl }

/// Which way a bowed arrow bends.
enum ArrowBend { up, down }

/// Arrow recipe params; with [dx] and [dy] the arrow is aimed from the
/// centre by that offset instead of spanning the box.
///
/// Mirrors `ArrowParams` in `src/lib/ink/recipes/arrow-ink.ts`.
final class ArrowParams {
  /// Params.
  const ArrowParams({
    required this.direction,
    required this.curve,
    required this.head,
    required this.tone,
    required this.weight,
    required this.bend,
    required this.mirror,
    this.dx,
    this.dy,
    this.animate,
  });

  final ArrowDirection direction;
  final ArrowCurve curve;
  final ArrowHead head;
  final MarkPen tone;
  final MarkWeight weight;
  final ArrowBend bend;

  /// Flips the direction in right-to-left text.
  final bool mirror;
  final double? dx;
  final double? dy;
  final bool? animate;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'direction': direction.id,
    'curve': curve.name,
    'head': head.name,
    'tone': tone.id,
    'weight': weight.name,
    'bend': bend.name,
    'mirror': mirror,
    'dx': ?dx,
    'dy': ?dy,
    'animate': ?animate,
  };
}

/// How far an aimed arrow reaches past its box.
///
/// Mirrors `arrowReach` in `src/lib/ink/recipes/arrow-ink.ts`.
double arrowReach({double? dx, double? dy}) {
  if (dx == null || dy == null) return 14;
  return JsMath.hypot(dx, dy).ceilToDouble() + 18;
}

/// A hand-drawn arrow in one of eight directions, or aimed by an offset.
///
/// Mirrors `arrowRecipe` in `src/lib/ink/recipes/arrow-ink.ts`.
final Recipe<ArrowParams> arrowRecipe = defineRecipe<ArrowParams>(
  id: 'arrow',
  kind: 'arrow',
  layers: const [LayerName.rest],
  padFor: (_, p, _) => arrowReach(dx: p.dx, dy: p.dy),
  draw: _draw,
);

void _draw(Ink ink, Box size, ArrowParams p, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final brush = p.weight == MarkWeight.brush;
  final mp = markPen(
    p.tone,
    switch (brush) {
      true => MarkWeight.regular,
      false => p.weight,
    },
    18,
  );
  final pen = mp.pen;
  final width = switch (brush) {
    true => mp.width * 1.3,
    false => mp.width,
  };
  final dir = switch (p.mirror && ctx.dir == Dir.rtl) {
    true => p.direction.flipped,
    false => p.direction,
  };
  final (x1, y1, x2, y2) = switch ((p.dx, p.dy)) {
    (final double ax, final double ay) => (
      w / 2,
      h / 2,
      w / 2 + ax,
      h / 2 + ay,
    ),
    _ => _spanning(dir, w, h),
  };
  final len = JsMath.hypot(x2 - x1, y2 - y1);
  final dx = x2 - x1, dy = y2 - y1;
  final up = switch (p.bend) {
    ArrowBend.up => -1,
    ArrowBend.down => 1,
  };
  final side = switch (dx != 0) {
    true => dx.sign * up,
    false => -dy.sign * up,
  };
  final bow = switch (p.curve) {
    ArrowCurve.straight => null,
    ArrowCurve.curved => side * 0.2,
    ArrowCurve.curl => side * 0.06,
  };
  final lines = arrowLines(
    ink.next('arrow'),
    x1,
    y1,
    x2,
    y2,
    head: p.head,
    curl: p.curve == ArrowCurve.curl,
    curve: bow,
    headLen: math.min(14, math.max(7, len * 0.22)),
  );
  ink.layer(LayerName.rest, () {
    if (p.animate ?? false) {
      revealMark(
        ink,
        id: markRevealId(ctx.seed, 'a'),
        lines: lines,
        pen: pen,
        box: size,
        pad: arrowReach(dx: p.dx, dy: p.dy) + 6,
        width: width,
        opts: const StrokeOpts(dry: structuralDry),
        revealWidth: 5,
      );
      return;
    }
    ink.lines(lines, pen, StrokeOpts(width: width, dry: structuralDry));
  });
}

(double, double, double, double) _spanning(
  ArrowDirection dir,
  double w,
  double h,
) {
  final m = math.min(4, math.min(w, h) * 0.12).toDouble();
  final ArrowDirection(:ux, :uy) = dir;
  final cx = w / 2, cy = h / 2;
  final x1 = switch (ux) {
    0 => cx,
    > 0 => m,
    _ => w - m,
  };
  final x2 = switch (ux) {
    0 => cx,
    > 0 => w - m,
    _ => m,
  };
  var y1 = switch (uy) {
    0 => cy,
    > 0 => m,
    _ => h - m,
  };
  final y2 = switch (uy) {
    0 => cy,
    < 0 => m,
    _ => h - m,
  };
  if (uy == 0) y1 += math.min(3, h * 0.08);
  return (x1, y1, x2, y2);
}
