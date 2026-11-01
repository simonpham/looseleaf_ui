import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:looseleaf_ink/src/recipes/marks/marks.dart';

/// Scribble (redaction) recipe params.
///
/// Mirrors `ScribbleParams` in `src/lib/ink/recipes/scribble-ink.ts`.
final class ScribbleParams {
  /// Params.
  const ScribbleParams({
    required this.line,
    required this.tone,
    required this.weight,
  });

  final LineParams line;
  final MarkPen tone;
  final MarkWeight weight;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    ...line.toJson(),
    'tone': tone.id,
    'weight': weight.name,
  };
}

const StrokeOpts _zig = StrokeOpts(
  end: StrokeEnd.flick,
  speed: 1.5,
  wobble: 0.5,
  poly: true,
  round: 1.4,
);

/// A dense zigzag scribbled over one line of text, redacting it.
///
/// Mirrors `scribbleRecipe` in `src/lib/ink/recipes/scribble-ink.ts`.
final Recipe<ScribbleParams> scribbleRecipe = defineRecipe<ScribbleParams>(
  id: 'scribble',
  kind: 'scribble',
  layers: const [LayerName.rest],
  pad: 10,
  draw: _draw,
);

void _draw(Ink ink, Box size, ScribbleParams params, RecipeContext ctx) {
  final Box(:w) = size;
  final p = params.line;
  final o = overshoot(p.fs);
  final rng = ink.next('redact');
  final top = p.base - p.cap - p.fs * 0.06;
  final bot = p.base + p.desc * 0.7;
  final weight = switch (params.weight) {
    MarkWeight.regular => MarkWeight.brush,
    final other => other,
  };
  final (:pen, :width, dry: _) = markPen(params.tone, weight, p.fs);
  final x0 = -o * 0.7, x1 = w + o * 0.8;
  final pitch = math.max(2.6, p.fs * 0.2);
  ink.layer(LayerName.rest, () {
    final lines = <Line>[];
    var pts = <Pt>[];
    var x = x0;
    var up = true;
    var len = 0.0;
    final lean = rng.gauss(0.22, 0.05) * (bot - top);
    while (x < x1) {
      final t = switch (up) {
        true => top + rng.range(0, 0.18) * (bot - top),
        false => bot - rng.range(0, 0.18) * (bot - top),
      };
      final shift = switch (up) {
        true => -lean / 2,
        false => lean / 2,
      };
      pts.add((math.min(x1, x + shift), t));
      x += pitch * rng.range(0.7, 1.35);
      up = !up;
      len += pitch;
      if (len > 160 && pts.length > 3) {
        lines.add(Line(pts, o: _zig));
        pts = [pts[pts.length - 1]];
        len = 0;
      }
    }
    if (pts.length > 1) lines.add(Line(pts, o: _zig));
    ink.lines(lines, pen, StrokeOpts(width: 0.7 * width));
    if (ctx.calm) return;
    final back = <Pt>[];
    final n = math.max(4, JsMath.roundInt((x1 - x0) / (pitch * 3.1)));
    for (var i = 0; i <= n; i++) {
      back.add((
        x0 + ((x1 - x0) * i) / n + rng.gauss(0, 1),
        switch (i % 2) {
          0 => bot - 1,
          _ => top + 1,
        },
      ));
    }
    ink.lines(
      [
        Line(
          back,
          o: const StrokeOpts(
            end: StrokeEnd.flick,
            speed: 1.4,
            wobble: 0.6,
            poly: true,
            round: 1.2,
          ),
        ),
      ],
      pen,
      StrokeOpts(width: 0.6 * width),
    );
  });
}
