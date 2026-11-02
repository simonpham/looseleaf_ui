import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SketchpadGraphPaperExample extends StatefulWidget {
  const SketchpadGraphPaperExample({super.key});

  @override
  State<SketchpadGraphPaperExample> createState() =>
      _SketchpadGraphPaperExampleState();
}

class _SketchpadGraphPaperExampleState
    extends State<SketchpadGraphPaperExample> {
  static const _maxWidth = 672.0;

  late final _sketch = SketchpadController(
    strokes: _plot(),
    tool: SketchTool.pencil,
  );

  static double _round(double n) => (n * 10).round() / 10;

  static List<SketchPoint> _along(
    int n,
    (double, double) Function(double t) f,
  ) => [
    for (var i = 0; i <= n; i++)
      switch (f(i / n)) {
        (final x, final y) => (_round(x), _round(y), null),
      },
  ];

  static SketchStroke _dot(String id, double cx, double cy) => SketchStroke(
    id: id,
    tool: DrawTool.felt,
    color: SketchColor.red,
    size: 1.9,
    pts: _along(
      10,
      (t) => (
        cx + 2.6 * math.cos(t * math.pi * 2),
        cy + 2.6 * math.sin(t * math.pi * 2),
      ),
    ),
  );

  static List<SketchStroke> _plot() => [
    const SketchStroke(
      id: 'axis-y',
      tool: DrawTool.pencil,
      color: SketchColor.ink,
      size: 1,
      pts: [(58, 36, null), (58, 168, null), (59, 300, null)],
    ),
    const SketchStroke(
      id: 'axis-x',
      tool: DrawTool.pencil,
      color: SketchColor.ink,
      size: 1,
      pts: [(58, 300, null), (270, 301, null), (486, 300, null)],
    ),
    const SketchStroke(
      id: 'arrow-y',
      tool: DrawTool.pencil,
      color: SketchColor.ink,
      size: 1,
      pts: [(49, 50, null), (58, 34, null), (67, 50, null)],
    ),
    const SketchStroke(
      id: 'arrow-x',
      tool: DrawTool.pencil,
      color: SketchColor.ink,
      size: 1,
      pts: [(470, 291, null), (488, 300, null), (470, 309, null)],
    ),
    SketchStroke(
      id: 'curve',
      tool: DrawTool.felt,
      color: SketchColor.inkYou,
      size: 1,
      pts: _along(
        48,
        (t) => (
          58 + t * 400,
          300 - 232 * (1 - math.pow(1 - t, 2.2)) - math.sin(t * 19) * 3,
        ),
      ),
    ),
    _dot('d1', 98, 252),
    _dot('d2', 178, 174),
    _dot('d3', 298, 99),
    _dot('d4', 418, 70),
  ];

  @override
  void dispose() {
    _sketch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: Sketchpad(
      controller: _sketch,
      tools: const [SketchTool.pencil, SketchTool.felt, SketchTool.eraser],
      width: 520,
      height: 340,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d12,
        children: [
          SketchpadToolbar(
            children: [
              SketchpadTools(),
              SketchpadColors(
                colors: [
                  SketchColor.ink,
                  SketchColor.inkYou,
                  SketchColor.red,
                  SketchColor.green,
                ],
              ),
              SketchpadSizes(),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d8,
                children: [
                  SketchpadUndo(),
                  SketchpadRedo(),
                  SketchpadClear(child: Text('Wipe')),
                ],
              ),
            ],
          ),
          SketchpadCanvas(
            paper: SketchpadPaper.graph,
            label: 'Sketchbook page',
          ),
        ],
      ),
    ),
  );
}
