import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/paper/paper.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Paper sheet recipe params.
///
/// Mirrors `SheetParams` in `src/lib/ink/recipes/paper-ink.ts`.
final class SheetParams {
  /// Params.
  const SheetParams({
    required this.stock,
    required this.edge,
    this.chamfer,
    this.shadow,
    this.noShadow = false,
  });

  /// The paper stock.
  final StockName stock;

  /// The edge of each side.
  final EdgeSpec edge;

  /// The size of a curled bottom-right corner, if any.
  final double? chamfer;

  /// The shadow; the stock's when null.
  final SheetShadowKind? shadow;

  /// No shadow at all (upstream `shadow: 'none'`); wins over [shadow].
  final bool noShadow;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'stock': stock.id,
    'edge': edgeJson(edge),
    if (chamfer case final double c) 'chamfer': c,
    if (noShadow) 'shadow': 'none',
    if (shadow case final SheetShadowKind s when !noShadow) 'shadow': s.name,
  };
}

/// An [EdgeSpec] as upstream writes it: the kind when every side matches,
/// else an object of the sides that are not `cut`.
Object edgeJson(EdgeSpec edge) {
  final sides = edgeSides(edge);
  if (sides.every((k) => k == sides.first)) return sides.first.name;
  return {
    for (final side in SheetSide.values)
      if (edge.of(side) != EdgeKind.cut) side.name: edge.of(side).name,
  };
}

/// The padding a sheet with [edge] needs.
///
/// Mirrors `sheetPad` in `src/lib/ink/recipes/paper-ink.ts`.
double sheetPad(EdgeSpec edge) => (edgeInset(edge) * 0.4).ceilToDouble() + 3;

String _railPath(List<Pt> pts, int from, int to, [double gap = 2.4]) {
  final d = StringBuffer();
  var lx = -1e9, ly = -1e9;
  for (var i = from; i < to; i++) {
    final (x, y) = pts[i];
    if (JsMath.hypot(x - lx, y - ly) < gap && i != to - 1) continue;
    final lead = switch (d.isEmpty) {
      true => 'M',
      false => 'L',
    };
    d.write('$lead${num10(x)} ${num10(y)}');
    lx = x;
    ly = y;
  }
  return '$d';
}

/// Draws a [w]×[h] sheet into the rest layer: the fibre rim, contact
/// shadow, face mark, edge stroke, lit torn edges, gum strip, napkin
/// emboss and curled corner. Returns the outline.
///
/// Mirrors `drawSheet` in `src/lib/ink/recipes/paper-ink.ts`.
Outline drawSheet(Ink ink, double w, double h, SheetParams p) {
  final stock = stockOf(p.stock);
  final r = ink.next('sheet');
  final outline = sheetOutline(
    r,
    w,
    h,
    p.edge,
    amp: ink.knobs.wobble,
    chamfer: p.chamfer,
  );
  final body = outlinePath(outline, OutlineRing.body, ink.tier);
  final gid = 'll-sh${ink.seed.toRadixString(36)}';
  final shadow = switch (p.noShadow) {
    true => null,
    false => p.shadow ?? stock.shadow,
  };
  final contact = switch (shadow) {
    final SheetShadowKind k => contactShadow(k),
    null => null,
  };
  final casts = shadow != null && farShadow(shadow) != 'none';
  ink.layer(LayerName.rest, () {
    final s = StringBuffer();
    if (outline.fibrous && outline.reach > 0.25) {
      s.write(
        '<path d="${outlinePath(outline, OutlineRing.rim, ink.tier)}" '
        'fill="${tok(stock.base)}" fill-opacity=".42"/>',
      );
    }
    if (contact case (:final dy, :final a)) {
      s.write(
        '<use href="#$gid" transform="translate(0 ${num10(dy)})" '
        'fill="var(--ll-umber)" fill-opacity="${js(a)}" '
        'opacity="var(--ll-shadow-k)"/>',
      );
    }
    s
      ..write(
        faceMark(
          FaceSpec(
            d: body,
            stock: p.stock,
            seed: ink.seed,
            cast: switch ((casts, shadow)) {
              (true, final SheetShadowKind k) => FaceCast(
                kind: k,
                inset: sideInsets(outline, w, h, p.chamfer ?? 0),
              ),
              _ => null,
            },
          ),
        ),
      )
      ..write('<defs><path id="$gid" d="$body"/></defs>');
    final edgeOp = switch (outline.fibrous) {
      true => 0.16,
      false => 0.13,
    };
    s.write(
      '<use href="#$gid" fill="none" stroke="${tok('ink')}" '
      'stroke-opacity="${js(edgeOp)}" stroke-width=".6"/>',
    );
    if (outline.fibrous) {
      final rim =
          'fill="none" stroke="${tok('photo')}" stroke-opacity=".78" '
          'stroke-width="1.1" stroke-linecap="round" stroke-linejoin="round" '
          'transform="translate(0 -.6)"';
      final torn = [
        for (final q in outline.sides)
          if (q.kind == EdgeKind.torn || q.kind == EdgeKind.deckle) q,
      ];
      final whole = torn.length == 4 || outline.sides.isEmpty;
      s.write(switch (whole) {
        true => '<use href="#$gid" $rim/>',
        false =>
          '<path d="${torn.map((q) => _railPath(outline.pts, q.from, q.to)).join()}" $rim/>',
      });
    }
    if (stock.gum) {
      final gh = math.min(22, h * 0.2);
      s.write(
        '<linearGradient id="${gid}g" x1="0" y1="0" x2="0" y2="1">'
        '<stop offset="0" stop-color="${tok('orange-text')}" stop-opacity=".1"/>'
        '<stop offset="1" stop-color="${tok('orange-text')}" stop-opacity="0"/>'
        '</linearGradient><rect x=".6" y=".6" width="${num10(w - 1.2)}" '
        'height="${num10(gh.toDouble())}" fill="url(#${gid}g)"/>',
      );
    }
    if (p.stock == StockName.napkin) s.write(_napkinEmboss(w, h));
    if (p.chamfer case final double c when c != 0) {
      final curl = curlMarkup(
        ink.next('curl'),
        '${gid}f',
        c,
        PaintKey.byId(stock.base) ?? PaintKey.stickyYellow,
      );
      s.write(
        '<g transform="translate(${num10(w - c)} ${num10(h - c)})">$curl</g>',
      );
    }
    ink
      ..raw('$s', Material.under)
      ..grow(BBox(-2, -2, w + 2, h + 2));
  });
  return outline;
}

String _napkinEmboss(double w, double h) {
  final inset = math.max(8, math.min(26, math.min(w, h) * 0.058)).toDouble();
  final rr = math.max(4, inset * 0.5).toDouble();
  final rect =
      'M${num10(inset + rr)} ${num10(inset)}H${num10(w - inset - rr)}'
      'a${num10(rr)} ${num10(rr)} 0 0 1 ${num10(rr)} ${num10(rr)}'
      'V${num10(h - inset - rr)}'
      'a${num10(rr)} ${num10(rr)} 0 0 1 ${num10(-rr)} ${num10(rr)}'
      'H${num10(inset + rr)}'
      'a${num10(rr)} ${num10(rr)} 0 0 1 ${num10(-rr)} ${num10(-rr)}'
      'V${num10(inset + rr)}'
      'a${num10(rr)} ${num10(rr)} 0 0 1 ${num10(rr)} ${num10(-rr)}z';
  String groove(
    double dx,
    double dy,
    String c,
    double op,
    double sw, [
    String extra = '',
  ]) =>
      '<path d="$rect" transform="translate(${js(dx)} ${js(dy)})" fill="none" '
      'stroke="$c" stroke-opacity="${js(op)}" stroke-width="${js(sw)}" '
      'stroke-linecap="round" $extra/>';
  return groove(0.8, 0.8, tok('ink'), 0.11, 2, 'stroke-dasharray="0 5.6"') +
      groove(-0.7, -0.7, tok('photo'), 0.95, 2, 'stroke-dasharray="0 5.6"') +
      groove(0.6, 0.6, tok('ink'), 0.08, 0.9) +
      groove(-0.5, -0.5, tok('photo'), 0.8, 0.9);
}

/// A paper sheet: stock face, edges and shadow in the rest layer.
///
/// Mirrors `sheetRecipe` in `src/lib/ink/recipes/paper-ink.ts`.
final Recipe<SheetParams> sheetRecipe = defineRecipe<SheetParams>(
  id: 'paper-sheet',
  kind: 'sheet',
  layers: const [LayerName.rest],
  padFor: (size, params, ctx) => sheetPad(params.edge),
  draw: (ink, size, params, ctx) => drawSheet(ink, size.w, size.h, params),
);

/// A [w]×[h] sheet drawn on its own, with its faces rendered as plain SVG
/// ([tiles] and [faceId] as in [renderFaces]).
///
/// Mirrors `paperSheet` in `src/lib/ink/recipes/paper-ink.ts`.
InkResult paperSheet(
  Object seed,
  double w,
  double h,
  SheetParams p, {
  Tier? tier,
  bool? calm,
  bool tiles = false,
  String? faceId,
}) {
  final ink = Ink(seed, tier: tier, calm: calm);
  drawSheet(ink, w, h, p);
  final res = ink.toSvg(w: w, h: h, pad: sheetPad(p.edge));
  String faces(String v) => renderFaces(v, tiles: tiles, id: faceId);
  return InkResult(
    svg: faces(res.svg),
    w: res.w,
    h: res.h,
    pad: res.pad,
    layers: res.layers,
    parts: {
      for (final MapEntry(:key, :value) in res.parts.entries) key: faces(value),
    },
    bbox: res.bbox,
  );
}

/// The paper hand-ruled lines go on.
///
/// Mirrors `HandRulesParams['paper']` in `src/lib/ink/recipes/paper-ink.ts`.
enum HandRulesPaper { ruled, pad }

/// Hand-ruled lines recipe params.
///
/// Mirrors `HandRulesParams` in `src/lib/ink/recipes/paper-ink.ts`.
final class HandRulesParams {
  /// Params.
  const HandRulesParams({this.paper});

  /// The paper; blue rules unless [HandRulesPaper.pad].
  final HandRulesPaper? paper;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    if (paper case final HandRulesPaper p) 'paper': p.name,
  };
}

/// Ruled lines drawn by hand with a ruler: blue rules (faint you-ink on a
/// pad) and a red margin.
///
/// Mirrors `handRulesRecipe` in `src/lib/ink/recipes/paper-ink.ts`.
final Recipe<HandRulesParams> handRulesRecipe = defineRecipe<HandRulesParams>(
  id: 'paper-rules-hand',
  kind: 'rules',
  layers: const [LayerName.rest],
  pad: 2,
  draw: (ink, size, params, ctx) {
    final Box(:w, :h) = size;
    final g = ruleGeometry(RuleName.ruled, calm: ctx.calm);
    final pad = params.paper == HandRulesPaper.pad;
    final (color, alpha) = switch (pad) {
      true => (PaintKey.inkYou, 0.42),
      false => (PaintKey.ruleBlue, 0.85),
    };
    ink.layer(LayerName.rest, () {
      for (var y = g.first - g.offset; y < h - 4; y += g.pitch) {
        ink.stroke(
          [(-1, y), (w + 1, y)],
          PenName.pencilFine,
          ruler.merge(
            StrokeOpts(simple: true, color: color, alpha: alpha, width: 0.9),
          ),
        );
      }
      if (g.margin case final double m) {
        ink.stroke(
          [(m, -1), (m, h + 1)],
          PenName.pencilFine,
          ruler.merge(
            const StrokeOpts(
              simple: true,
              color: PaintKey.ruleRed,
              alpha: 0.9,
              width: 1.1,
            ),
          ),
        );
      }
    });
  },
);
