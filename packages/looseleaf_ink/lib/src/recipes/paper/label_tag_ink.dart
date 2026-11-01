import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/paper/paper.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:looseleaf_ink/src/recipes/paper/paper.dart';

/// The cut of a label tag.
///
/// Mirrors `TagShape` in `src/lib/ink/recipes/label-tag-ink.ts`.
enum TagShape { price, round, luggage }

/// The metal ring around a tag's hole.
///
/// Mirrors `LabelTagParams['eyelet']` in `src/lib/ink/recipes/label-tag-ink.ts`.
enum TagEyelet { brass, steel, none }

/// Label tag recipe params.
///
/// Mirrors `LabelTagParams` in `src/lib/ink/recipes/label-tag-ink.ts`.
final class LabelTagParams {
  /// Params.
  const LabelTagParams({
    required this.stock,
    required this.shape,
    required this.string,
    this.twine,
    required this.eyelet,
  });

  /// The paper stock.
  final StockName stock;

  /// The cut.
  final TagShape shape;

  /// How far the string loop reaches past the hole.
  final double string;

  /// The string's colour; natural twine when null.
  final Accent? twine;

  /// The eyelet.
  final TagEyelet eyelet;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'stock': stock.id,
    'shape': shape.name,
    'string': string,
    'twine': twine?.name ?? 'natural',
    'eyelet': eyelet.name,
  };
}

/// Label tag geometry: the hole radius, the hole's distance from the end,
/// the reinforcement patch radius and the corner chamfer.
///
/// Mirrors `TAG` in `src/lib/ink/recipes/label-tag-ink.ts`.
const ({double hole, double eyelet, double patch, double chamfer}) labelTag = (
  hole: 4.4,
  eyelet: 18,
  patch: 11.5,
  chamfer: 22,
);

/// The centre of a [shape] tag's hole.
///
/// Mirrors `tagHole` in `src/lib/ink/recipes/label-tag-ink.ts`.
Pt tagHole(double w, double h, TagShape shape) => switch (shape) {
  TagShape.luggage => (labelTag.eyelet + 2, h / 2),
  TagShape.round => (w / 2, labelTag.eyelet + 2),
  TagShape.price => (w / 2, labelTag.eyelet),
};

double _chamfer(double w, double h) =>
    math.min(labelTag.chamfer, math.min(w * 0.24, h * 0.3));

/// The outline of a [w]×[h] [shape] tag with a little jitter from [r],
/// flipped left to right when [mirror] is set.
///
/// Mirrors `tagPath` in `src/lib/ink/recipes/label-tag-ink.ts`.
String tagPath(
  double w,
  double h,
  TagShape shape,
  Rng r, [
  bool mirror = false,
]) {
  final c = _chamfer(w, h);
  const k = 3.0;
  double j() => r.gauss(0, 0.22);
  if (shape == TagShape.round) {
    final big = w / 2;
    return 'M0 ${num10(big)}A${num10(big)} ${num10(big)} 0 0 1 ${num10(w)} '
        '${num10(big)}V${num10(h - k)}Q${num10(w)} ${num10(h)} ${num10(w - k)} '
        '${num10(h)}H${num10(k)}Q0 ${num10(h)} 0 ${num10(h - k)}z';
  }
  final List<Pt> pts = switch (shape) {
    TagShape.luggage => [
      (c, j()),
      (w * 0.5, j()),
      (w - k, j()),
      (w + j(), k),
      (w + j(), h / 2),
      (w + j(), h - k),
      (w - k, h + j()),
      (w * 0.5, h + j()),
      (c, h + j()),
      (j(), h - c),
      (j(), h / 2),
      (j(), c),
    ],
    _ => [
      (c, j()),
      (w / 2, j()),
      (w - c, j()),
      (w + j(), c),
      (w + j(), h / 2),
      (w + j(), h - k),
      (w - k, h + j()),
      (w / 2, h + j()),
      (k, h + j()),
      (j(), h - k),
      (j(), h / 2),
      (j(), c),
    ],
  };
  return polyD(switch (mirror) {
    true => [for (final (x, y) in pts) (w - x, y)],
    false => pts,
  }, true);
}

/// A paper label tag on a loop of twine: the tag face, a reinforcement
/// patch, an optional eyelet (glinting on hover) and the cord passing
/// through the hole.
///
/// Mirrors `labelTagRecipe` in `src/lib/ink/recipes/label-tag-ink.ts`.
final Recipe<LabelTagParams> labelTagRecipe = defineRecipe<LabelTagParams>(
  id: 'label-tag-sheet',
  kind: 'sheet',
  layers: const [LayerName.rest, LayerName.hover],
  padFor: (size, params, ctx) => (params.string + 14).ceilToDouble(),
  draw: _drawTag,
);

void _drawTag(Ink ink, Box size, LabelTagParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final LabelTagParams(:shape, :string, :eyelet) = params;
  final r = ink.next('tag');
  final (hx, hy) = tagHole(w, h, shape);
  final horizontal = shape == TagShape.luggage;
  final flip = horizontal && ctx.dir == Dir.rtl;
  final body = tagPath(w, h, shape, r, flip);
  String mirrored(String m) => switch (flip) {
    true => '<g transform="${mirrorTransform(w)}">$m</g>',
    false => m,
  };
  ink.layer(LayerName.rest, () {
    final len = string;
    final (double, double) dir = switch (horizontal) {
      true => (-1, 0),
      false => (0, -1),
    };
    final (double, double) across = switch (horizontal) {
      true => (0, 1),
      false => (1, 0),
    };
    String at(double along, double side) =>
        '${num10(hx + dir.$1 * along + across.$1 * side)} '
        '${num10(hy + dir.$2 * along + across.$2 * side)}';
    final wob = r.gauss(0, 1.5);
    final back =
        'M${at(0, 1.2)}C${at(len * 0.35, 15 + wob)} '
        '${at(len * 1.02, 15 + wob)} ${at(len, 1)}';
    final front =
        'M${at(0, -1.2)}C${at(len * 0.35, -15 - wob)} '
        '${at(len * 1.02, -15 - wob)} ${at(len, -1)}';
    final colour = tok(params.twine?.name ?? 'orange-text');
    String cord(String d) =>
        pathTag(
          d,
          stroke: tok('ink'),
          sw: 3.8,
          op: 0.2,
          transform: 'translate(.8 1.4)',
        ) +
        pathTag(d, stroke: colour, sw: 3) +
        pathTag(
          d,
          stroke: tok('ink'),
          sw: 0.7,
          op: 0.55,
          extra: 'stroke-dasharray="1.2 2.6"',
        ) +
        pathTag(
          d,
          stroke: tok('photo'),
          sw: 0.8,
          op: 0.55,
          transform: 'translate(-.4 -.5)',
          extra: 'stroke-dasharray="1.6 2.2"',
        );
    final under = cord(back);
    final cut = switch (shape) {
      TagShape.round => w / 2,
      _ => _chamfer(w, h),
    };
    final inset = switch ((horizontal, flip)) {
      (false, _) => [cut, 1.0, 1.0, 1.0],
      (true, true) => [1.0, cut, 1.0, 1.0],
      (true, false) => [1.0, 1.0, 1.0, cut],
    };
    final holeX = switch (flip) {
      true => w - hx,
      false => hx,
    };
    final paper = paperFill(
      ink.seed,
      body + circleD(holeX, hy, labelTag.hole),
      stock: params.stock,
      evenodd: true,
      shadow: true,
      inset: inset,
    );
    final big = w / 2;
    final edge = switch (shape) {
      TagShape.round =>
        'M0.6 ${num10(big)}A${num10(big - 0.6)} ${num10(big - 0.6)} 0 0 1 '
            '${num10(w - 0.6)} ${num10(big)}',
      TagShape.luggage => 'M${num10(labelTag.chamfer)} 0.6H${num10(w - 4)}',
      TagShape.price =>
        'M${num10(labelTag.chamfer)} 0.6H${num10(w - labelTag.chamfer)}',
    };
    final patch =
        '${circleD(hx, hy, labelTag.patch)}${circleD(hx, hy, labelTag.hole)}';
    final s = StringBuffer(litEdge(edge, 0.7))
      ..write(
        pathTag(
          patch,
          fill: tok('ink'),
          op: 0.14,
          transform: 'translate(.6 1.1)',
          extra: 'fill-rule="evenodd"',
        ),
      )
      ..write(pathTag(patch, fill: tok('paper'), extra: 'fill-rule="evenodd"'))
      ..write(
        pathTag(
          circleD(hx, hy, labelTag.patch),
          stroke: tok('ink'),
          sw: 0.6,
          op: 0.28,
        ),
      )
      ..write(
        pathTag(
          circleD(hx, hy, labelTag.patch - 1.6),
          stroke: tok('paper-shade'),
          sw: 0.7,
          op: 0.8,
        ),
      );
    if (eyelet != TagEyelet.none) s.write(_eyelet(eyelet, hx, hy));
    s.write(cord(front));
    ink
      ..raw(mirrored(under) + paper + mirrored('$s'), Material.under)
      ..grow(BBox(-string - 6, -string - 6, w + string + 6, h + 6));
  });
  ink.layer(LayerName.hover, () {
    if (eyelet == TagEyelet.none) return;
    final gl = pathTag(
      'M${num10(hx - 3)} ${num10(hy - 6)}l2 -2.5'
      'M${num10(hx + 4)} ${num10(hy - 7)}l-1 -2.8',
      stroke: tok('photo'),
      sw: 1.2,
      op: 0.95,
    );
    ink.raw(mirrored(gl), Material.top);
  });
}

String _eyelet(TagEyelet eyelet, double hx, double hy) {
  final metal = switch (eyelet) {
    TagEyelet.brass => tok('hi-deep'),
    _ => tok('pencil-mark'),
  };
  const hole = 4.4;
  final ring = '${circleD(hx, hy, hole + 2.6)}${circleD(hx, hy, hole - 0.4)}';
  return pathTag(
        ring,
        fill: tok('ink'),
        op: 0.2,
        transform: 'translate(.7 1.2)',
        extra: 'fill-rule="evenodd"',
      ) +
      pathTag(ring, fill: metal, extra: 'fill-rule="evenodd"') +
      pathTag(
        'M${num10(hx - hole - 1.6)} ${num10(hy - 0.5)}A${num10(hole + 1.6)} '
        '${num10(hole + 1.6)} 0 0 1 ${num10(hx + 0.5)} ${num10(hy - hole - 1.6)}',
        stroke: tok('photo'),
        sw: 1.1,
        op: 0.9,
      ) +
      pathTag(
        'M${num10(hx + hole + 1.4)} ${num10(hy + 0.5)}A${num10(hole + 1.6)} '
        '${num10(hole + 1.6)} 0 0 1 ${num10(hx - 0.5)} ${num10(hy + hole + 1.6)}',
        stroke: tok('ink'),
        sw: 1,
        op: 0.35,
      );
}
