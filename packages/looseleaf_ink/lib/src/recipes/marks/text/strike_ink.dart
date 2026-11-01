import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:looseleaf_ink/src/recipes/marks/marks.dart';

/// The strike-through's stroke.
enum StrikeKind { single, double, cross }

/// Strike recipe params.
///
/// Mirrors `StrikeParams` in `src/lib/ink/recipes/strike-ink.ts`.
final class StrikeParams {
  /// Params.
  const StrikeParams({
    required this.line,
    required this.kind,
    required this.tone,
    required this.weight,
  });

  final LineParams line;
  final StrikeKind kind;
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

/// A strike-through over one line of text, single, doubled or a cross.
///
/// Mirrors `strikeRecipe` in `src/lib/ink/recipes/strike-ink.ts`.
final Recipe<StrikeParams> strikeRecipe = defineRecipe<StrikeParams>(
  id: 'strike',
  kind: 'strike',
  layers: const [LayerName.rest],
  pad: 12,
  draw: _draw,
);

void _draw(Ink ink, Box size, StrikeParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final p = params.line;
  final o = overshoot(p.fs);
  final (:pen, :width, dry: _) = markPen(
    params.tone,
    params.weight,
    p.fs,
    pencil: true,
  );
  ink.layer(LayerName.rest, () {
    if (params.kind == StrikeKind.cross) {
      final rng = ink.next('cross');
      final top = p.base - p.cap - 1;
      final bot = h - (p.ch - p.base - p.desc) + 1;
      final l = -o * 0.8, r = w + o * 0.8;
      double j() => rng.gauss(0, 0.9);
      final n = math.max(6, (w / 14).ceil());
      final lines = [
        Line(
          seg(l + j(), top + j(), r + j(), bot + j(), rng.gauss(0, 1.2), n),
          o: const StrokeOpts(end: StrokeEnd.flick, wobble: 0.5, speed: 1.2),
        ),
        Line(
          seg(
            r + j() - 2,
            top + j(),
            l + j() + 3,
            bot + j(),
            rng.gauss(0, 1.2),
            n,
          ),
          o: const StrokeOpts(
            end: StrokeEnd.flick,
            start: StrokeStart.soft,
            wobble: 0.5,
            speed: 1.2,
          ),
        ),
      ];
      ink.lines(lines, pen, StrokeOpts(width: width));
      return;
    }
    strike(
      ink,
      -o * 0.4,
      p.base - p.xh * 0.55,
      w + o * 0.9,
      pen: pen,
      doubled: params.kind == StrikeKind.double,
      opts: StrokeOpts(width: width),
    );
  });
}
