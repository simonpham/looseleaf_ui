import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/no_params.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// A red wavy underline under a field's error message (straight when calm).
///
/// Mirrors `fieldErrorRecipe` in `src/lib/ink/recipes/field-error-ink.ts`.
final Recipe<NoParams> fieldErrorRecipe = defineRecipe<NoParams>(
  id: 'field-error',
  kind: 'underline',
  layers: const [LayerName.rest],
  pad: 12,
  draw: (ink, size, _, ctx) {
    final Box(:w, :h) = size;
    ink.layer(
      LayerName.rest,
      () => underline(
        ink,
        -1,
        h + 0.5,
        w + 2,
        kind: switch (ctx.calm) {
          true => UnderlineKind.single,
          false => UnderlineKind.wavy,
        },
        pen: switch (ctx.calm) {
          true => PenName.redFine,
          false => PenName.redfeltFine,
        },
        opts: StrokeOpts(simple: w > 200),
      ),
    );
  },
);
