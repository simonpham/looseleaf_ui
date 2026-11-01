import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:looseleaf_ink/src/recipes/marks/marks.dart';

/// Quote recipe params: [size] is the opening marks' height, [rule] adds a
/// pencil rule down the side.
///
/// Mirrors `QuoteParams` in `src/lib/ink/recipes/quote-ink.ts`.
final class QuoteParams {
  /// Params.
  const QuoteParams({
    required this.tone,
    required this.weight,
    required this.size,
    required this.rule,
    this.animate,
  });

  final MarkPen tone;
  final MarkWeight weight;
  final double size;
  final bool rule;
  final bool? animate;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'tone': tone.id,
    'weight': weight.name,
    'size': size,
    'rule': rule,
    'animate': ?animate,
  };
}

Line _mark(Rng rng, double x, double y, double s, bool opening) {
  double j() => rng.gauss(0, s * 0.012);
  final lean = rng.gauss(0, 0.04);
  double bend(double t) => JsMath.sin(t * JsMath.pi) * s * 0.09;
  final pts = <Pt>[];
  const n = 12;
  for (var i = 0; i <= n; i++) {
    final t = i / n;
    final px = switch (opening) {
      true => 0.66 - 0.54 * t - lean * t,
      false => 0.62 - 0.4 * t - lean * t,
    };
    final py = switch (opening) {
      true => 0.06 + 0.8 * t,
      false => 0.14 + 0.78 * t,
    };
    final curl = switch (opening) {
      true => -bend(t),
      false => bend(t) * 0.5,
    };
    pts.add((x + s * px + curl + j(), y + s * py + j()));
  }
  return Line(
    pts,
    o: switch (opening) {
      true => const StrokeOpts(
        start: StrokeStart.soft,
        end: StrokeEnd.pool,
        wobble: 0.4,
        speed: 0.8,
      ),
      false => const StrokeOpts(
        start: StrokeStart.pool,
        end: StrokeEnd.flick,
        wobble: 0.4,
        speed: 0.9,
      ),
    },
  );
}

/// Big hand-drawn quote marks around a pull quote, with an optional rule.
///
/// Mirrors `quoteRecipe` in `src/lib/ink/recipes/quote-ink.ts`.
final Recipe<QuoteParams> quoteRecipe = defineRecipe<QuoteParams>(
  id: 'quote',
  kind: 'quote',
  layers: const [LayerName.rest],
  pad: 14,
  draw: _draw,
);

void _draw(Ink ink, Box size, QuoteParams p, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final s = p.size;
  final c = s * 0.72;
  final Pen pen = switch (p.tone) {
    MarkPen.marker => PenName.inkBrush.spec.copyWith(
      color: PaintKey.marker,
      alpha: 0.88,
    ),
    _ => markPen(p.tone, MarkWeight.brush, 18).pen,
  };
  final rng = ink.next('quote');
  final marks = [
    _mark(rng.fork('o1'), 2, 2, s, true),
    _mark(rng.fork('o2'), 2 + s * 0.46, 2, s, true),
    _mark(rng.fork('c1'), w - c * 1.05, h - c * 1.0, c, false),
    _mark(rng.fork('c2'), w - c * 1.05 + c * 0.46, h - c * 1.0, c, false),
  ];
  final rtl = ctx.dir == Dir.rtl;
  final lines = switch (rtl) {
    true => [
      for (final l in marks)
        Line([for (final (x, y) in l.pts) (w - x, y)], o: l.o, pen: l.pen),
    ],
    false => marks,
  };
  final weightK = switch (p.weight) {
    MarkWeight.fine => 0.7,
    MarkWeight.brush => 1.25,
    MarkWeight.regular => 1.0,
  };
  final width = (s / 30) * 0.95 * weightK;
  ink.layer(LayerName.rest, () {
    void marksOnly() {
      if (p.animate ?? false) {
        revealMark(
          ink,
          id: markRevealId(ctx.seed, 'q'),
          lines: lines,
          pen: pen,
          box: size,
          pad: 20,
          width: width,
          revealWidth: s * 0.3,
        );
        return;
      }
      ink.lines(lines, pen, StrokeOpts(width: width));
    }

    marksOnly();
    if (!p.rule) return;
    final x = switch (rtl) {
      true => w - 3,
      false => 3.0,
    };
    ink.lines(
      [
        Line([(x, s + 10), (x, h - c - 4)], o: ruler),
      ],
      PenName.pencil,
      const StrokeOpts(width: 1.1),
    );
  });
}
