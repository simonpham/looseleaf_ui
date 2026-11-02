import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SketchpadPostcardExample extends StatefulWidget {
  const SketchpadPostcardExample({super.key});

  @override
  State<SketchpadPostcardExample> createState() =>
      _SketchpadPostcardExampleState();
}

class _SketchpadPostcardExampleState extends State<SketchpadPostcardExample> {
  static const _maxWidth = 768.0;
  static const _previewWidth = 176.0;
  static const _width = 480.0;
  static const _height = 320.0;
  static const _tau = math.pi * 2;

  late final _sketch = SketchpadController(strokes: _start());
  late final _preview = SketchpadController(strokes: _sketch.strokes);
  var _copied = false;

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

  static List<SketchPoint> _line(
    (double, double) a,
    (double, double) b, [
    int n = 6,
  ]) => _along(n, (t) => (a.$1 + (b.$1 - a.$1) * t, a.$2 + (b.$2 - a.$2) * t));

  static List<SketchPoint> _heart(double cx, double cy, double k) =>
      _along(36, (t) {
        final a = t * _tau - math.pi / 2;
        return (
          cx + 16 * math.pow(math.sin(a), 3) * k,
          cy -
              (13 * math.cos(a) -
                      5 * math.cos(2 * a) -
                      2 * math.cos(3 * a) -
                      math.cos(4 * a)) *
                  k,
        );
      });

  static List<SketchStroke> _start() => [
    SketchStroke(
      id: 'sun',
      tool: DrawTool.felt,
      color: SketchColor.tangerine,
      size: 1.1,
      pts: _along(
        28,
        (t) => (
          388 + 24 * math.cos(t * _tau * 1.03 - 1.6),
          70 + 24 * math.sin(t * _tau * 1.03 - 1.6),
        ),
      ),
    ),
    for (var i = 0; i < 6; i++)
      SketchStroke(
        id: 'ray$i',
        tool: DrawTool.felt,
        color: SketchColor.tangerine,
        size: 1.1,
        pts: _along(3, (t) {
          final a = (i / 6) * _tau - 0.4;
          return (
            388 + (36 + 12 * t) * math.cos(a),
            70 + (36 + 12 * t) * math.sin(a),
          );
        }),
      ),
    SketchStroke(
      id: 'sail',
      tool: DrawTool.marker,
      color: SketchColor.red,
      size: 1,
      pts: [
        ..._line((233, 208), (281, 208), 5),
        ..._line((274, 196), (235, 196), 5),
        ..._line((263, 184), (236, 184), 4),
        ..._line((255, 172), (237, 172), 3),
        ..._line((249, 160), (238, 160), 3),
        ..._line((243, 148), (239, 148), 2),
      ],
    ),
    SketchStroke(
      id: 'sail-edge',
      tool: DrawTool.felt,
      color: SketchColor.ink,
      size: 0.8,
      pts: [
        ..._line((226, 118), (226, 214), 8),
        ..._line((226, 214), (288, 214)),
        ..._line((288, 214), (226, 118), 8),
      ],
    ),
    SketchStroke(
      id: 'mast',
      tool: DrawTool.felt,
      color: SketchColor.ink,
      size: 1,
      pts: [
        ..._line((220, 226), (220, 100), 10),
        ..._line((221, 102), (246, 111), 4),
        ..._line((246, 111), (221, 120), 4),
      ],
    ),
    SketchStroke(
      id: 'hull',
      tool: DrawTool.felt,
      color: SketchColor.ink,
      size: 1,
      pts: [
        ..._line((150, 226), (292, 226), 10),
        ..._line((292, 226), (270, 254), 5),
        ..._line((270, 254), (172, 254), 8),
        ..._line((172, 254), (150, 226), 5),
      ],
    ),
    SketchStroke(
      id: 'sea',
      tool: DrawTool.felt,
      color: SketchColor.inkYou,
      size: 1,
      pts: _along(
        70,
        (t) => (34 + t * 412, 274 + 7 * math.sin(t * _tau * 8)),
      ),
    ),
    SketchStroke(
      id: 'heart',
      tool: DrawTool.marker,
      color: SketchColor.red,
      size: 1,
      pts: _heart(84, 86, 1.7),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _sketch.addListener(_sync);
  }

  void _sync() => setState(() => _preview.strokes = _sketch.strokes);

  Future<void> _copySvg() => Clipboard.setData(
    ClipboardData(
      text: _sketch.toSvg(width: _width, height: _height, title: 'Postcard'),
    ),
  );

  Future<void> _copyJson() async {
    final json = jsonEncode([
      for (final stroke in _sketch.strokes)
        {
          'id': stroke.id,
          'tool': stroke.tool.name,
          'color': stroke.color.id,
          'size': stroke.size,
          'pts': [
            for (final (x, y, pressure) in stroke.pts) [x, y, ?pressure],
          ],
        },
    ]);
    await Clipboard.setData(ClipboardData(text: json));
    if (!mounted) return;
    setState(() => _copied = true);
  }

  @override
  void dispose() {
    _sketch
      ..removeListener(_sync)
      ..dispose();
    _preview.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final empty = _sketch.strokes.isEmpty;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d16,
        children: [
          Expanded(
            child: Sketchpad(
              controller: _sketch,
              tools: const [
                SketchTool.felt,
                SketchTool.marker,
                SketchTool.eraser,
              ],
              width: _width,
              height: _height,
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
                          SketchColor.tangerine,
                          SketchColor.teal,
                          SketchColor.grape,
                        ],
                      ),
                      SketchpadUndo(),
                    ],
                  ),
                  SketchpadCanvas(
                    paper: SketchpadPaper.ruled,
                    label: 'Postcard',
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: _previewWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d8,
              children: [
                Text(
                  'Preview',
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 24,
                    cssLineHeight: 1,
                  ),
                ),
                Sketchpad(
                  controller: _preview,
                  readOnly: true,
                  width: _width,
                  height: _height,
                ),
                Text(
                  '${_sketch.strokes.length} strokes',
                  style: theme.typography.interface(
                    cssSize: 14,
                    color: theme.colors.inkMuted,
                  ),
                ),
                Button(
                  size: ButtonSize.sm,
                  disabled: empty,
                  onPressed: _copySvg,
                  child: const Text('Copy as SVG'),
                ),
                Button(
                  size: ButtonSize.sm,
                  variant: ButtonVariant.outline,
                  disabled: empty,
                  onPressed: _copyJson,
                  child: Text(switch (_copied) {
                    true => 'Copied',
                    false => 'Copy JSON',
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
