import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/paper/paper.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:looseleaf_ink/src/recipes/paper/paper.dart';

/// An envelope's front: the paper, the flap seams, an airmail border, a
/// postage stamp and a postmark, mirrored in right-to-left layouts.
///
/// Mirrors `envelopeFrontRecipe` in `src/lib/ink/recipes/envelope-ink.ts`.
final Recipe<EnvelopeFrontParams> envelopeFrontRecipe =
    defineRecipe<EnvelopeFrontParams>(
      id: 'envelope-front',
      kind: 'envelope',
      layers: const [LayerName.rest],
      pad: 8,
      draw: _drawFront,
    );

void _drawFront(
  Ink ink,
  Box size,
  EnvelopeFrontParams params,
  RecipeContext ctx,
) {
  final Box(:w, :h) = size;
  final r = ink.next('front');
  final rect = 'M0 0H${num10(w)}V${num10(h)}H0z';
  ink.layer(LayerName.rest, () {
    final s = StringBuffer(
      paperFill(ink.seed, rect, stock: params.stock, id: 'f'),
    )..write(litEdge('M1.5 0.6H${num10(w - 1.5)}', 0.7));
    final Pt apex = (w / 2 + r.gauss(0, 1), h * 0.5);
    for (final ((cx, cy), k) in [((0.0, h), 1), ((w, h), -1)]) {
      final mid = (
        (cx + apex.x) / 2 + r.gauss(0, 0.6),
        (cy + apex.y) / 2 + r.gauss(0, 0.6),
      );
      final d = polyD(spline([(cx, cy), mid, apex], 4));
      s
        ..write(pathTag(d, stroke: tok('ink'), sw: 0.8, op: 0.2))
        ..write(
          pathTag(
            d,
            stroke: tok('photo'),
            sw: 0.9,
            op: 0.6,
            transform: 'translate(${num10(k * 0.8)} -0.9)',
          ),
        );
    }
    if (params.airmail) {
      s.write(_airmail(ink, w, h, rect));
    }
    final inner = StringBuffer();
    final (:sw, :sh, :x, :y) = stampBox(w);
    if (params.stamp case final Accent stamp) {
      inner.write(_stamp(stamp, x, y, sw, sh));
    }
    if (params.postmark) {
      final pr = math.max(13, sw * 0.42).toDouble();
      final cx = x - pr * 0.4 + r.gauss(0, 1.2),
          cy = y + sh * 0.5 + r.gauss(0, 1.2);
      inner
        ..write(
          pathTag(
            circleD(cx, cy, pr),
            stroke: tok('ink-you'),
            sw: 1.3,
            op: 0.5,
          ),
        )
        ..write(
          pathTag(
            circleD(cx, cy, pr - 3.6),
            stroke: tok('ink-you'),
            sw: 0.8,
            op: 0.42,
          ),
        )
        ..write(
          pathTag(
            'M${num10(cx - pr * 0.6)} ${num10(cy)}h${num10(pr * 1.2)}'
            'M${num10(cx - pr * 0.5)} ${num10(cy - 4)}h${num10(pr)}'
            'M${num10(cx - pr * 0.5)} ${num10(cy + 4)}h${num10(pr)}',
            stroke: tok('ink-you'),
            sw: 0.7,
            op: 0.4,
          ),
        );
      final wave = StringBuffer();
      final x0 = cx + pr + 1;
      final ripples = math.max(2, math.min(5, ((w - 5 - x0) / 8).floor()));
      for (var k = 0; k < 4; k++) {
        final yy = cy - 9 + k * 6;
        wave.write('M${num10(x0)} ${num10(yy)}');
        for (var j = 0; j < ripples; j++) {
          final dy = switch (j.isOdd) {
            true => -3,
            false => 3,
          };
          wave.write('q${num10(4)} $dy ${num10(8)} 0');
        }
      }
      inner.write(
        pathTag('$wave', stroke: tok('ink-you'), sw: 1.05, op: 0.42),
      );
    }
    s.write(switch (ctx.dir) {
      Dir.rtl => mirrorX(w, '$inner'),
      Dir.ltr => '$inner',
    });
    ink
      ..raw('$s', Material.under)
      ..grow(BBox(-2, -2, w + 2, h + 2));
  });
}

String _airmail(Ink ink, double w, double h, String rect) {
  final bw = math.max(6, math.min(9, h * 0.04)).toDouble();
  const step = 13.0;
  final cid = 'll-am${ink.seed.toRadixString(36)}';
  final stripes = StringBuffer();
  for (var x = -h; x < w + h; x += step) {
    final c = switch (JsMath.round(x / step).remainder(2) != 0) {
      true => tok('sky'),
      false => tok('tomato'),
    };
    stripes.write(
      '<path d="M${num10(x)} ${num10(h)}L${num10(x + h)} 0" stroke="$c" '
      'stroke-width="${num10(step / 2 + 0.6)}" fill="none"/>',
    );
  }
  return '<clipPath id="$cid"><path clip-rule="evenodd" d="${rect}M${num10(bw)} '
      '${num10(bw)}V${num10(h - bw)}H${num10(w - bw)}V${num10(bw)}z"/></clipPath>'
      '<g clip-path="url(#$cid)" opacity=".92">$stripes</g>'
      '${pathTag('M${num10(bw)} ${num10(bw)}H${num10(w - bw)}V${num10(h - bw)}H${num10(bw)}z', stroke: tok('ink'), sw: 0.6, op: 0.22)}';
}

String _stamp(Accent stamp, double x, double y, double sw, double sh) {
  final d = perfRectD(x, y, sw, sh, 2.1, 7);
  final px = x + 4.5, py = y + 4.5, pw = sw - 9, ph = sh - 9;
  final face =
      'M${num10(px)} ${num10(py)}h${num10(pw)}v${num10(ph)}h${num10(-pw)}z';
  return pathTag(d, fill: tok('ink'), op: 0.2, transform: 'translate(.7 1.3)') +
      pathTag(d, fill: tok('photo')) +
      pathTag(d, stroke: tok('ink'), sw: 0.6, op: 0.3) +
      pathTag(face, fill: tok(stamp.name), op: 0.85) +
      pathTag(
        circleD(px + pw * 0.66, py + ph * 0.3, pw * 0.14),
        fill: tok('lemon'),
      ) +
      pathTag(
        'M${num10(px)} ${num10(py + ph)}V${num10(py + ph * 0.7)}'
        'Q${num10(px + pw * 0.3)} ${num10(py + ph * 0.5)} '
        '${num10(px + pw * 0.6)} ${num10(py + ph * 0.72)}'
        'T${num10(px + pw)} ${num10(py + ph * 0.66)}V${num10(py + ph)}z',
        fill: tok('ink'),
        op: 0.28,
      ) +
      pathTag(face, stroke: tok('ink'), sw: 0.6, op: 0.35);
}
