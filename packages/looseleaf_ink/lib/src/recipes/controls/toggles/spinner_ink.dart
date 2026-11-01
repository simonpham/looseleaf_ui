import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/toggles/draw_on_ink.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// shadcn's spinner variants (upstream `spinnerVariantList`).
enum SpinnerVariant { scribble, loops, write }

/// The mark a spinner draws on: an inward spiral or a row of loops.
enum SpinnerShape { spiral, loops }

List<Line> _loopLines(Rng rng, double w, double h, int loops) {
  final r = h * 0.4;
  final total = loops * tau;
  final k = math.min(r * 0.75, (w - 2 * r) / total);
  final count = math.max(30, loops * 16);
  final ph = rng.range(-0.3, 0.3);
  final pts = <Pt>[];
  for (var i = 0; i <= count; i++) {
    final th = (i / count) * total;
    pts.add((
      r + k * th - r * 0.9 * JsMath.sin(th + ph),
      h / 2 -
          r * JsMath.cos(th + ph) * (1 + 0.04 * JsMath.sin(th * 0.7)) +
          rng.gauss(0, 0.06),
    ));
  }
  return [
    Line(
      pts,
      o: const StrokeOpts(
        start: StrokeStart.soft,
        end: StrokeEnd.flick,
        wobble: 0.5,
        speed: 1,
      ),
    ),
  ];
}

/// A spinner mark [px] wide, drawn on through a reveal mask, in
/// `currentColor`. [shape] defaults to a spiral; loops are [w] × [h]
/// (`px` × `0.3 px` by default).
///
/// Mirrors `spinnerMark` in `src/lib/ink/recipes/spinner-ink.ts`.
InkResult spinnerMark(
  String seed,
  double px, {
  SpinnerShape? shape,
  double? w,
  double? h,
  Tier? tier,
  bool? calm,
}) {
  final kind = shape ?? SpinnerShape.spiral;
  final spiral = kind == SpinnerShape.spiral;
  final bw = switch (spiral) {
    true => px,
    false => w ?? px,
  };
  final bh = switch (spiral) {
    true => px,
    false => h ?? px * 0.3,
  };
  final ink = Ink(seed, tier: tier, calm: calm);
  final rng = ink.next('spinner');
  final id = revealId('$seed|spinner', 'sp');
  final width = clamp(px / 20, 0.9, 1.45);
  final lines = switch (spiral) {
    true => spiralLines(
      rng,
      bw / 2,
      bh / 2,
      bw * 0.4,
      turns: switch (px) {
        < 20 => 1.85,
        < 40 => 2.1,
        _ => 2.6,
      },
      steps: switch (px < 20) {
        true => 22,
        false => 34,
      },
      shrink: 0.86,
    ),
    false => _loopLines(
      rng,
      bw,
      bh,
      math.max(3, JsMath.roundInt(bw / (bh * 1.5))),
    ),
  };
  ink
    ..layer(
      LayerName.rest,
      () => reveal(
        ink,
        id: id,
        lines: lines,
        pen: PenName.ink,
        box: Box(bw, bh),
        width: width,
        revealWidth: math.max(3.4, math.min(bw, bh) * 0.34),
      ),
    )
    ..grow(BBox(-1, -1, bw + 1, bh + 1));
  return _recolour(ink.toSvg(w: bw, h: bh, pad: 3));
}

InkResult _recolour(InkResult res) {
  String swap(String s) => s.replaceAll('var(--ll-ink)', 'currentColor');
  return InkResult(
    svg: swap(res.svg),
    w: res.w,
    h: res.h,
    pad: res.pad,
    layers: res.layers,
    parts: {
      for (final MapEntry(:key, :value) in res.parts.entries) key: swap(value),
    },
    bbox: res.bbox,
  );
}
