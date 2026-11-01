import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/no_params.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// How far a keycap's depth sits below and right of its face.
///
/// Mirrors `KEY_DEPTH` in `src/lib/ink/recipes/kbd-ink.ts`.
const double keyDepth = 2.4;

/// A keycap in `currentColor`: a depth shadow (hidden when pressed), a slip
/// face with a light wash and a pencil outline.
///
/// Mirrors `kbdRecipe` in `src/lib/ink/recipes/kbd-ink.ts`.
final Recipe<NoParams> kbdRecipe = defineRecipe<NoParams>(
  id: 'kbd',
  kind: 'keycap',
  layers: const [LayerName.rest],
  pad: 12,
  draw: (ink, size, _, ctx) {
    final Box(:w, :h) = size;
    final calm = ctx.calm;
    final d = switch (calm) {
      true => 0.0,
      false => keyDepth,
    };
    final fw = w - d;
    final fh = h - d;
    final r = clamp(math.min(fw, fh) * 0.16, 2, 3.4);
    ink.layer(LayerName.rest, () {
      if (!calm) {
        ink.group(
          GroupAttrs(part: 'depth', hideOn: 'pressed'),
          () => ink.poly(
            Material.wash,
            roundRectPoly(d, d, fw, fh, r),
            PaintKey.current,
            0.3,
          ),
          Material.under,
        );
      }
      ink.poly(
        Material.under,
        roundRectPoly(0.5, 0.5, fw - 1, fh - 1, r),
        PaintKey.slip,
      );
      wash(
        ink,
        roundRectPoly(1.4, 1.4, fw - 2.8, fh - 2.8, r),
        PaintKey.current,
        alpha: 0.09,
        material: Material.wash,
      );
      box(
        ink,
        0,
        0,
        fw,
        fh,
        pen: PenName.pencil,
        corner: r,
        loose: 0.6,
        opts: const StrokeOpts(
          color: PaintKey.current,
          width: 1,
          alpha: 0.85,
          simple: true,
        ),
      );
    });
  },
);
