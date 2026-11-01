import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Chat bubble variants; `id` is the upstream name (`primary` is
/// upstream's `default`).
enum BubbleVariant {
  primary('default'),
  secondary('secondary'),
  muted('muted'),
  tinted('tinted'),
  outline('outline'),
  ghost('ghost'),
  destructive('destructive');

  const BubbleVariant(this.id);

  /// The upstream name.
  final String id;
}

/// Which side the bubble's tail sits on, in reading order.
enum BubbleTail { start, end }

/// Whose pen draws the bubble: the other person's ink or your blue.
enum BubblePen { ink, you }

/// Bubble recipe params.
///
/// Mirrors `BubbleParams` in `src/lib/ink/recipes/bubble-ink.ts`.
final class BubbleParams {
  /// Params.
  const BubbleParams({
    required this.variant,
    required this.tail,
    this.pen,
    this.interactive,
  });

  final BubbleVariant variant;
  final BubbleTail tail;

  /// Defaults to [BubblePen.ink].
  final BubblePen? pen;

  /// Draws a hover drop line.
  final bool? interactive;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'variant': variant.id,
    'tail': tail.name,
    if (pen case final BubblePen p) 'pen': p.name,
    if (interactive case final bool i) 'interactive': i,
  };
}

/// The corner radius of a bubble [w] × [h].
///
/// Mirrors `bubbleRadius` in `src/lib/ink/recipes/bubble-ink.ts`.
double bubbleRadius(double w, double h) => clamp(math.min(w, h) * 0.42, 7, 16);

const double _tailCorner = 3.4;

List<Line> _cloudLines(
  Ink ink,
  double x,
  double y,
  double w,
  double h,
  bool left,
  bool cheap,
) {
  final rng = ink.next('cloud');
  double j() => rng.gauss(0, 0.55);
  final Pt tr = (x + w + j(), y + j());
  final Pt br = (x + w + j(), y + h + j());
  final Pt bl = (x + j(), y + h + j());
  final Pt tl = (x + j(), y + j());
  final t0 = rng.range(0.2, 0.42);
  final Pt s = (
    tl.x + (tr.x - tl.x) * t0,
    tl.y + (tr.y - tl.y) * t0 + j() * 0.4,
  );
  final run = math.min(w * 0.3, rng.range(8, 20));
  final Pt end = (s.x + run, s.y - rng.range(0.5, 2));
  double bulge(double len) => -clamp(len * rng.range(0.008, 0.024), 0.5, 3.4);
  const c = _tailCorner * 1.15;
  final vs = switch (left) {
    true => <Pt>[s, tr, br, (bl.x + c, bl.y), (bl.x, bl.y - c), tl, end],
    false => <Pt>[s, tr, (br.x, br.y - c), (br.x - c, br.y), bl, tl, end],
  };
  double dist(Pt a, Pt b) => JsMath.hypot(a.x - b.x, a.y - b.y);
  final bows = <double>[];
  for (var i = 0; i < vs.length - 1; i++) {
    final len = dist(vs[i], vs[i + 1]);
    if (len < c * 2.5) {
      bows.add(0);
      continue;
    }
    bows.add(bulge(len));
  }
  final rad = bubbleRadius(w, h);
  final so = StrokeOpts(
    speed: 1.02,
    wobble: 0.85,
    start: StrokeStart.pool,
    end: StrokeEnd.flick,
    simple: cheap,
  );
  return [Line(chain(vs, bows, rad, rng, 12), o: so)];
}

({List<Line> lines, List<Pt> wedge}) _tailLines(
  Ink ink,
  double x,
  double y,
  double w,
  double h,
  bool left,
) {
  final rng = ink.next('tail');
  final dir = switch (left) {
    true => -1.0,
    false => 1.0,
  };
  final bx = switch (left) {
    true => x,
    false => x + w,
  };
  final by = y + h;
  final reach = clamp(h * 0.2, 7, 10.5) + rng.range(-0.5, 1.2);
  final rise = clamp(h * 0.34, 11, 18);
  final Pt a = (bx - dir * 0.6, by - rise);
  final Pt tip = (bx + dir * reach, by + rng.range(0.6, 2.2));
  final Pt b = (bx - dir * clamp(w * 0.07, 7, 12), by + rng.range(-0.3, 0.9));
  const so = StrokeOpts(wobble: 0.6, simple: true, speed: 1.05);
  final out = seg(a.x, a.y, tip.x, tip.y, dir * rng.range(0.8, 2.2), 6);
  final back = seg(tip.x, tip.y, b.x, b.y, rng.range(-0.5, 0.6), 4);
  return (
    lines: [
      Line(
        out,
        o: so.merge(
          const StrokeOpts(start: StrokeStart.soft, end: StrokeEnd.soft),
        ),
      ),
      Line(
        back,
        o: so.merge(
          const StrokeOpts(start: StrokeStart.soft, end: StrokeEnd.flick),
        ),
      ),
    ],
    wedge: [
      a,
      ...out.sublist(1, out.length - 1),
      tip,
      ...back.sublist(1, back.length - 1),
      b,
      (bx - dir * 2, by - 6),
    ],
  );
}

({PaintKey? color, double alpha}) _fillOf(BubbleVariant variant) =>
    switch (variant) {
      BubbleVariant.primary => (color: PaintKey.inkYou, alpha: 0.96),
      BubbleVariant.secondary => (color: PaintKey.hi, alpha: 0.82),
      BubbleVariant.muted => (color: PaintKey.paperShade, alpha: 0.95),
      _ => (color: null, alpha: 0),
    };

/// A chat bubble: a hand-drawn cloud outline with a tail, filled per
/// variant, a hover drop line when interactive and a lazy focus ring.
///
/// Mirrors `bubbleRecipe` in `src/lib/ink/recipes/bubble-ink.ts`.
final Recipe<BubbleParams> bubbleRecipe = defineRecipe<BubbleParams>(
  id: 'bubble',
  kind: 'bubble',
  layers: const [LayerName.rest, LayerName.hover, LayerName.focus],
  lazy: const [LayerName.focus],
  pad: 12,
  draw: _drawBubble,
);

void _drawBubble(Ink ink, Box size, BubbleParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final variant = params.variant;
  ink.lean();
  final left = (params.tail == BubbleTail.start) == (ctx.dir == Dir.ltr);
  final r = bubbleRadius(w, h);
  ctx.lazy(LayerName.focus, (f) => focusRing(f, 0, 0, w, h, r: r));
  if (ctx.lazyOnly || variant == BubbleVariant.ghost) return;

  final felt = switch ((variant, params.pen ?? BubblePen.ink)) {
    (BubbleVariant.destructive, _) => PenName.redfelt,
    (_, BubblePen.you) => PenName.blue,
    _ => PenName.ink,
  };
  final calm = ctx.calm;
  final inset = clamp(h * 0.05, 1.6, 2.6);
  final body = roundRectPoly(inset, inset, w - 2 * inset, h - 2 * inset, r);
  final f = _fillOf(variant);
  final color = f.color;

  ink.layer(LayerName.rest, () {
    if (variant == BubbleVariant.outline ||
        variant == BubbleVariant.tinted ||
        variant == BubbleVariant.destructive) {
      ink.poly(Material.under, body, PaintKey.slip, 0.94);
    }
    _restFill(ink, variant, body, color, f.alpha, h, calm);
    final o = switch (variant == BubbleVariant.muted || calm) {
      true => const StrokeOpts(alpha: 0.85),
      false => const StrokeOpts(),
    };
    final cloudPen = switch ((calm, variant)) {
      (true, _) => PenName.pencilFine,
      (false, BubbleVariant.muted) => _fine(felt),
      _ => felt,
    };
    ink
      ..lines(
        _cloudLines(ink, 0, 0, w, h, left, ctx.tier == Tier.lo),
        cloudPen,
        o,
      )
      ..part('tail', () {
        final t = _tailLines(ink, 0, 0, w, h, left);
        final pale = switch (calm) {
          true => Material.wash,
          false => Material.felt,
        };
        _tailFill(ink, variant, t.wedge, color, f.alpha, calm, pale);
        ink.lines(
          t.lines,
          switch (calm) {
            true => PenName.pencilFine,
            false => felt,
          },
          o,
        );
      }, Material.top);
  });

  if (params.interactive ?? false) {
    ink.layer(LayerName.hover, () {
      if (calm) return;
      const d = 3.6;
      ink.lines(
        [
          Line(
            chain(
              [(r + d + 2, h + d), (w + d, h + d), (w + d, r + d + 2)],
              [0, 0],
              math.max(2.5, r),
              ink.next('drop'),
            ),
            o: ruler,
          ),
        ],
        PenName.inkFine,
        const StrokeOpts(width: 1.35),
      );
    });
  }
}

PenName _fine(PenName felt) => switch (felt) {
  PenName.redfelt => PenName.redfeltFine,
  PenName.blue => PenName.blueFine,
  _ => PenName.inkFine,
};

void _restFill(
  Ink ink,
  BubbleVariant variant,
  List<Pt> body,
  PaintKey? color,
  double alpha,
  double h,
  bool calm,
) {
  if (color != null) {
    ink.part('fill', () {
      if (color == PaintKey.paperShade) {
        return wash(ink, body, color, alpha: 0.95, material: Material.wash);
      }
      if (calm) {
        return wash(ink, body, color, alpha: 0.6, material: Material.wash);
      }
      final mis = clamp(h * 0.04, 1.4, 3);
      if (h < 30) return blobFill(ink, body, color, alpha: alpha, mis: mis);
      return bandFill(
        ink,
        body,
        color,
        alpha: alpha,
        passes: switch (variant) {
          BubbleVariant.primary => 2,
          _ => 1,
        },
        mis: mis,
        w: clamp(h * 0.2, 6.5, 9.5),
        ends: BandEnds.loose,
        overlap: 0.3,
      );
    });
    return;
  }
  if (variant == BubbleVariant.tinted) {
    ink.part(
      'fill',
      () => wash(
        ink,
        body,
        PaintKey.marker,
        alpha: switch (calm) {
          true => 0.24,
          false => 0.3,
        },
        material: Material.wash,
      ),
    );
    return;
  }
  if (variant == BubbleVariant.destructive) {
    ink.part('fill', () => blobFill(ink, body, PaintKey.red, alpha: 0.97));
  }
}

void _tailFill(
  Ink ink,
  BubbleVariant variant,
  List<Pt> wedge,
  PaintKey? color,
  double alpha,
  bool calm,
  Material pale,
) {
  if (color == PaintKey.paperShade) {
    wash(
      ink,
      wedge,
      PaintKey.paperShade,
      alpha: 0.95,
      inset: 0,
      material: pale,
    );
    return;
  }
  if (color != null && calm) {
    wash(ink, wedge, color, alpha: 0.6, inset: 0, material: Material.wash);
    return;
  }
  if (color != null) {
    blobFill(ink, wedge, color, alpha: alpha, mis: 1);
    return;
  }
  if (variant == BubbleVariant.tinted) {
    wash(ink, wedge, PaintKey.marker, alpha: 0.3, inset: 0, material: pale);
    return;
  }
  if (variant == BubbleVariant.outline ||
      variant == BubbleVariant.destructive) {
    ink.poly(
      switch (calm) {
        true => Material.under,
        false => Material.felt,
      },
      wedge,
      PaintKey.slip,
      0.94,
    );
  }
}

/// Bubble reactions recipe params.
///
/// Mirrors `BubbleReactionsParams` in `src/lib/ink/recipes/bubble-ink.ts`.
final class BubbleReactionsParams {
  /// Params.
  const BubbleReactionsParams({this.dashed});

  /// Adds a dashed inner pill.
  final bool? dashed;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    if (dashed case final bool d) 'dashed': d,
  };
}

/// The reactions pill under a bubble: a photo-white pill with a fine
/// pencil outline, optionally dashed inside.
///
/// Mirrors `bubbleReactionsRecipe` in `src/lib/ink/recipes/bubble-ink.ts`.
final Recipe<BubbleReactionsParams> bubbleReactionsRecipe =
    defineRecipe<BubbleReactionsParams>(
      id: 'bubble-reactions',
      kind: 'reactions',
      layers: const [LayerName.rest],
      pad: 6,
      draw: _drawReactions,
    );

void _drawReactions(
  Ink ink,
  Box size,
  BubbleReactionsParams params,
  RecipeContext ctx,
) {
  final Box(:w, :h) = size;
  final body = pillPoly(0.8, 0.8, w - 1.6, h - 1.6);
  ink.layer(LayerName.rest, () {
    ink.poly(Material.under, body, PaintKey.photo, 1);
    if (params.dashed ?? false) {
      dashedBox(
        ink,
        2.5,
        2.5,
        w - 5,
        h - 5,
        r: (h - 5) / 2,
        pen: PenName.pencil,
        opts: const StrokeOpts(alpha: 0.55),
      );
    }
    final d = pillPoly(0.4, 0.4, w - 0.8, h - 0.8);
    ink.lines(
      [
        Line(
          [...d, d[1]],
          o: StrokeOpts(
            simple: true,
            wobble: switch (ctx.calm) {
              true => 0.2,
              false => 0.5,
            },
            alpha: 0.7,
            width: 0.9,
          ),
        ),
      ],
      PenName.pencilFine,
    );
  });
}
