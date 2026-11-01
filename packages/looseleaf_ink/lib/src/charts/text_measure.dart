import 'dart:math' as math;

/// The font a chart label is set in, for width estimates.
///
/// Mirrors `LabelFont` in `src/lib/ink/charts/chart-scale.ts`.
enum LabelFont {
  script(0.4),
  hand(0.47),
  mono(0.6);

  const LabelFont(this.em);

  /// The average glyph width, in ems.
  final double em;
}

const String _narrow = "il.,:;!'|";
const String _wide = 'mwMW%@';

/// The estimated width of [s] at [size] px in [font].
///
/// Mirrors `textWidth` in `src/lib/ink/charts/chart-scale.ts`.
double textWidth(String s, double size, [LabelFont font = LabelFont.script]) {
  final base = font.em;
  var em = 0.0;
  for (final rune in s.runes) {
    final ch = String.fromCharCode(rune);
    em += switch (ch) {
      ' ' => base * 0.55,
      _ when _narrow.contains(ch) => base * 0.6,
      _ when _wide.contains(ch) => base * 1.45,
      _ when rune >= 0x41 && rune <= 0x5A => base * 1.12,
      _ => base,
    };
  }
  return em * size;
}

/// Extra room a label gets over its estimate (`LABEL_SLACK`).
const double labelSlack = 1.15;

/// The least gap between labels (`LABEL_GAP`).
const double labelGap = 8;

/// [textWidth] with [labelSlack].
///
/// Mirrors `labelWidth` in `src/lib/ink/charts/chart-scale.ts`.
double labelWidth(String s, double size, [LabelFont font = LabelFont.script]) =>
    textWidth(s, size, font) * labelSlack;

/// The category labels to show, at an even stride, so labels of [widths]
/// [pitch] px apart keep [gap] between them.
///
/// Mirrors `pickLabelIndices` in `src/lib/ink/charts/chart-scale.ts`.
({List<int> idx, int stride}) pickLabelIndices(
  List<double> widths,
  double pitch, [
  double gap = labelGap,
]) {
  final n = widths.length;
  if (n == 0) return (idx: <int>[], stride: 1);
  final last = n - 1;
  bool clear(int a, int b) =>
      (b - a) * pitch - (widths[a] + widths[b]) / 2 >= gap;
  List<int> run(int s) => [for (var i = 0; i < n; i += s) i];
  bool valid(List<int> p) {
    for (var k = 1; k < p.length; k++) {
      if (!clear(p[k - 1], p[k])) return false;
    }
    return true;
  }

  var s = 1;
  while (s < n && !valid(run(s))) {
    s++;
  }
  int upTo(double k) => math.min(last, (s * k).ceil());
  const tries = [(1.5, false), (1.34, true), (2.0, true)];
  for (final (k, tail) in tries) {
    for (var t = s; t <= upTo(k); t++) {
      final p = run(t);
      if (!valid(p)) continue;
      final rem = last % t;
      if (rem == 0) return (idx: p, stride: t);
      if (tail && 2 * rem > t && clear(p.last, last)) {
        return (idx: [...p, last], stride: t);
      }
    }
  }
  final p = run(s);
  if (p.last != last && clear(p.last, last)) p.add(last);
  return (idx: p, stride: s);
}

/// The [items] that keep [gap] between them, left to right, keeping the
/// last one when it fits after dropping earlier ones; [x] and [w] read an
/// item's centre and width.
///
/// Mirrors `clearLabels` in `src/lib/ink/charts/chart-scale.ts`.
List<T> clearLabels<T>(
  List<T> items,
  double Function(T) x,
  double Function(T) w, [
  double gap = labelGap,
]) {
  final out = <T>[];
  bool clear(T a, T b) => x(b) - x(a) - (w(a) + w(b)) / 2 >= gap;
  for (final (k, it) in items.indexed) {
    if (out.isEmpty || clear(out.last, it)) {
      out.add(it);
      continue;
    }
    if (k != items.length - 1) continue;
    while (out.length > 1 && !clear(out.last, it)) {
      out.removeLast();
    }
    if (clear(out.last, it)) out.add(it);
  }
  return out;
}
