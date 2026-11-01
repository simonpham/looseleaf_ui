import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:looseleaf_ink/src/recipes/marks/marks.dart';

/// The underline's stroke.
enum UnderlineMarkKind { single, double, wavy, scribble }

/// Underline recipe params.
///
/// Mirrors `UnderlineParams` in `src/lib/ink/recipes/underline-ink.ts`.
final class UnderlineParams {
  /// Params.
  const UnderlineParams({
    required this.line,
    required this.kind,
    required this.tone,
    required this.weight,
  });

  final LineParams line;
  final UnderlineMarkKind kind;
  final MarkPen tone;
  final MarkWeight weight;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    ...line.toJson(),
    'kind': kind.name,
    'tone': tone.id,
    'weight': weight.name,
  };
}

/// A hand underline under one line of text: single, double, wavy or a
/// scribbled zigzag.
///
/// Mirrors `underlineRecipe` in `src/lib/ink/recipes/underline-ink.ts`.
final Recipe<UnderlineParams> underlineRecipe = defineRecipe<UnderlineParams>(
  id: 'underline',
  kind: 'underline',
  layers: const [LayerName.rest],
  pad: 10,
  draw: _draw,
);

void _draw(Ink ink, Box size, UnderlineParams params, RecipeContext ctx) {
  final Box(:w) = size;
  final p = params.line;
  final o = overshoot(p.fs);
  final x0 = switch (p.first) {
    true => -o * 0.5,
    false => 0.0,
  };
  final x1 = switch (p.last) {
    true => w + o,
    false => w,
  };
  final y = p.base + p.desc * 0.55 + p.fs * 0.1;
  final (:pen, :width, dry: _) = markPen(params.tone, params.weight, p.fs);
  ink.layer(LayerName.rest, () {
    if (params.kind == UnderlineMarkKind.scribble) {
      final rng = ink.next('ul-scrib');
      final pts = <Pt>[];
      final swing = math.max(2.2, p.fs * 0.16);
      var x = x0;
      var up = rng.chance(0.5);
      while (x < x1) {
        final sign = switch (up) {
          true => -1,
          false => 1,
        };
        pts.add((
          x,
          y +
              sign * swing * rng.range(0.6, 1.1) -
              swing * 0.2 -
              ((x - x0) / (x1 - x0)) * 1.2,
        ));
        x += math.max(3.4, p.fs * 0.27) * rng.range(0.75, 1.3);
        up = !up;
      }
      ink.lines(
        [
          Line(
            pts,
            o: const StrokeOpts(
              poly: true,
              round: 1.6,
              end: StrokeEnd.flick,
              speed: 1.3,
              wobble: 0.6,
            ),
          ),
        ],
        pen,
        StrokeOpts(width: 0.85 * width),
      );
      return;
    }
    underline(
      ink,
      x0,
      y,
      x1 - x0,
      kind: switch (params.kind) {
        UnderlineMarkKind.double => UnderlineKind.double,
        UnderlineMarkKind.wavy => UnderlineKind.wavy,
        _ => UnderlineKind.single,
      },
      pen: pen,
      opts: StrokeOpts(width: width),
    );
  });
}
