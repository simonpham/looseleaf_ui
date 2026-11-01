import 'dart:math' as math;

import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/paper/paper.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// How a napkin is folded.
///
/// Mirrors `NapkinFold` in `src/lib/ink/recipes/napkin-ink.ts`.
enum NapkinFold { quarter, half, none }

/// Napkin decor recipe params.
///
/// Mirrors `NapkinParams` in `src/lib/ink/recipes/napkin-ink.ts`.
final class NapkinParams {
  /// Params.
  const NapkinParams({required this.fold, required this.stain});

  /// The fold creases.
  final NapkinFold fold;

  /// A coffee ring.
  final bool stain;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'fold': fold.name, 'stain': stain};
}

String _creaseGradient(String id, String axis) =>
    '<linearGradient id="$id" $axis>'
    '<stop offset="0" stop-color="${tok('ink')}" stop-opacity=".085"/>'
    '<stop offset="1" stop-color="${tok('ink')}" stop-opacity="0"/>'
    '</linearGradient>';

/// A napkin's fold creases (shaded, with a lit ridge) and coffee ring.
///
/// Mirrors `napkinRecipe` in `src/lib/ink/recipes/napkin-ink.ts`.
final Recipe<NapkinParams> napkinRecipe = defineRecipe<NapkinParams>(
  id: 'napkin-decor',
  kind: 'napkin',
  layers: const [LayerName.rest],
  pad: 4,
  draw: (ink, size, params, ctx) {
    final Box(:w, :h) = size;
    final r = ink.next('creases');
    final id = 'll-nk${ink.seed.toRadixString(36)}';
    ink.layer(LayerName.rest, () {
      final s = StringBuffer();
      const reach = 34.0;
      void vertical(double x0, int i) {
        final j = r.gauss(0, 0.5);
        s
          ..write(_creaseGradient('${id}v$i', 'x1="1" y1="0" x2="0" y2="0"'))
          ..write(
            pathTag(
              'M${num10(x0 - reach)} 0H${num10(x0)}V${num10(h)}H${num10(x0 - reach)}z',
              fill: 'url(#${id}v$i)',
              transform: 'translate(${num10(j)} 0)',
            ),
          )
          ..write(
            pathTag(
              'M${num10(x0 + j)} 3L${num10(x0 + j + r.gauss(0, 0.6))} '
              '${num10(h * 0.5)}L${num10(x0 + j)} ${num10(h - 3)}',
              stroke: tok('ink'),
              sw: 0.7,
              op: 0.2,
            ),
          )
          ..write(
            pathTag(
              'M${num10(x0 + j + 1.2)} 3L${num10(x0 + j + 1.2)} ${num10(h - 3)}',
              stroke: tok('photo'),
              sw: 1,
              op: 0.75,
            ),
          );
      }

      void horizontal(double y0, int i) {
        final j = r.gauss(0, 0.5);
        s
          ..write(_creaseGradient('${id}h$i', 'x1="0" y1="1" x2="0" y2="0"'))
          ..write(
            pathTag(
              'M0 ${num10(y0 - reach)}H${num10(w)}V${num10(y0)}H0z',
              fill: 'url(#${id}h$i)',
              transform: 'translate(0 ${num10(j)})',
            ),
          )
          ..write(
            pathTag(
              'M3 ${num10(y0 + j)}L${num10(w * 0.5)} '
              '${num10(y0 + j + r.gauss(0, 0.6))}L${num10(w - 3)} ${num10(y0 + j)}',
              stroke: tok('ink'),
              sw: 0.7,
              op: 0.2,
            ),
          )
          ..write(
            pathTag(
              'M3 ${num10(y0 + j + 1.2)}H${num10(w - 3)}',
              stroke: tok('photo'),
              sw: 1,
              op: 0.75,
            ),
          );
      }

      switch (params.fold) {
        case NapkinFold.quarter:
          vertical(w / 2 + r.gauss(0, 0.4), 0);
          horizontal(h / 2 + r.gauss(0, 0.4), 0);
        case NapkinFold.half:
          horizontal(h / 2 + r.gauss(0, 0.4), 0);
        case NapkinFold.none:
          break;
      }
      if (params.stain) {
        final big = math
            .min(46, math.max(24, math.min(w, h) * 0.13))
            .toDouble();
        final ring = coffeeRing(
          '${ink.seed}|ring',
          radius: big,
          tier: ink.tier,
          calm: ctx.calm,
        );
        s.write(
          '<g transform="translate(${num10(w * 0.58)} ${num10(h * 0.56)}) '
          'rotate(${num10(r.range(-30, 30))} ${num10(big)} ${num10(big)})">'
          '${ring.svg}</g>',
        );
      }
      ink
        ..raw('$s', Material.top)
        ..grow(BBox(0, 0, w, h));
    });
  },
);
