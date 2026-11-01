import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Which side of the label the rule runs on.
enum MarkerSide { start, end, full }

/// The rule's tone; `id` is the upstream name (`regular` is upstream's
/// `default`).
enum MarkerTone {
  regular('default'),
  fresh('new');

  const MarkerTone(this.id);

  /// The upstream name.
  final String id;
}

/// The rule's stroke.
enum MarkerStyle { line, wavy }

/// Marker rule recipe params.
///
/// Mirrors `MarkerRuleParams` in `src/lib/ink/recipes/marker-ink.ts`.
final class MarkerRuleParams {
  /// Params.
  const MarkerRuleParams({required this.side, required this.tone, this.style});

  final MarkerSide side;
  final MarkerTone tone;

  /// The stroke, [MarkerStyle.line] when unset.
  final MarkerStyle? style;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'side': side.name,
    'tone': tone.id,
    if (style case final MarkerStyle s) 'style': s.name,
  };
}

/// The rule beside a list marker label ("new" in red), leaving a gap
/// toward the words.
///
/// Mirrors `markerRuleRecipe` in `src/lib/ink/recipes/marker-ink.ts`.
final Recipe<MarkerRuleParams> markerRuleRecipe =
    defineRecipe<MarkerRuleParams>(
      id: 'marker-rule',
      kind: 'rule',
      layers: const [LayerName.rest],
      pad: 8,
      draw: _draw,
    );

void _draw(Ink ink, Box size, MarkerRuleParams p, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final y = h / 2;
  final rtl = ctx.dir == Dir.rtl;
  final towardsWords = switch (p.side) {
    MarkerSide.full => null,
    final side when (side == MarkerSide.start) == !rtl => 'right',
    _ => 'left',
  };
  final gap = clamp(w * 0.02, 1, 4) + 1;
  final x1 = switch (towardsWords) {
    'left' => gap,
    _ => 0.0,
  };
  final x2 = switch (towardsWords) {
    'right' => w - gap,
    _ => w,
  };
  final fresh = p.tone == MarkerTone.fresh;
  ink.layer(LayerName.rest, () {
    if (ctx.calm) {
      line(
        ink,
        x1,
        y,
        x2,
        y,
        pen: PenName.pencilFine,
        opts: StrokeOpts(
          alpha: switch (fresh) {
            true => 0.9,
            false => 0.7,
          },
          simple: true,
          color: switch (fresh) {
            true => PaintKey.red,
            false => null,
          },
        ),
      );
      return;
    }
    final pen = switch (fresh) {
      true => PenName.red,
      false => PenName.pencil,
    };
    if ((p.style ?? MarkerStyle.line) == MarkerStyle.wavy &&
        p.side == MarkerSide.full) {
      underline(ink, x1, y, x2 - x1, kind: UnderlineKind.wavy, pen: pen);
      return;
    }
    line(ink, x1, y, x2, y, pen: pen);
  });
}
