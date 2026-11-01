import 'dart:math' as math;

import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

/// The vertical metrics of one line of text, in pixels.
///
/// Mirrors `LineMetrics` in `src/lib/ink/recipes/text-marks-ink.ts`.
final class LineMetrics {
  /// Line metrics.
  const LineMetrics({
    required this.fs,
    required this.base,
    required this.xh,
    required this.cap,
    required this.desc,
    required this.ch,
  });

  /// Font size.
  final double fs;

  /// Baseline, from the top of the line box.
  final double base;

  /// x-height.
  final double xh;

  /// Cap height.
  final double cap;

  /// Descender depth.
  final double desc;

  /// Line box height.
  final double ch;

  /// Upstream's object shape.
  Map<String, Object?> toJson() => {
    'fs': fs,
    'base': base,
    'xh': xh,
    'cap': cap,
    'desc': desc,
    'ch': ch,
  };
}

/// One line of a marked text run: its metrics, whether it is the first or
/// last line, how many lines the run has and whether the mark draws itself
/// on.
///
/// Mirrors `LineParams` in `src/lib/ink/recipes/text-marks-ink.ts`.
final class LineParams {
  /// Line params.
  const LineParams({
    required this.metrics,
    required this.first,
    required this.last,
    required this.n,
    this.animate,
  });

  final LineMetrics metrics;
  final bool first;
  final bool last;

  /// Lines in the run.
  final int n;
  final bool? animate;

  double get fs => metrics.fs;
  double get base => metrics.base;
  double get xh => metrics.xh;
  double get cap => metrics.cap;
  double get desc => metrics.desc;
  double get ch => metrics.ch;

  /// Upstream's object shape (the metrics are flattened in).
  Map<String, Object?> toJson() => {
    ...metrics.toJson(),
    'first': first,
    'last': last,
    'n': n,
    if (animate case final bool a) 'animate': a,
  };
}

/// A font's vertical proportions, relative to its size.
///
/// Mirrors `FontRatios` in `src/lib/ink/recipes/text-marks-ink.ts`.
final class FontRatios {
  /// Font ratios.
  const FontRatios({
    required this.asc,
    required this.desc,
    required this.xh,
    required this.cap,
    required this.pdesc,
  });

  final double asc;
  final double desc;
  final double xh;
  final double cap;
  final double pdesc;
}

/// Ratios that fit most hand fonts.
///
/// Mirrors `GUESS_RATIOS` in `src/lib/ink/recipes/text-marks-ink.ts`.
const FontRatios guessRatios = FontRatios(
  asc: 1.06,
  desc: 0.53,
  xh: 0.52,
  cap: 0.74,
  pdesc: 0.22,
);

/// The metrics of a line [h] tall set at font size [fs].
///
/// Mirrors `lineMetrics` in `src/lib/ink/recipes/text-marks-ink.ts`.
LineMetrics lineMetrics(double h, double fs, [FontRatios r = guessRatios]) {
  final total = JsMath.or(r.asc + r.desc, 1);
  return LineMetrics(
    fs: math.max(6, JsMath.round(fs)),
    ch: JsMath.round(h),
    base: JsMath.round((r.asc / total) * h),
    xh: math.max(2, JsMath.round(r.xh * fs)),
    cap: math.max(3, JsMath.round(r.cap * fs)),
    desc: math.max(1, JsMath.round(r.pdesc * fs)),
  );
}

/// Highlighter tones; `id` is the upstream name.
enum HighlightTone {
  yellow('yellow', null, 1),
  pink('pink', PaintKey.bubblegum, 0.8),
  green('green', PaintKey.grass, 0.7),
  blue('blue', PaintKey.sky, 0.75),
  orange('orange', PaintKey.tangerine, 0.75),
  lilac('lilac', PaintKey.grape, 0.6),
  teal('teal', PaintKey.teal, 0.7);

  const HighlightTone(this.id, this.color, this.alpha);

  /// The upstream name.
  final String id;

  /// The paint, or null for the highlighter's own yellow.
  final PaintKey? color;
  final double alpha;
}

/// Pen tones for text marks; `id` is the upstream name.
enum MarkPen {
  ink('ink'),
  blue('blue'),
  red('red'),
  green('green'),
  pencil('pencil'),
  marker('marker'),
  orange('orange');

  const MarkPen(this.id);

  /// The upstream name.
  final String id;
}

/// Stroke weights for text marks.
enum MarkWeight { fine, regular, brush }

PenName _felt(MarkPen tone) => switch (tone) {
  MarkPen.ink => PenName.ink,
  MarkPen.blue => PenName.blue,
  MarkPen.red => PenName.redfelt,
  MarkPen.green => PenName.greenfelt,
  MarkPen.pencil => PenName.pencil,
  MarkPen.marker => PenName.terracotta,
  MarkPen.orange => PenName.orange,
};

PenName? _pencil(MarkPen tone) => switch (tone) {
  MarkPen.red => PenName.red,
  MarkPen.green => PenName.green,
  _ => null,
};

/// The pen, width and dryness a text mark draws with at font size [fs];
/// [pencil] prefers the pencil version of red and green.
///
/// Mirrors `markPen` in `src/lib/ink/recipes/text-marks-ink.ts`.
({PenName pen, double width, double dry}) markPen(
  MarkPen tone,
  MarkWeight weight,
  double fs, {
  bool pencil = false,
}) {
  final k = math.min(1.7, math.max(0.85, fs / 18));
  if (tone == MarkPen.marker) {
    return (pen: PenName.terracotta, width: 0.3 * k, dry: 1);
  }
  final base = switch (pencil) {
    true => _pencil(tone) ?? _felt(tone),
    false => _felt(tone),
  };
  final w = switch (weight == MarkWeight.regular && fs < 15) {
    true => MarkWeight.fine,
    false => weight,
  };
  if (w == MarkWeight.regular) return (pen: base, width: k, dry: 1);
  final pen = PenName.byId('${base.id}.${w.name}');
  if (pen == null) throw StateError('ink: no ${w.name} pen for ${base.id}');
  return (pen: pen, width: k, dry: 1);
}

/// The dryness of structural marks (arrows, brackets, rules).
///
/// Mirrors `STRUCTURAL_DRY` in `src/lib/ink/recipes/text-marks-ink.ts`.
const double structuralDry = 0.3;

/// The highlighter pen and options for [tone].
///
/// Mirrors `highlighterPen` in `src/lib/ink/recipes/text-marks-ink.ts`.
({Pen pen, StrokeOpts opts}) highlighterPen(HighlightTone tone) {
  final opts = switch (tone.color) {
    final PaintKey color => StrokeOpts(color: color, alpha: tone.alpha),
    null => const StrokeOpts(),
  };
  return (pen: PenName.hi, opts: opts);
}

/// How far a mark runs past the ends of the text at font size [fs].
///
/// Mirrors `overshoot` in `src/lib/ink/recipes/text-marks-ink.ts`.
double overshoot(double fs) => math.max(1.5, fs * 0.14);
