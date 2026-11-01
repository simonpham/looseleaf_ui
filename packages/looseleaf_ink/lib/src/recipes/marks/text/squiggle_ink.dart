import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:looseleaf_ink/src/recipes/marks/marks.dart';

/// The squiggle's pattern.
///
/// Mirrors `SquiggleKind` (and `SQUIGGLE_KINDS`) in
/// `src/lib/ink/recipes/squiggle-ink.ts`.
enum SquiggleKind { wavy, zigzag, loops, scallops, dashes, dots }

/// Which way a squiggle runs.
enum SquiggleOrientation { horizontal, vertical }

/// Squiggle recipe params.
///
/// Mirrors `SquiggleParams` in `src/lib/ink/recipes/squiggle-ink.ts`.
final class SquiggleParams {
  /// Params.
  const SquiggleParams({
    required this.kind,
    required this.orientation,
    required this.tone,
    required this.weight,
    this.animate,
  });

  final SquiggleKind kind;
  final SquiggleOrientation orientation;
  final MarkPen tone;
  final MarkWeight weight;
  final bool? animate;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'orientation': orientation.name,
    'tone': tone.id,
    'weight': weight.name,
    'animate': ?animate,
  };
}

/// A decorative hand-drawn divider: wavy, zigzag, loops, scallops, dashes
/// or dots, horizontal or vertical.
///
/// Mirrors `squiggleRecipe` in `src/lib/ink/recipes/squiggle-ink.ts`.
final Recipe<SquiggleParams> squiggleRecipe = defineRecipe<SquiggleParams>(
  id: 'squiggle',
  kind: 'squiggle',
  layers: const [LayerName.rest],
  pad: 8,
  draw: _draw,
);

void _draw(Ink ink, Box size, SquiggleParams p, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final vertical = p.orientation == SquiggleOrientation.vertical;
  final long = switch (vertical) {
    true => h,
    false => w,
  };
  final thick = switch (vertical) {
    true => w,
    false => h,
  };
  final (:pen, :width, dry: _) = markPen(p.tone, p.weight, 18);
  final rng = ink.next('squiggle');
  final lines = _lines(rng, p, long, thick);
  ink.layer(LayerName.rest, () {
    void draw() {
      if (p.animate ?? false) {
        revealMark(
          ink,
          id: markRevealId(ctx.seed, 's'),
          lines: lines,
          pen: pen,
          box: Box(long, thick),
          pad: 10,
          width: width,
          opts: const StrokeOpts(dry: structuralDry),
          revealWidth: math.max(6, thick * 0.8),
        );
        return;
      }
      ink.lines(lines, pen, StrokeOpts(width: width, dry: structuralDry));
    }

    if (vertical) {
      ink.group(
        GroupAttrs(
          transform: 'translate(${JsMath.numberToString(w)} 0) rotate(90)',
        ),
        draw,
      );
      return;
    }
    draw();
  });
}

List<Line> _lines(Rng rng, SquiggleParams p, double long, double thick) {
  final y = thick / 2;
  final amp = math.max(1.6, math.min(thick * 0.32, 5)).toDouble();
  const x0 = 2.0;
  final x1 = long - 2;
  final so = StrokeOpts(
    end: StrokeEnd.flick,
    wobble: 0.5,
    speed: 1.15,
    simple: long > 220,
  );
  switch (p.kind) {
    case SquiggleKind.wavy:
      return [
        for (final l in squiggleLines(
          rng,
          x0,
          y,
          x1 - x0,
          h: math.max(8, thick),
          amp: amp / 3,
        ))
          Line(
            l.pts,
            o: (l.o ?? const StrokeOpts()).copyWith(simple: long > 220),
            pen: l.pen,
          ),
      ];
    case SquiggleKind.zigzag:
      final pitch = math.max(9, amp * 3.4).toDouble();
      final pts = <Pt>[];
      var x = x0;
      var up = rng.chance(0.5);
      while (x <= x1) {
        final a = switch (up) {
          true => -amp,
          false => amp,
        };
        pts.add((x, y + a * rng.range(0.75, 1.1)));
        x += pitch * rng.range(0.85, 1.15);
        up = !up;
      }
      return [Line(pts, o: so.copyWith(poly: true, round: 0.7))];
    case SquiggleKind.loops:
      final pitch = math.max(12, amp * 4.2).toDouble(), r = pitch * 0.42;
      final pts = <Pt>[];
      final n = math.max(6, JsMath.roundInt((x1 - x0) / pitch));
      for (var i = 0; i <= n * 14; i++) {
        final s = i / 14;
        final th = s * JsMath.pi * 2;
        pts.add((
          x0 +
              ((x1 - x0) / n) * s -
              r * JsMath.sin(th) * 0.9 +
              rng.gauss(0, 0.05),
          y - r * 0.55 * JsMath.cos(th) * (1 + 0.05 * JsMath.sin(s * 2.3)),
        ));
      }
      return [Line(pts, o: so)];
    case SquiggleKind.scallops:
      final pitch = math.max(16, amp * 5.2).toDouble();
      final n = math.max(3, JsMath.roundInt((x1 - x0) / pitch));
      final pts = <Pt>[];
      for (var i = 0; i < n; i++) {
        final a = x0 + ((x1 - x0) / n) * i, b = x0 + ((x1 - x0) / n) * (i + 1);
        final from = switch (i) {
          0 => 0,
          _ => 1,
        };
        for (var k = from; k <= 8; k++) {
          final t = k / 8;
          pts.add((
            a + (b - a) * t + rng.gauss(0, 0.15),
            y +
                amp * 1.0 -
                JsMath.sin(JsMath.pi * t) * amp * 2.1 * rng.range(0.92, 1.06),
          ));
        }
      }
      return [Line(pts, o: so)];
    case SquiggleKind.dashes:
      final lines = <Line>[];
      var x = x0 + rng.range(0, 4);
      while (x < x1 - 4) {
        final len = rng.range(6, 11);
        lines.add(
          Line(
            [
              (x, y + rng.gauss(0, 0.5)),
              (math.min(x1, x + len), y + rng.gauss(0, 0.6)),
            ],
            o: const StrokeOpts(
              start: StrokeStart.soft,
              end: StrokeEnd.soft,
              wobble: 0.4,
              simple: true,
            ),
          ),
        );
        x += len + rng.range(5, 9);
      }
      return lines;
    case SquiggleKind.dots:
      final lines = <Line>[];
      var x = x0 + 3;
      while (x < x1) {
        final big = switch (p.weight) {
          MarkWeight.brush => 1.5,
          _ => 1.0,
        };
        final r = rng.range(0.9, 1.5) * big;
        lines.add(
          Line(
            [
              (x, y + rng.gauss(0, 0.5)),
              (x + r * 0.6, y + rng.gauss(0, 0.5) + 0.4),
            ],
            o: const StrokeOpts(
              start: StrokeStart.pool,
              end: StrokeEnd.pool,
              wobble: 0.2,
              simple: true,
              width: 1.7,
            ),
          ),
        );
        x += rng.range(9, 13);
      }
      return lines;
  }
}
