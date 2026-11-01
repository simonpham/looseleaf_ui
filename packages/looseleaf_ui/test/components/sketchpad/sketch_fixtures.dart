import 'dart:math' as math;

import 'package:looseleaf_ui/looseleaf_ui.dart';

List<SketchPoint> _line(List<(double, double)> corners, {double step = 4}) {
  final out = <SketchPoint>[];
  for (var i = 0; i < corners.length - 1; i++) {
    final (x0, y0) = corners[i];
    final (x1, y1) = corners[i + 1];
    final n = math.max(
      1,
      (math.sqrt(math.pow(x1 - x0, 2) + math.pow(y1 - y0, 2)) / step).ceil(),
    );
    for (var k = 0; k < n; k++) {
      out.add((x0 + (x1 - x0) * k / n, y0 + (y1 - y0) * k / n, null));
    }
  }
  final (x, y) = corners.last;
  out.add((x, y, null));
  return out;
}

List<SketchPoint> _wave(
  double x0,
  double y,
  double w, {
  double amp = 8,
  double? pressure,
}) => [
  for (var x = x0; x <= x0 + w; x += 3)
    (x, y + amp * math.sin((x - x0) / 9), pressure),
];

/// A small house, a highlighter swipe, a wave and a sun, like the docs
/// thumbnail.
final List<SketchStroke> sketchFixture = [
  SketchStroke(
    id: 'roof',
    tool: DrawTool.felt,
    color: SketchColor.ink,
    size: 1,
    pts: _line([(150, 150), (210, 100), (270, 150)]),
  ),
  SketchStroke(
    id: 'wall',
    tool: DrawTool.felt,
    color: SketchColor.ink,
    size: 1,
    pts: _line([(160, 150), (160, 210), (260, 210), (260, 150)]),
  ),
  SketchStroke(
    id: 'fill',
    tool: DrawTool.marker,
    color: SketchColor.marker,
    size: 1,
    pts: _line([
      (170, 165),
      (250, 168),
      (172, 182),
      (248, 186),
      (172, 198),
      (246, 200),
    ]),
  ),
  SketchStroke(
    id: 'hi',
    tool: DrawTool.highlighter,
    color: SketchColor.hi,
    size: 1,
    pts: _line([(40, 40), (110, 40)]),
  ),
  SketchStroke(
    id: 'wave',
    tool: DrawTool.brush,
    color: SketchColor.inkYou,
    size: 1,
    pts: _wave(40, 260, 70, pressure: 0.7),
  ),
  SketchStroke(
    id: 'grass',
    tool: DrawTool.pencil,
    color: SketchColor.green,
    size: 1,
    pts: _line([(30, 225), (430, 222)]),
  ),
  SketchStroke(
    id: 'sun',
    tool: DrawTool.felt,
    color: SketchColor.tangerine,
    size: 1.9,
    pts: [
      for (var a = 0.0; a <= 2 * math.pi + 0.3; a += 0.25)
        (380 + 22 * math.cos(a), 70 + 22 * math.sin(a), null),
    ],
  ),
];
