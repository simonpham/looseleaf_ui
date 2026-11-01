import 'dart:math' as math;

import 'package:looseleaf_ink/src/art/art.dart';
import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Signature baseline recipe params.
///
/// Mirrors `SignatureBaselineParams` in
/// `src/lib/ink/recipes/signature-pad-ink.ts`.
final class SignatureBaselineParams {
  /// Params.
  const SignatureBaselineParams({this.invalid});

  /// Draws the line and cross in red.
  final bool? invalid;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    if (invalid case final bool v) 'invalid': v,
  };
}

/// Where the signature line sits, as a share of the pad's height.
///
/// Mirrors `BASELINE_AT` in `src/lib/ink/recipes/signature-pad-ink.ts`.
const double signatureBaselineAt = 0.72;

/// A signature pad's baseline with a sign-here cross at its start.
///
/// Mirrors `signatureBaselineRecipe` in
/// `src/lib/ink/recipes/signature-pad-ink.ts`.
final Recipe<SignatureBaselineParams> signatureBaselineRecipe =
    defineRecipe<SignatureBaselineParams>(
      id: 'signature-baseline',
      kind: 'signature-baseline',
      layers: const [LayerName.rest],
      pad: 8,
      draw: (ink, size, params, ctx) {
        final Box(:w, :h) = size;
        final y = h * signatureBaselineAt;
        final invalid = params.invalid ?? false;
        final (pen, alpha) = switch (invalid) {
          true => (PenName.red, 0.9),
          false => (PenName.pencil, 0.85),
        };
        ink.layer(LayerName.rest, () {
          line(
            ink,
            w * 0.11,
            y,
            w - w * 0.05,
            y - 1.4,
            pen: pen,
            opts: StrokeOpts(alpha: alpha),
          );
          final x = w * 0.05, s = math.min(11, h * 0.07);
          const soft = StrokeOpts(
            start: StrokeStart.soft,
            end: StrokeEnd.flick,
          );
          ink.lines(
            [
              Line(seg(x - s, y - 2 * s - 2, x + s, y - 2, 0.2, 4), o: soft),
              Line(seg(x + s, y - 2 * s - 3, x - s, y - 1, 0.2, 4), o: soft),
            ],
            pen,
            const StrokeOpts(width: 1.1),
          );
        });
      },
    );

/// A typed name drawn as a handwritten signature: the markup and the
/// letter size it was fitted to (0 for an empty name).
///
/// Mirrors `TypedSignature` in `src/lib/ink/recipes/signature-pad-ink.ts`.
typedef TypedSignature = ({String svg, double size});

/// [text] set in hand lettering on a [w]×[h] pad's baseline, shrunk to
/// fit, with a brush underline flourish in [color].
///
/// Mirrors `typedSignature` in `src/lib/ink/recipes/signature-pad-ink.ts`.
TypedSignature typedSignature(
  String text,
  double w,
  double h,
  String seed, [
  PaintKey color = PaintKey.inkYou,
]) {
  final trimmed = text.trim();
  final name = trimmed.substring(0, math.min(60, trimmed.length));
  final ink = Ink('sig|$seed');
  if (name.isEmpty) return (svg: '', size: 0);
  final x0 = w * 0.11;
  final room = w - x0 - w * 0.06;
  const spacing = 2.0;
  var size = math.min(h * 0.3, 54).toDouble();
  final natural = measureText(LetterFont.hand, name, size, spacing);
  if (natural > room) size = math.max(14, (size * room) / natural).toDouble();
  final base = h * signatureBaselineAt - 5;
  final tp = textPath(
    name,
    x0,
    base,
    size,
    ink.next('type'),
    const TextOpts(
      font: LetterFont.hand,
      anchor: TextAnchor.start,
      spacing: spacing,
      jitter: 1.1,
      rot: -2.2,
    ),
  );
  ink.flat(Material.felt, tp.d, color, op: 0.93, bbox: tp.bbox);
  final sw = math.min(room, tp.width + 16);
  final cap = capHeight(LetterFont.hand, size);
  ink.stroke(
    [
      (x0 - 4, base + 5 - cap * 0.05),
      (x0 + sw * 0.35, base + 8),
      (x0 + sw * 0.7, base + 4.5),
      (x0 + sw + 4, base - 2),
    ],
    PenName.inkBrush,
    StrokeOpts(
      color: color,
      width: 0.6,
      end: StrokeEnd.flick,
      start: StrokeStart.soft,
    ),
  );
  return (svg: ink.toSvg(w: w, h: h, pad: 4).svg, size: size);
}
