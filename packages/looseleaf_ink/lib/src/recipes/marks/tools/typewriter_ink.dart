import 'dart:math' as math;

import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// One frame of a typing animation: the [text] shown from [at] ms.
///
/// Mirrors `TypeStep` in `src/lib/ink/recipes/typewriter-ink.ts`.
final class TypeStep {
  /// A step.
  const TypeStep({required this.at, required this.text});

  final int at;
  final String text;
}

/// How phrases follow each other: on new lines, or typed and backspaced in
/// turn.
enum TypingMode { lines, cycle }

/// Typing animation options.
///
/// Mirrors `TypingOptions` in `src/lib/ink/recipes/typewriter-ink.ts`.
final class TypingOptions {
  /// Options.
  const TypingOptions({
    required this.speed,
    required this.pause,
    required this.mode,
    required this.seed,
    this.loop = false,
  });

  /// Keys per second.
  final double speed;

  /// Pause between phrases, in ms.
  final double pause;
  final TypingMode mode;
  final bool loop;
  final String seed;
}

List<String> _keys(String s) => [
  for (final rune in s.runes) String.fromCharCode(rune),
];

double _hold(String ch) {
  if (ch == '\n') return 4;
  if (ch == '.' || ch == '!' || ch == '?') return 5;
  if (ch == ',' || ch == ';' || ch == ':') return 2.6;
  if (ch == ' ') return 1.15;
  return 1;
}

/// The keystroke timeline that types [phrases] like a person: punctuation
/// holds longer, every key jitters, backspaces are quick.
///
/// Upstream splits keys into graphemes with `Intl.Segmenter`; this splits
/// by code point, which matches for text without combining sequences.
///
/// Mirrors `typingPlan` in `src/lib/ink/recipes/typewriter-ink.ts`.
({List<TypeStep> steps, int total}) typingPlan(
  List<String> phrases,
  TypingOptions o,
) {
  final rng = Rng('typing|${o.seed}');
  final base = 1000 / math.max(1, o.speed);
  final steps = <TypeStep>[const TypeStep(at: 0, text: '')];
  var t = 0.0;
  var page = '';
  final typed = <String>[];
  void push() => steps.add(TypeStep(at: JsMath.roundInt(t), text: page));
  void type(String s) {
    for (final ch in _keys(s)) {
      final prev = switch (typed) {
        [..., final last] => last,
        _ => '',
      };
      t += base * _hold(prev) * (0.62 + 0.76 * rng());
      page += ch;
      typed.add(ch);
      push();
    }
  }

  void backspace() {
    t += (base / 3) * (0.7 + 0.6 * rng());
    page = page.substring(0, page.length - typed.removeLast().length);
    push();
  }

  if (o.mode == TypingMode.cycle) {
    for (final (i, p) in phrases.indexed) {
      type(p);
      if (i < phrases.length - 1) {
        t += o.pause;
        while (typed.isNotEmpty) {
          backspace();
        }
        t += base * 3;
      }
    }
  }
  if (o.mode == TypingMode.lines) {
    for (final (i, p) in phrases.indexed) {
      if (i > 0) {
        t += o.pause * 0.4;
        page += '\n';
        typed.add('\n');
        push();
      }
      type(p);
    }
  }
  if (o.loop) {
    t += o.pause;
    if (o.mode == TypingMode.cycle) {
      while (typed.isNotEmpty) {
        backspace();
      }
    }
    if (o.mode == TypingMode.lines) {
      page = '';
      typed.clear();
      push();
    }
    t += base * 4;
    steps.add(TypeStep(at: JsMath.roundInt(t), text: ''));
  }
  return (steps: steps, total: JsMath.roundInt(t));
}

/// The typewriter caret's shape.
enum CaretShape { block, bar, underscore }

/// Typewriter caret params.
///
/// Mirrors `CaretParams` in `src/lib/ink/recipes/typewriter-ink.ts`.
final class CaretParams {
  /// Params.
  const CaretParams({required this.shape});

  final CaretShape shape;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'shape': shape.name};
}

/// The typewriter caret: an inked block, a bar or an underscore.
///
/// Mirrors `typewriterCaretRecipe` in `src/lib/ink/recipes/typewriter-ink.ts`.
final Recipe<CaretParams> typewriterCaretRecipe = defineRecipe<CaretParams>(
  id: 'typewriter-caret',
  kind: 'typewriter-caret',
  layers: const [LayerName.rest],
  pad: 3,
  draw: (ink, size, params, ctx) {
    final Box(:w, :h) = size;
    ink.layer(LayerName.rest, () {
      switch (params.shape) {
        case CaretShape.block:
          blobFill(
            ink,
            roundRectPoly(0.5, 0.5, w - 1, h - 1, 1),
            PaintKey.ink,
            alpha: 0.9,
            mis: 0.5,
            material: Material.wash,
          );
        case CaretShape.bar:
          ink.lines(
            [
              Line(
                seg(w / 2, 0.5, w / 2 + 0.4, h - 0.5, 0.4, 5),
                o: const StrokeOpts(
                  start: StrokeStart.pool,
                  end: StrokeEnd.soft,
                ),
              ),
            ],
            PenName.ink,
            const StrokeOpts(width: 1.25),
          );
        case CaretShape.underscore:
          ink.lines(
            [
              Line(
                seg(0.5, h - 1.6, w - 0.5, h - 1.9, 0.3, 4),
                o: const StrokeOpts(
                  start: StrokeStart.soft,
                  end: StrokeEnd.flick,
                ),
              ),
            ],
            PenName.ink,
            const StrokeOpts(width: 1.35),
          );
      }
    });
  },
);
