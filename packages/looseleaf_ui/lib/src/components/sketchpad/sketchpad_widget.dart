import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/sketchpad/sketchpad.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A drawing pad: a toolbar of pens, colors and widths over a sheet you
/// draw on with a mouse, a finger or a pen (pen pressure swells the line,
/// the pen's eraser end erases), or with the keyboard.
///
/// Its state lives in a [SketchpadController]: give one to read, drive or
/// export the drawing ([SketchpadController.toSvg],
/// [SketchpadController.toPng]); without one the pad keeps its own.
/// [onChanged] hears every new set of strokes. [child] replaces the
/// default layout ([SketchpadToolbar] with [SketchpadTools], [SketchpadUndo],
/// [SketchpadRedo], [SketchpadClear], [SketchpadColors] and
/// [SketchpadSizes], then a [SketchpadCanvas]) with your own parts.
///
/// The drawing is [width] × [height] units, scaled to the canvas. [readOnly]
/// hides the toolbar and shows the drawing as an image; [disabled] dims the
/// toolbar and stops input. [replay] draws the strokes on in order, at
/// [replaySpeed].
///
/// ```dart
/// Sketchpad(
///   controller: sketch,
///   tools: const [SketchTool.felt, SketchTool.highlighter, SketchTool.eraser],
///   onChanged: (strokes) => save(strokes),
/// )
/// ```
///
/// Mirrors upstream `src/components/ui/sketchpad.tsx`.
class Sketchpad extends StatefulWidget {
  const Sketchpad({
    super.key,
    this.controller,
    this.onChanged,
    this.tools = defaultTools,
    this.width = 640,
    this.height = 400,
    this.readOnly = false,
    this.disabled = false,
    this.replay = false,
    this.replaySpeed = 1,
    this.seed,
    this.focusNode,
    this.child,
  });

  /// Upstream's `DEFAULT_TOOLS`.
  static const List<SketchTool> defaultTools = [
    SketchTool.felt,
    SketchTool.pencil,
    SketchTool.marker,
    SketchTool.highlighter,
    SketchTool.eraser,
  ];

  /// The drawing's state; the pad keeps its own when null.
  final SketchpadController? controller;

  /// Called with the strokes after each stroke, erase, undo, redo or clear.
  final ValueChanged<List<SketchStroke>>? onChanged;

  /// The tools offered, in order.
  final List<SketchTool> tools;

  /// The drawing's width in units.
  final double width;

  /// The drawing's height in units.
  final double height;

  /// Shows the drawing without the toolbar or input.
  final bool readOnly;

  /// Stops input and dims the toolbar.
  final bool disabled;

  /// Draws the strokes on in order when shown.
  final bool replay;

  /// The replay's speed multiplier.
  final double replaySpeed;

  /// Pins the hand of the pad's ink.
  final String? seed;

  /// The canvas's focus node; the pad keeps its own when null.
  final FocusNode? focusNode;

  /// Your own layout of the pad's parts.
  final Widget? child;

  @override
  State<Sketchpad> createState() => _SketchpadState();
}

class _SketchpadState extends State<Sketchpad> with InkSeed {
  SketchpadController? _own;
  FocusNode? _ownFocus;
  late SketchpadController _listened = _controller;
  late List<SketchStroke> _reported;

  FocusNode get _canvasFocus =>
      widget.focusNode ?? (_ownFocus ??= FocusNode(debugLabel: 'sketchpad'));

  SketchpadController get _controller =>
      widget.controller ?? (_own ??= SketchpadController());

  @override
  void initState() {
    super.initState();
    _reported = _listened.strokes;
    _listened.addListener(_onChange);
  }

  @override
  void didUpdateWidget(Sketchpad oldWidget) {
    super.didUpdateWidget(oldWidget);
    final controller = _controller;
    if (identical(controller, _listened)) return;
    _listened.removeListener(_onChange);
    _listened = controller..addListener(_onChange);
    _reported = controller.strokes;
  }

  @override
  void dispose() {
    _listened.removeListener(_onChange);
    _own?.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  void _onChange() {
    final strokes = _listened.strokes;
    if (identical(strokes, _reported)) return;
    _reported = strokes;
    widget.onChanged?.call(strokes);
  }

  @override
  Widget build(BuildContext context) => SketchpadScope(
    controller: _controller,
    width: widget.width,
    height: widget.height,
    tools: widget.tools,
    readOnly: widget.readOnly,
    disabled: widget.disabled,
    replay: widget.replay,
    replaySpeed: widget.replaySpeed,
    seed: inkSeed(widget.seed),
    canvasFocusNode: _canvasFocus,
    child: widget.child ?? _defaultLayout(),
  );

  Widget _defaultLayout() => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: Spacing.d12,
    children: [
      if (!widget.readOnly)
        const SketchpadToolbar(
          children: [
            SketchpadTools(),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Spacing.d8,
              children: [SketchpadUndo(), SketchpadRedo(), SketchpadClear()],
            ),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: Spacing.d16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [SketchpadColors(), SketchpadSizes()],
              ),
            ),
          ],
        ),
      const SketchpadCanvas(),
    ],
  );
}
