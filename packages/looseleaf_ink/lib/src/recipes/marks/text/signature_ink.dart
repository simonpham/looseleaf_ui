import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:looseleaf_ink/src/recipes/marks/marks.dart';

/// The flourish under a signature.
enum SignatureFlourish { swoosh, underline, none }

/// Signature recipe params; [fs] is the signature's font size.
///
/// Mirrors `SignatureParams` in `src/lib/ink/recipes/signature-ink.ts`.
final class SignatureParams {
  /// Params.
  const SignatureParams({
    required this.flourish,
    required this.tone,
    required this.weight,
    required this.fs,
    this.animate,
  });

  final SignatureFlourish flourish;
  final MarkPen tone;
  final MarkWeight weight;
  final double fs;
  final bool? animate;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'flourish': flourish.name,
    'tone': tone.id,
    'weight': weight.name,
    'fs': fs,
    'animate': ?animate,
  };
}

/// The flourish under a signature: an underline or a looped swoosh.
///
/// Mirrors `signatureRecipe` in `src/lib/ink/recipes/signature-ink.ts`.
final Recipe<SignatureParams> signatureRecipe = defineRecipe<SignatureParams>(
  id: 'signature',
  kind: 'signature',
  layers: const [LayerName.rest],
  pad: 20,
  draw: _draw,
);

void _draw(Ink ink, Box size, SignatureParams p, RecipeContext ctx) {
  final Box(:w, :h) = size;
  if (p.flourish == SignatureFlourish.none) return;
  final (:pen, :width, dry: _) = markPen(p.tone, p.weight, p.fs * 0.5);
  final rng = ink.next('sig');
  final base = math.max(p.fs * 0.5, h - 12) * 0.88;
  final r = math.max(4, p.fs * 0.16).toDouble();
  final lines = switch (p.flourish) {
    SignatureFlourish.underline => _underline(rng, w, base, r),
    _ => _swoosh(rng, w, base, r),
  };
  ink.layer(LayerName.rest, () {
    if (p.animate ?? false) {
      revealMark(
        ink,
        id: markRevealId(ctx.seed, 'g'),
        lines: lines,
        pen: pen,
        box: size,
        pad: 28,
        width: width,
        revealWidth: 5 + p.fs * 0.06,
      );
      return;
    }
    ink.lines(lines, pen, StrokeOpts(width: width));
  });
}

List<Line> _underline(Rng rng, double w, double base, double r) {
  final y = base + r * 0.6;
  final pts = <Pt>[];
  for (var i = 0; i <= 12; i++) {
    final t = i / 12;
    pts.add((
      -w * 0.02 + t * w * 1.08,
      y +
          JsMath.sin(t * JsMath.pi * 1.1) * -r * 0.5 -
          t * r * 0.7 +
          rng.gauss(0, 0.2),
    ));
  }
  return [
    Line(
      pts,
      o: const StrokeOpts(
        start: StrokeStart.pool,
        end: StrokeEnd.flick,
        wobble: 0.6,
      ),
    ),
  ];
}

List<Line> _swoosh(Rng rng, double w, double base, double r) {
  final x0 = w * 0.03, y0 = base;
  final pts = <Pt>[];
  const loop = 14;
  for (var i = 0; i <= loop; i++) {
    final a = (i / loop) * JsMath.pi * 2 + JsMath.pi * 0.5;
    pts.add((
      x0 + JsMath.cos(a) * r * 1.25 - r * 0.2,
      y0 - r * 0.5 - JsMath.sin(a) * r * 0.85 + (i / loop) * r * 0.9,
    ));
  }
  const n = 22;
  final (sx, sy) = pts[pts.length - 1];
  for (var i = 1; i <= n; i++) {
    final t = i / n;
    final x = sx + t * (w * 1.1 - sx);
    final sag = JsMath.sin(t * JsMath.pi * 0.95) * r * 0.9;
    final rise = t * t * t * r * 3.2;
    pts.add((x, sy + sag - rise + rng.gauss(0, 0.15)));
  }
  final cx0 = w * rng.range(0.42, 0.55),
      cx1 = w * rng.range(0.9, 1.0),
      cy = base + r * 1.35;
  final under = <Pt>[];
  for (var i = 0; i <= 8; i++) {
    final t = i / 8;
    under.add((
      cx0 + t * (cx1 - cx0),
      cy - t * r * 0.9 + JsMath.sin(t * JsMath.pi) * r * 0.25,
    ));
  }
  return [
    Line(
      pts,
      o: const StrokeOpts(
        start: StrokeStart.pool,
        end: StrokeEnd.flick,
        wobble: 0.55,
        speed: 1.05,
      ),
    ),
    Line(
      under,
      o: const StrokeOpts(
        start: StrokeStart.soft,
        end: StrokeEnd.flick,
        wobble: 0.5,
        speed: 1.25,
      ),
    ),
  ];
}
