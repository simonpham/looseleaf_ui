import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// The typing indicator's look: three dots or a cursive scrawl.
enum TypingVariant { dots, squiggle }

/// Whose pen writes: the other person's ink or your blue.
enum TypingPen { ink, you }

/// Typing indicator params.
///
/// Mirrors `TypingParams` in `src/lib/ink/recipes/typing-indicator-ink.ts`.
final class TypingParams {
  /// Params.
  const TypingParams({required this.variant, this.pen, this.pencil});

  final TypingVariant variant;

  /// Defaults to [TypingPen.ink].
  final TypingPen? pen;

  /// Draws the little pencil (default true).
  final bool? pencil;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'variant': variant.name,
    'pen': ?pen?.name,
    'pencil': ?pencil,
  };
}

/// Where the indicator's marks sit: baseline [y], dot or scrawl [xs], and the
/// [x0]–[x1] span.
///
/// Mirrors `typingGeometry` in `src/lib/ink/recipes/typing-indicator-ink.ts`.
({double y, List<double> xs, double x0, double x1, double span}) typingGeometry(
  double w,
  double h,
  TypingVariant variant,
) {
  final y = h * 0.7;
  if (variant == TypingVariant.dots) {
    final gap = clamp(h * 0.62, 10, 18);
    final start = w * 0.14;
    final xs = [start, start + gap, start + 2 * gap];
    return (y: y, xs: xs, x0: xs[0], x1: xs[2], span: xs[2] - xs[0]);
  }
  final x0 = w * 0.1;
  final x1 = w * 0.62;
  return (y: y, xs: [x0, x1], x0: x0, x1: x1, span: x1 - x0);
}

List<Pt> _cursive(Ink ink, double x0, double y, double span, double amp) {
  final rng = ink.next('scrawl');
  final loops = math.max(3, JsMath.roundInt(span / (amp * 3.1)));
  final steps = loops * 12;
  final ph = rng.range(0, 1);
  final pts = <Pt>[];
  for (var i = 0; i <= steps; i++) {
    final t = i / steps;
    final a = (t * loops + ph) * JsMath.pi * 2;
    final k = 1 + 0.18 * JsMath.sin(t * 9 + ph * 6) + rng.gauss(0, 0.015);
    pts.add((
      x0 + span * t - amp * 1.1 * k * JsMath.sin(a),
      y - amp * 0.8 * k * JsMath.cos(a) - amp * 0.5 * JsMath.sin(t * JsMath.pi),
    ));
  }
  return pts;
}

void _pencilShape(Ink ink, double tx, double ty, double scale) {
  final l = 21 * scale,
      hw = 2.7 * scale,
      cone = 5.4 * scale,
      ferrule = 2.2 * scale,
      eraser = 3.2 * scale;
  final body = rectPoly(cone, -hw, l - cone, 2 * hw);
  final List<Pt> tip = [
    (0, 0),
    (cone + 0.4, -hw * 0.92),
    (cone + 0.4, hw * 0.92),
  ];
  ink.group(
    GroupAttrs(
      transform:
          'translate(${JsMath.toFixed(tx, 2)} ${JsMath.toFixed(ty, 2)}) '
          'rotate(-38)',
    ),
    () {
      blobFill(
        ink,
        body,
        PaintKey.lemon,
        alpha: 0.92,
        mis: 0.5,
        rough: 0.3,
      );
      blobFill(ink, tip, PaintKey.kraft, alpha: 0.95, mis: 0.4, rough: 0.2);
      blobFill(
        ink,
        rectPoly(l, -hw, ferrule + eraser, 2 * hw),
        PaintKey.bubblegum,
        alpha: 0.9,
        mis: 0.4,
        rough: 0.2,
      );
      ink
        ..stroke(
          [(cone - 1, -hw), (l, -hw - 0.2), (l + ferrule + eraser, -hw + 0.1)],
          PenName.inkFine,
          const StrokeOpts(simple: true, wobble: 0.5, width: 0.9),
        )
        ..stroke(
          [(cone - 1, hw), (l, hw + 0.2), (l + ferrule + eraser, hw - 0.1)],
          PenName.inkFine,
          const StrokeOpts(simple: true, wobble: 0.5, width: 0.9),
        )
        ..stroke(
          [(cone, -hw), (0.2, 0), (cone, hw)],
          PenName.inkFine,
          const StrokeOpts(simple: true, wobble: 0.4, width: 0.9),
        )
        ..stroke(
          [(l, -hw), (l + 0.4, hw)],
          PenName.inkFine,
          const StrokeOpts(simple: true, wobble: 0.3, width: 0.8),
        )
        ..stroke(
          [(0, 0), (1.9 * scale, 0)],
          PenName.pencil,
          const StrokeOpts(simple: true, width: 1.5),
        );
    },
    Material.top,
  );
}

/// The "someone is typing" mark: three felt dots (or a cursive scrawl) and
/// a little pencil, each a `data-part` for animation.
///
/// Mirrors `typingIndicatorRecipe` in
/// `src/lib/ink/recipes/typing-indicator-ink.ts`.
final Recipe<TypingParams> typingIndicatorRecipe = defineRecipe<TypingParams>(
  id: 'typing-indicator',
  kind: 'typing',
  layers: const [LayerName.rest],
  pad: 10,
  draw: _draw,
);

void _draw(Ink ink, Box size, TypingParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final g = typingGeometry(w, h, params.variant);
  final felt = switch ((ctx.calm, params.pen ?? TypingPen.ink)) {
    (true, _) => PenName.pencilFine,
    (false, TypingPen.you) => PenName.blue,
    (false, TypingPen.ink) => PenName.ink,
  };
  final r = clamp(h * 0.1, 1.8, 3.2);
  ink.layer(LayerName.rest, () {
    if (params.variant == TypingVariant.dots) {
      for (final (i, x) in g.xs.indexed) {
        ink.part('dot-${i + 1}', () {
          ink.dot(
            x + ink.rng.gauss(0, 0.3),
            g.y + ink.rng.gauss(0, 0.4),
            r *
                switch (i) {
                  1 => 1.05,
                  _ => 0.95,
                },
            felt,
            const StrokeOpts(alpha: 1),
          );
        }, Material.top);
      }
    }
    if (params.variant == TypingVariant.squiggle) {
      ink.part('line', () {
        ink.stroke(
          _cursive(ink, g.x0, g.y - 2, g.span, clamp(h * 0.16, 2.6, 5)),
          felt,
          const StrokeOpts(
            wobble: 0.5,
            speed: 1.05,
            start: StrokeStart.pool,
            end: StrokeEnd.flick,
          ),
        );
      }, Material.top);
    }
    if (params.pencil ?? true) {
      ink.part(
        'pencil',
        () => _pencilShape(
          ink,
          g.x1 + clamp(h * 0.32, 5, 9),
          g.y + 0.5,
          clamp(h / 24, 0.7, 1.4),
        ),
        Material.top,
      );
    }
  });
}
