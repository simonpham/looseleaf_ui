import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/paper/paper.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:looseleaf_ink/src/recipes/paper/paper.dart';

/// Index card decor recipe params.
///
/// Mirrors `IndexCardParams` in `src/lib/ink/recipes/index-card-ink.ts`.
final class IndexCardParams {
  /// Params.
  const IndexCardParams({required this.hole, this.flag, required this.stack});

  /// A punched hole near the foot.
  final bool hole;

  /// A coloured flag tab on the end edge; none when null.
  final Accent? flag;

  /// How many cards peek out below.
  final int stack;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'hole': hole,
    'flag': flag?.name ?? 'none',
    'stack': stack,
  };
}

/// Index card geometry: the hole's distance from the foot and radius, and
/// the flag's top, height, overhang and overlap.
///
/// Mirrors `INDEX_CARD` in `src/lib/ink/recipes/index-card-ink.ts`.
const ({
  double holeFromFoot,
  double holeR,
  double flagAt,
  double flagH,
  double flagOut,
  double flagOver,
})
indexCardLayout = (
  holeFromFoot: 19,
  holeR: 6.2,
  flagAt: 58,
  flagH: 42,
  flagOut: 15,
  flagOver: 9,
);

/// An index card's stack of cards below, a punched hole and a flag tab,
/// mirrored in right-to-left layouts.
///
/// Mirrors `indexCardRecipe` in `src/lib/ink/recipes/index-card-ink.ts`.
final Recipe<IndexCardParams> indexCardRecipe = defineRecipe<IndexCardParams>(
  id: 'index-card-decor',
  kind: 'index-card',
  layers: const [LayerName.rest],
  pad: 26,
  draw: (ink, size, params, ctx) {
    final Box(:w, :h) = size;
    final id = 'll-ic${ink.seed.toRadixString(36)}';
    ink.layer(LayerName.rest, () {
      final r = ink.next('card');
      final s = StringBuffer(
        stackSvg(w, h, params.stack, r, id, ('card', 'slip')),
      );
      final inner = StringBuffer();
      if (params.hole) {
        inner.write(
          holePunch(
            '${id}h',
            w / 2 + r.gauss(0, 0.6),
            h - indexCardLayout.holeFromFoot + r.gauss(0, 0.5),
            indexCardLayout.holeR,
            r.range(-20, 20),
          ),
        );
      }
      if (params.flag case final Accent flag) {
        final (
          flagAt: y,
          flagH: fh,
          flagOut: out,
          flagOver: over,
          holeFromFoot: _,
          holeR: _,
        ) = indexCardLayout;
        final x0 = w - over;
        final x1 = w + out;
        final body =
            'M${num10(x0)} ${num10(y)}H${num10(x1 - 3)}L${num10(x1)} '
            '${num10(y + fh / 2)}L${num10(x1 - 3)} ${num10(y + fh)}H${num10(x0)}z';
        inner
          ..write(
            pathTag(
              body,
              fill: tok('ink'),
              op: 0.18,
              transform: 'translate(.8 2)',
            ),
          )
          ..write(pathTag(body, fill: tok(flag.name), op: 0.92))
          ..write(
            pathTag(
              'M${num10(x0)} ${num10(y)}H${num10(w)}V${num10(y + fh)}H${num10(x0)}z',
              fill: tok('photo'),
              op: 0.18,
            ),
          )
          ..write(
            pathTag(
              'M${num10(w)} ${num10(y)}V${num10(y + fh)}',
              stroke: tok('ink'),
              sw: 0.6,
              op: 0.28,
            ),
          )
          ..write(
            pathTag(
              'M${num10(x0 + 1)} ${num10(y + 1)}H${num10(x1 - 3)}',
              stroke: tok('photo'),
              sw: 0.9,
              op: 0.75,
            ),
          )
          ..write(pathTag(body, stroke: tok('ink'), sw: 0.6, op: 0.28));
      }
      s.write(switch (ctx.dir) {
        Dir.rtl => mirrorX(w, '$inner'),
        Dir.ltr => '$inner',
      });
      ink
        ..raw('$s', Material.top)
        ..grow(BBox(-26, -26, w + 26, h + 26));
    });
  },
);
