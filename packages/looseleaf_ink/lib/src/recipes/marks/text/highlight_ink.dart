import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:looseleaf_ink/src/recipes/marks/marks.dart';

/// How much of the line a highlight covers.
enum HighlightCover { full, under }

/// Highlight recipe params.
///
/// Mirrors `HighlightParams` in `src/lib/ink/recipes/highlight-ink.ts`.
final class HighlightParams {
  /// Params.
  const HighlightParams({
    required this.line,
    required this.tone,
    this.fat,
    this.cover,
  });

  final LineParams line;
  final HighlightTone tone;

  /// Band thickness factor (1 when unset).
  final double? fat;
  final HighlightCover? cover;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    ...line.toJson(),
    'tone': tone.id,
    'fat': ?fat,
    if (cover case final HighlightCover c) 'cover': c.name,
  };
}

/// A highlighter swipe over one line of text, with a lighter second pass on
/// long runs.
///
/// Mirrors `highlightRecipe` in `src/lib/ink/recipes/highlight-ink.ts`.
final Recipe<HighlightParams> highlightRecipe = defineRecipe<HighlightParams>(
  id: 'highlight',
  kind: 'highlight',
  layers: const [LayerName.rest],
  pad: 10,
  draw: _draw,
);

void _draw(Ink ink, Box size, HighlightParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final p = params.line;
  final (:pen, :opts) = highlighterPen(params.tone);
  final o = overshoot(p.fs);
  final under = params.cover == HighlightCover.under;
  final top = switch (under) {
    true => p.base - p.xh * 0.42,
    false => p.base - p.cap - p.fs * 0.14,
  };
  final descK = switch (under) {
    true => 0.95,
    false => 0.85,
  };
  final bot = p.base + p.desc * descK + p.fs * 0.06;
  final band = math.min(h, (bot - top) * (params.fat ?? 1));
  final y = math.max(0, top + ((bot - top) - band) / 2).toDouble();
  final x0 = switch (p.first) {
    true => -o * 0.6,
    false => -1.0,
  };
  final x1 = switch (p.last) {
    true => w + o * 0.6,
    false => w + 1,
  };
  ink.layer(LayerName.rest, () {
    highlight(ink, x0, y, x1 - x0, band, pen: pen, opts: opts);
    if (ctx.calm || x1 - x0 <= 4.5 * p.fs) return;
    final r = ink.next('again');
    highlight(
      ink,
      x0 + r.range(0.1, 0.25) * (x1 - x0),
      y + r.range(-1.2, 1.2),
      (x1 - x0) * r.range(0.4, 0.62),
      band * 0.8,
      pen: pen,
      opts: opts.copyWith(alpha: (opts.alpha ?? 1) * 0.5),
    );
  });
}
