import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/no_params.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// The frame around an input with addons. Draws every state eagerly; the rest
/// outline is hidden (`hideOn`) while invalid or disabled.
///
/// Mirrors `inputGroupRecipe` in `src/lib/ink/recipes/input-group-ink.ts`.
final Recipe<NoParams> inputGroupRecipe = defineRecipe<NoParams>(
  id: 'input-group',
  kind: 'field',
  layers: const [
    LayerName.rest,
    LayerName.invalid,
    LayerName.disabled,
    LayerName.hover,
    LayerName.focus,
  ],
  lazy: const [LayerName.focus, LayerName.hover],
  pad: 12,
  draw: _drawGroup,
);

void _drawGroup(Ink ink, Box size, NoParams _, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final r = clamp(math.min(w, h) * 0.08, 2, 4);
  final body = roundRectPoly(1.5, 1.5, w - 3, h - 3, r);
  final rtl = ctx.dir == Dir.rtl;
  final calm = ctx.calm;
  final wide = w > 360;
  ctx
    ..lazy(LayerName.focus, (f) => focusRing(f, 0, 0, w, h, r: r))
    ..lazy(
      LayerName.hover,
      (hv) => box(
        hv,
        0.6,
        0.6,
        w - 1.2,
        h - 1.2,
        pen: PenName.inkFine,
        corner: r,
        loose: 0.7,
        opts: StrokeOpts(alpha: 0.75, simple: wide),
      ),
    );
  if (ctx.lazyOnly) return;

  ink
    ..layer(LayerName.rest, () {
      ink
        ..poly(Material.under, body, PaintKey.slip, 0.7)
        ..group(GroupAttrs(hideOn: 'invalid disabled'), () {
          if (calm) {
            box(ink, 0, 0, w, h, pen: PenName.pencilFine, corner: r);
            return;
          }
          box(
            ink,
            0,
            0,
            w,
            h,
            pen: PenName.pencil,
            corner: r,
            opts: StrokeOpts(width: 1.15, simple: wide),
          );
        });
    })
    ..layer(LayerName.invalid, () {
      box(
        ink,
        0,
        0,
        w,
        h,
        pen: switch (calm) {
          true => PenName.redFine,
          false => PenName.red,
        },
        corner: r,
        opts: StrokeOpts(
          width: switch (calm) {
            true => 1.1,
            false => 1.25,
          },
          simple: wide,
        ),
      );
      final len = clamp(w - 40, 24, 110);
      if (calm) return;
      squiggle(
        ink,
        switch (rtl) {
          true => w - 6 - len,
          false => 6,
        },
        h + 5,
        len,
        pen: PenName.redfeltFine,
        h: 7,
        amp: 0.8,
      );
    })
    ..layer(LayerName.disabled, () {
      wash(ink, body, PaintKey.paperShade, alpha: 0.9, material: Material.wash);
      dashedBox(
        ink,
        0,
        0,
        w,
        h,
        r: r,
        pen: PenName.pencil,
        opts: const StrokeOpts(color: PaintKey.pencilMark),
      );
    });
}

/// Which edge of an input group a rule runs along.
enum InputGroupEdge { top, bottom }

/// Input group rule params.
///
/// Mirrors the params of `inputGroupRuleRecipe` in
/// `src/lib/ink/recipes/input-group-ink.ts`.
final class InputGroupRuleParams {
  /// Params.
  const InputGroupRuleParams({required this.edge});

  final InputGroupEdge edge;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'edge': edge.name};
}

/// The rule between an input group's block addon and its input.
///
/// Mirrors `inputGroupRuleRecipe` in `src/lib/ink/recipes/input-group-ink.ts`.
final Recipe<InputGroupRuleParams> inputGroupRuleRecipe =
    defineRecipe<InputGroupRuleParams>(
      id: 'input-group-rule',
      kind: 'rule',
      layers: const [LayerName.rest],
      pad: 6,
      draw: (ink, size, params, ctx) {
        final Box(:w, :h) = size;
        final y = switch (params.edge) {
          InputGroupEdge.bottom => h - 1,
          InputGroupEdge.top => 1.0,
        };
        ink.layer(LayerName.rest, () {
          if (ctx.calm) {
            line(
              ink,
              1,
              y,
              w - 1,
              y,
              pen: PenName.pencilFine,
              opts: const StrokeOpts(alpha: 0.7, wobble: 0.2),
            );
            return;
          }
          line(
            ink,
            1,
            y,
            w - 1,
            y,
            pen: PenName.pencil,
            opts: StrokeOpts(width: 1.15, simple: w > 360),
          );
        });
      },
    );
