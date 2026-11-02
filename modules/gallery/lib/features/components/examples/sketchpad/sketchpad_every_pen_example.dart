import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SketchpadEveryPenExample extends StatefulWidget {
  const SketchpadEveryPenExample({super.key});

  @override
  State<SketchpadEveryPenExample> createState() =>
      _SketchpadEveryPenExampleState();
}

class _SketchpadEveryPenExampleState extends State<SketchpadEveryPenExample> {
  static const _maxWidth = 672.0;
  static const _tools = [
    (DrawTool.felt, SketchColor.ink),
    (DrawTool.brush, SketchColor.inkYou),
    (DrawTool.pencil, SketchColor.ink),
    (DrawTool.marker, SketchColor.tangerine),
    (DrawTool.highlighter, SketchColor.hi),
  ];

  late final _sketch = SketchpadController(
    strokes: [
      for (final (row, (tool, color)) in _tools.indexed)
        SketchStroke(
          id: tool.name,
          tool: tool,
          color: color,
          size: 1,
          pts: [
            for (var i = 0; i < 112; i++)
              (
                34 + i * 5.2 + 10 * math.cos(i * 0.62),
                52 + row * 62 + 13 * math.sin(i * 0.62) - 4 * math.sin(i / 9),
                0.55 + 0.4 * math.cos(i * 0.62),
              ),
          ],
        ),
    ],
  );

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
      readOnly: true,
      height: 330,
    ),
  );
}
