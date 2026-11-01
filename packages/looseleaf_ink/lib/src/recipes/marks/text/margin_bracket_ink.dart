import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/controls.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Margin bracket recipe params.
///
/// Mirrors `MarginBracketParams` in
/// `src/lib/ink/recipes/margin-bracket-ink.ts`.
final class MarginBracketParams {
  /// Params; [kind] is square or curly.
  const MarginBracketParams({required this.kind});

  final BracketKind kind;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'kind': kind.name};
}

/// A blue-pencil bracket in the margin that draws itself on.
///
/// Mirrors `marginBracketRecipe` in
/// `src/lib/ink/recipes/margin-bracket-ink.ts`.
final Recipe<MarginBracketParams> marginBracketRecipe =
    defineRecipe<MarginBracketParams>(
      id: 'margin-bracket',
      kind: 'bracket',
      layers: const [LayerName.rest],
      pad: 8,
      draw: _draw,
    );

void _draw(Ink ink, Box size, MarginBracketParams p, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final rtl = ctx.dir == Dir.rtl;
  final dir = switch (rtl) {
    true => -1,
    false => 1,
  };
  final x = switch (rtl) {
    true => w - 1.5,
    false => 1.5,
  };
  final lines = bracketLines(
    ink.next('bracket'),
    x,
    1,
    math.max(8, h - 2),
    kind: p.kind,
    dir: dir,
  );
  ink.layer(LayerName.rest, () {
    reveal(
      ink,
      id: revealId(ctx.seed, 'b'),
      lines: lines,
      pen: switch (ctx.calm) {
        true => PenName.bluepencilFine,
        false => PenName.bluepencil,
      },
      width: switch (ctx.calm) {
        true => 1.1,
        false => 1.65,
      },
      box: size,
      revealWidth: math.max(4, math.min(w, 14)),
    );
  });
}
