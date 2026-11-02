import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SketchpadReplayExample extends StatefulWidget {
  const SketchpadReplayExample({super.key});

  @override
  State<SketchpadReplayExample> createState() => _SketchpadReplayExampleState();
}

class _SketchpadReplayExampleState extends State<SketchpadReplayExample> {
  static const _maxWidth = Spacing.d512;

  late final _sketch = SketchpadController(strokes: _heart());

  static List<SketchPoint> _step(
    int n,
    (double, double) Function(double t) f,
  ) => [
    for (var i = 0; i <= n; i++)
      switch (f(i / n)) {
        (final x, final y) => (x, y, null),
      },
  ];

  static List<SketchStroke> _heart() => [
    SketchStroke(
      id: 'heart',
      tool: DrawTool.marker,
      color: SketchColor.bubblegum,
      size: 1.2,
      pts: _step(40, (t) {
        final a = t * math.pi * 2 - math.pi / 2;
        return (
          220 + 16 * math.pow(math.sin(a), 3) * 6.4,
          150 -
              (13 * math.cos(a) -
                      5 * math.cos(2 * a) -
                      2 * math.cos(3 * a) -
                      math.cos(4 * a)) *
                  6.4,
        );
      }),
    ),
    SketchStroke(
      id: 'arrow',
      tool: DrawTool.felt,
      color: SketchColor.ink,
      size: 1,
      pts: _step(12, (t) => (70 + t * 300, 240 - t * 170)),
    ),
    const SketchStroke(
      id: 'head',
      tool: DrawTool.felt,
      color: SketchColor.ink,
      size: 1,
      pts: [(336, 70, null), (372, 68, null), (366, 102, null)],
    ),
    SketchStroke(
      id: 'note',
      tool: DrawTool.brush,
      color: SketchColor.inkYou,
      size: 0.9,
      pts: _step(
        30,
        (t) => (90 + t * 250, 268 + math.sin(t * 16) * 9 * (1 - t / 2)),
      ),
    ),
  ];

  @override
  void dispose() {
    _sketch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d12,
      children: [
        Sketchpad(
          controller: _sketch,
          readOnly: true,
          replay: true,
          width: 440,
          height: Spacing.d320,
        ),
        Button(
          variant: ButtonVariant.outline,
          size: ButtonSize.sm,
          onPressed: _sketch.replay,
          child: const Text('Draw it again'),
        ),
      ],
    ),
  );
}
