import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/no_params.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// A pencil frame around hover card media.
///
/// Mirrors `hoverCardMediaRecipe` in `src/lib/ink/recipes/hover-card-ink.ts`.
final Recipe<NoParams> hoverCardMediaRecipe = defineRecipe<NoParams>(
  id: 'hover-card-media',
  kind: 'frame',
  layers: const [LayerName.rest],
  pad: 6,
  draw: (ink, size, _, ctx) {
    final Box(:w, :h) = size;
    ink.layer(
      LayerName.rest,
      () => box(
        ink,
        1,
        1,
        w - 2,
        h - 2,
        pen: switch (ctx.calm) {
          true => PenName.pencilFine,
          false => PenName.pencil,
        },
        corner: 2,
      ),
    );
  },
);
