import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';

/// The line boxes of a marked run of text, its font size and the font's
/// vertical proportions: what the text-mark recipes draw from.
///
/// Mirrors `Measured` in upstream `src/hooks/use-mark-ink.tsx`.
class InkMarkMeasure {
  const InkMarkMeasure({
    required this.rects,
    required this.ratios,
    required this.fontSize,
  });

  /// One box per line, in the host's coordinates, quantised to 0.25 px.
  final List<Rect> rects;

  final FontRatios ratios;

  /// The CSS font size: Kevin Sans sizes are divided back by the hand
  /// face's size-adjust so strokes scale like upstream's.
  final double fontSize;

  /// Upstream's `MAX_MARK_LINES`: longer runs are not marked.
  static const int maxLines = 60;

  /// Measures the text under [host]: the tight line boxes of every
  /// [RenderParagraph] inside it, merged per line like the browser's
  /// `getClientRects()`. Falls back to [host]'s own box when it holds no
  /// text; null when it has no size yet.
  ///
  /// [kevinSansFamily] names the theme's Kevin Sans family, whose sizes are
  /// read as the hand face (`size-adjust: 88%`).
  static InkMarkMeasure? of(
    RenderBox host, {
    required String kevinSansFamily,
  }) {
    if (!host.hasSize || host.size.isEmpty) return null;
    final paragraphs = <RenderParagraph>[];
    _collect(host, paragraphs);
    final boxes = <Rect>[];
    for (final paragraph in paragraphs) {
      if (!paragraph.attached || !paragraph.hasSize) continue;
      final toHost = paragraph.getTransformTo(host);
      for (final box in _glyphBoxes(paragraph)) {
        boxes.add(MatrixUtils.transformRect(toHost, box.toRect()));
      }
    }
    final style = switch (paragraphs) {
      [final first, ...] => first.text.style,
      _ => null,
    };
    final scaler = switch (paragraphs) {
      [final first, ...] => first.textScaler,
      _ => TextScaler.noScaling,
    };
    final family = style?.fontFamily ?? '';
    final kevinSans = family.endsWith(kevinSansFamily);
    final adjust = switch (kevinSans) {
      true => _handSizeAdjust,
      false => 1.0,
    };
    final fontSize = scaler.scale(style?.fontSize ?? _cssBody) / adjust;
    final ratios = switch (style) {
      final TextStyle measured => _ratios(measured, adjust),
      null => guessRatios,
    };
    final merged = mergeLineRects(boxes);
    final rects = switch (merged.length) {
      0 => [Offset.zero & host.size],
      > maxLines => <Rect>[],
      _ => [for (final rect in merged) _quantise(rect)],
    };
    return InkMarkMeasure(rects: rects, ratios: ratios, fontSize: fontSize);
  }

  /// The boxes of the paragraph's words: merged per line they span the
  /// words but not the whitespace a line ends on, like an inline element's
  /// client rects.
  static List<TextBox> _glyphBoxes(RenderParagraph paragraph) {
    final text = paragraph.text.toPlainText(includeSemanticsLabels: false);
    return [
      for (final word in _word.allMatches(text))
        ...paragraph.getBoxesForSelection(
          TextSelection(baseOffset: word.start, extentOffset: word.end),
        ),
    ];
  }

  static final RegExp _word = RegExp(r'\S+');

  static const double _handSizeAdjust = 0.88;
  static const double _cssBody = 16;

  static void _collect(RenderObject node, List<RenderParagraph> out) {
    if (node is RenderParagraph) {
      out.add(node);
      return;
    }
    node.visitChildren((child) => _collect(child, out));
  }

  static double _q(double value) => (value * 4).roundToDouble() / 4;

  static Rect _quantise(Rect rect) => Rect.fromLTWH(
    _q(rect.left),
    _q(rect.top),
    _q(rect.width),
    _q(rect.height),
  );

  static final Map<String, FontRatios> _cache = {};

  static FontRatios _ratios(TextStyle style, double adjust) {
    final key = '${style.fontFamily}|${style.fontWeight}|${style.fontStyle}';
    final cached = _cache[key];
    if (cached != null) return _scaled(cached, adjust);
    final painter = TextPainter(
      text: TextSpan(
        text: 'x',
        style: TextStyle(
          fontFamily: style.fontFamily,
          fontFamilyFallback: style.fontFamilyFallback,
          fontWeight: style.fontWeight,
          fontStyle: style.fontStyle,
          fontSize: 100,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final metrics = painter.computeLineMetrics();
    painter.dispose();
    if (metrics.isEmpty) return guessRatios;
    final line = metrics.first;
    final ratios = FontRatios(
      asc: line.ascent / 100,
      desc: line.descent / 100,
      xh: guessRatios.xh,
      cap: guessRatios.cap,
      pdesc: guessRatios.pdesc,
    );
    _cache[key] = ratios;
    return _scaled(ratios, adjust);
  }

  static FontRatios _scaled(FontRatios ratios, double adjust) => FontRatios(
    asc: ratios.asc * adjust,
    desc: ratios.desc * adjust,
    xh: ratios.xh,
    cap: ratios.cap,
    pdesc: ratios.pdesc,
  );

  /// The line params of each box to draw: one per line, or with [box] one
  /// around all lines, like upstream `useMarkInk`'s `drawn`.
  List<(Rect, LineParams)> lines({required bool box, required bool animate}) {
    if (rects.isEmpty) return const [];
    final list = switch (box) {
      true => [_union()],
      false => rects,
    };
    return [
      for (final (index, rect) in list.indexed)
        (
          rect,
          LineParams(
            metrics: lineMetrics(
              switch (box) {
                true => math.min(
                  rect.height,
                  JsMath.round((ratios.asc + ratios.desc) * fontSize),
                ),
                false => rect.height,
              },
              fontSize,
              ratios,
            ),
            first: index == 0,
            last: index == list.length - 1,
            n: list.length,
            animate: animate,
          ),
        ),
    ];
  }

  Rect _union() {
    final left = rects.map((r) => r.left).reduce(math.min);
    final top = rects.map((r) => r.top).reduce(math.min);
    final right = rects.map((r) => r.right).reduce(math.max);
    final bottom = rects.map((r) => r.bottom).reduce(math.max);
    return _quantise(Rect.fromLTRB(left, top, right, bottom));
  }

  @override
  bool operator ==(Object other) =>
      other is InkMarkMeasure &&
      other.fontSize == fontSize &&
      other.ratios.asc == ratios.asc &&
      other.ratios.desc == ratios.desc &&
      listEquals(other.rects, rects);

  @override
  int get hashCode => Object.hash(fontSize, ratios.asc, Object.hashAll(rects));
}

/// Merges glyph-run boxes that share a line into one box per line: boxes
/// overlapping by more than 60% of the shorter one's height are one line.
///
/// Mirrors `mergeLineRects` in upstream `src/hooks/use-mark-ink.tsx`.
List<Rect> mergeLineRects(Iterable<Rect> list) {
  final out = <Rect>[];
  for (final rect in list) {
    if (!(rect.width >= 0.5 && rect.height >= 0.5)) continue;
    final same = out.indexWhere(
      (o) =>
          math.min(o.bottom, rect.bottom) - math.max(o.top, rect.top) >
          0.6 * math.min(o.height, rect.height),
    );
    if (same < 0) {
      out.add(rect);
      continue;
    }
    out[same] = out[same].expandToInclude(rect);
  }
  return out;
}
