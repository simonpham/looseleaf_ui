import 'dart:math' as math;

import 'package:looseleaf_ink/src/art/art.dart';
import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/paper/paper.dart';

List<Pt> _waxOutline(double cx, double cy, double big, Rng rng) {
  final p1 = rng.range(0, tau), p2 = rng.range(0, tau), p3 = rng.range(0, tau);
  final tab = rng.range(0.9, 1.5);
  const count = 44;
  return [
    for (var i = 0; i < count; i++)
      _waxPoint(i / count * tau, cx, cy, big, tab, p1, p2, p3),
  ];
}

Pt _waxPoint(
  double a,
  double cx,
  double cy,
  double big,
  double tab,
  double p1,
  double p2,
  double p3,
) {
  final dA = JsMath.atan2(JsMath.sin(a - tab), JsMath.cos(a - tab));
  final drip = 0.16 * JsMath.exp(-(dA * dA) / 0.05);
  final r =
      big *
      (1 +
          0.05 * JsMath.sin(3 * a + p1) +
          0.03 * JsMath.sin(7 * a + p2) +
          0.018 * JsMath.sin(11 * a + p3) +
          drip);
  return (cx + JsMath.cos(a) * r, cy + JsMath.sin(a) * r);
}

/// Draws a [size] px wax seal: a dripping blob, a pressed inner disc and a
/// check, up to two letters or a star.
///
/// Mirrors `waxSeal` in `src/lib/ink/recipes/seal-ink.ts`.
void waxSeal(Ink ink, double size, SealParams p) {
  final rng = ink.next('wax');
  final c = size / 2;
  final big = size * 0.4;
  final tone = p.tone ?? PaintKey.red;
  final outline = _waxOutline(c, c, big, rng);
  final d = smoothClosed(outline, tierCfg(ink.tier));
  final bbox = BBox(c - big * 1.2, c - big * 1.2, c + big * 1.2, c + big * 1.2);
  ink
    ..flat(Material.under, d, tone, bbox: bbox)
    ..flat(Material.under, d, PaintKey.ink, op: 0.1, bbox: bbox);
  List<Pt> inner(double rr, [double dx = 0, double dy = 0]) => [
    for (var i = 0; i < 40; i++)
      (
        c +
            dx +
            JsMath.cos((i / 40) * tau) * rr * (1 + 0.012 * JsMath.sin(i * 1.7)),
        c +
            dy +
            JsMath.sin((i / 40) * tau) * rr * (1 + 0.012 * JsMath.cos(i * 1.3)),
      ),
  ];
  final rIn = big * 0.62;
  final lip = inner(rIn * 1.02, -big * 0.02, -big * 0.02);
  ink
    ..poly(Material.under, inner(big * 0.93, -big * 0.04, -big * 0.05), tone)
    ..poly(
      Material.under,
      inner(big * 0.93, -big * 0.04, -big * 0.05),
      PaintKey.photo,
      0.12,
    )
    ..poly(
      Material.marker,
      inner(big * 0.5, -big * 0.32, -big * 0.36),
      PaintKey.photo,
      0.3,
    )
    ..poly(Material.under, inner(rIn), PaintKey.ink, 0.22)
    ..poly(Material.under, inner(rIn * 0.96, big * 0.012, big * 0.012), tone)
    ..stroke(
      [...inner(rIn), inner(rIn).first],
      PenName.inkFine,
      const StrokeOpts(poly: true, alpha: 0.55, width: 0.9),
    )
    ..stroke(
      [...lip.sublist(28), ...lip.sublist(0, 8)],
      PenName.inkFine,
      const StrokeOpts(
        poly: true,
        color: PaintKey.photo,
        alpha: 0.55,
        width: 0.9,
      ),
    );
  final upper = (p.text ?? '').toUpperCase();
  final word = upper.substring(0, math.min(2, upper.length));
  if (p.mark == SealMark.check) {
    final List<Pt> pts = [
      (c - big * 0.3, c + big * 0.02),
      (c - big * 0.07, c + big * 0.24),
      (c + big * 0.34, c - big * 0.26),
    ];
    ink
      ..stroke(
        [for (final (x, y) in pts) (x + 0.9, y + 0.9)],
        PenName.inkBrush,
        const StrokeOpts(
          poly: true,
          alpha: 0.6,
          width: 1.15,
          start: StrokeStart.soft,
          end: StrokeEnd.flick,
        ),
      )
      ..stroke(
        pts,
        PenName.inkBrush,
        const StrokeOpts(
          poly: true,
          color: PaintKey.photo,
          alpha: 0.6,
          width: 1.05,
          start: StrokeStart.soft,
          end: StrokeEnd.flick,
        ),
      );
  }
  if (p.mark != SealMark.check && word.isNotEmpty) {
    final em =
        big *
        switch (word.length > 1) {
          true => 0.62,
          false => 0.9,
        };
    final base = c + 0.745 * em * 0.5;
    const opts = TextOpts(font: LetterFont.hand, jitter: 0.5);
    final t = textPath(word, c + 0.9, base + 0.9, em, rng.fork('t'), opts);
    final t2 = textPath(word, c, base, em, rng.fork('t'), opts);
    ink
      ..flat(Material.text, t.d, PaintKey.ink, op: 0.6, bbox: t.bbox)
      ..flat(Material.text, t2.d, PaintKey.photo, op: 0.55, bbox: t2.bbox);
  }
  if (p.mark != SealMark.check && word.isEmpty) {
    final s = sealStarPath(c, c, big * 0.34);
    ink
      ..flat(Material.text, s, PaintKey.ink, op: 0.45)
      ..flat(Material.text, s, PaintKey.photo, op: 0.4);
  }
  ink
    ..stroke(
      [...outline, outline.first],
      PenName.inkFine,
      const StrokeOpts(poly: true, alpha: 0.8, width: 0.95),
    )
    ..stroke(
      [
        (c - big * 0.72, c - big * 0.42),
        (c - big * 0.55, c - big * 0.66),
        (c - big * 0.3, c - big * 0.82),
      ],
      PenName.inkFine,
      const StrokeOpts(
        poly: true,
        color: PaintKey.photo,
        alpha: 0.85,
        width: 1.2,
      ),
    );
}
