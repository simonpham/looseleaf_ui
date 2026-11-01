import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// shadcn's badge variants; `id` is the upstream name (`primary` is
/// upstream's `default`).
///
/// Mirrors `badgeVariantList` in `src/lib/ink/recipes/badge-ink.ts`.
enum BadgeVariant {
  primary('default'),
  secondary('secondary'),
  destructive('destructive'),
  outline('outline'),
  ghost('ghost'),
  link('link');

  const BadgeVariant(this.id);

  /// The upstream name.
  final String id;
}

/// Badge sizes; `id` is the upstream name (`regular` is upstream's
/// `default`), [labelPx] the label font size.
///
/// Mirrors `badgeSizeList` and `LABEL_PX` in
/// `src/lib/ink/recipes/badge-ink.ts`.
enum BadgeSize {
  sm('sm', 13),
  regular('default', 14),
  lg('lg', 16);

  const BadgeSize(this.id, this.labelPx);

  /// The upstream name.
  final String id;

  /// The label font size, used to place link underlines.
  final double labelPx;
}

/// The marker tone of a default badge.
///
/// Mirrors `badgeToneList` in `src/lib/ink/recipes/badge-ink.ts`.
enum BadgeTone {
  marker(PaintKey.marker),
  hi(PaintKey.hi),
  tangerine(PaintKey.tangerine),
  lemon(PaintKey.lemon),
  grass(PaintKey.grass),
  teal(PaintKey.teal),
  sky(PaintKey.sky),
  bubblegum(PaintKey.bubblegum);

  const BadgeTone(this.paint);

  /// The fill paint.
  final PaintKey paint;
}

/// Badge params. [tally] draws that many tally marks instead of a label.
///
/// Mirrors `BadgeParams` in `src/lib/ink/recipes/badge-ink.ts`.
final class BadgeParams {
  /// Params.
  const BadgeParams({
    required this.variant,
    required this.size,
    this.tone,
    this.tally,
    this.hoverable = false,
  });

  final BadgeVariant variant;
  final BadgeSize size;

  /// The fill tone, [BadgeTone.marker] when null.
  final BadgeTone? tone;
  final int? tally;

  /// Draws a `hover` layer.
  final bool hoverable;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'variant': variant.id,
    'size': size.id,
    'tone': ?tone?.name,
    'tally': ?tally,
    if (hoverable) 'hoverable': true,
  };
}

/// The height of a tally group in a badge [h] tall.
///
/// Mirrors `tallyHeight` in `src/lib/ink/recipes/badge-ink.ts`.
double badgeTallyHeight(double h) => JsMath.round(h * 0.62);

/// The width [count] tally marks take in a badge [h] tall.
///
/// Mirrors `tallyWidth` in `src/lib/ink/recipes/badge-ink.ts`.
double badgeTallyWidth(int count, double h) {
  final gh = badgeTallyHeight(h);
  final step = 0.26 * gh;
  final groupW = 1.05 * gh + 6;
  final full = count ~/ 5;
  final rest = count % 5;
  final last = switch (rest) {
    0 => 0.0,
    _ => (math.min(4, rest) - 1) * step + 1.4,
  };
  final gap = switch (rest) {
    0 => 6,
    _ => 0,
  };
  return math.max(0, (full * groupW - gap + last).ceilToDouble());
}

/// The badge: a marker pill, a highlighter swipe, a red pill or an outline,
/// optional tally marks, a lazy focus ring, and a hover layer when
/// hoverable.
///
/// Mirrors `badgeRecipe` in `src/lib/ink/recipes/badge-ink.ts`.
final Recipe<BadgeParams> badgeRecipe = defineRecipe<BadgeParams>(
  id: 'badge',
  kind: 'chip',
  layers: const [LayerName.rest, LayerName.hover, LayerName.focus],
  lazy: const [LayerName.focus],
  pad: 12,
  draw: _draw,
);

void _draw(Ink ink, Box size, BadgeParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final variant = params.variant;
  final r = h / 2;
  final calm = ctx.calm;
  ctx.lazy(LayerName.focus, (fink) => focusRing(fink, 0, 0, w, h, r: r));
  if (ctx.lazyOnly) return;
  final body = pillPoly(0.5, 0.5, w - 1, h - 1);
  final fillTone = (params.tone ?? BadgeTone.marker).paint;
  final labelBase = h / 2 + params.size.labelPx * 0.56;

  ink.layer(
    LayerName.rest,
    () => _rest(ink, variant, w, h, r, body, fillTone, calm, params.tally),
  );

  if (!params.hoverable) return;
  ink.layer(
    LayerName.hover,
    () => _hover(ink, variant, w, h, r, body, labelBase, calm),
  );
}

void _rest(
  Ink ink,
  BadgeVariant variant,
  double w,
  double h,
  double r,
  List<Pt> body,
  PaintKey fillTone,
  bool calm,
  int? tally,
) {
  final outlinePen = switch (calm) {
    true => PenName.pencilFine,
    false => PenName.inkFine,
  };
  switch (variant) {
    case BadgeVariant.primary:
      ink.part('fill', () => blobFill(ink, body, fillTone, alpha: 0.9));
      box(ink, 0, 0, w, h, pen: outlinePen, corner: r);
    case BadgeVariant.secondary:
      ink.part('fill', () {
        highlight(ink, 2, h * 0.08, w - 4, h * 0.84, k: 1);
        return InkOffset.zero;
      }, Material.hl);
    case BadgeVariant.destructive:
      ink.part('fill', () => blobFill(ink, body, PaintKey.red, alpha: 0.97));
      box(
        ink,
        0,
        0,
        w,
        h,
        pen: switch (calm) {
          true => PenName.redFine,
          false => PenName.redfelt,
        },
        corner: r,
        opts: const StrokeOpts(width: 0.8),
      );
    case BadgeVariant.outline:
      box(ink, 0, 0, w, h, pen: outlinePen, corner: r);
    case BadgeVariant.ghost || BadgeVariant.link:
      break;
  }
  if (tally case final int count when count != 0) {
    final gh = badgeTallyHeight(h);
    final tw = badgeTallyWidth(count, h);
    final t = tallyLines(
      ink.next('tally'),
      (w - tw) / 2 + 0.8,
      (h - gh) / 2,
      count,
      gh,
    );
    ink.lines(
      t.lines,
      switch (h < 24) {
        true => PenName.inkFine,
        false => PenName.ink,
      },
      const StrokeOpts(width: 1.05),
    );
  }
}

void _hover(
  Ink ink,
  BadgeVariant variant,
  double w,
  double h,
  double r,
  List<Pt> body,
  double labelBase,
  bool calm,
) {
  if (variant == BadgeVariant.ghost) {
    ink.part(
      'swipe',
      () => highlight(ink, 2, h * 0.08, w - 4, h * 0.84, k: 1),
      Material.hl,
    );
    return;
  }
  if (variant == BadgeVariant.link) {
    ink.part(
      'swipe',
      () => underline(
        ink,
        w * 0.08,
        labelBase,
        w * 0.84,
        pen: PenName.blueBrush,
        kind: UnderlineKind.single,
      ),
      Material.top,
    );
    return;
  }
  if (variant == BadgeVariant.outline) {
    wash(ink, body, PaintKey.hi, alpha: 0.5);
  }
  if (calm) {
    box(
      ink,
      1,
      1,
      w - 2,
      h - 2,
      pen: PenName.pencilFine,
      corner: r,
      loose: 0.6,
      opts: const StrokeOpts(alpha: 0.7, simple: true),
    );
    return;
  }
  final d = 3 + h / 40;
  ink.lines(
    [
      Line([(r * 0.8 + d, h + d), (w - r * 0.7 + d, h + d)], o: ruler),
    ],
    PenName.inkFine,
    const StrokeOpts(width: 1.3),
  );
}
