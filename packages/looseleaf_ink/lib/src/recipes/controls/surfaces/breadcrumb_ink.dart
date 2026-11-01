import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/no_params.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// The current breadcrumb page: a double blue underline (a single pencil
/// one when calm).
///
/// Mirrors `breadcrumbPageRecipe` in `src/lib/ink/recipes/breadcrumb-ink.ts`.
final Recipe<NoParams> breadcrumbPageRecipe = defineRecipe<NoParams>(
  id: 'breadcrumb-page',
  kind: 'crumb',
  layers: const [LayerName.rest],
  pad: 8,
  draw: (ink, size, _, ctx) {
    final Box(:w, :h) = size;
    ink.layer(LayerName.rest, () {
      if (ctx.calm) {
        underline(
          ink,
          1,
          h - 5,
          w - 2,
          kind: UnderlineKind.single,
          pen: PenName.pencilFine,
        );
        return;
      }
      underline(
        ink,
        1,
        h - 8,
        w - 2,
        kind: UnderlineKind.double,
        pen: PenName.blueFine,
        opts: const StrokeOpts(width: 1.1),
      );
    });
  },
);
