import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/ink_mark_measure.dart';
import 'package:looseleaf_ui/src/components/foundation/ink_mark_surface.dart';
import 'package:looseleaf_ui/src/components/foundation/span_text_style.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Builds the ink source of one marked line from its [LineParams].
typedef InkMarkSourceBuilder = InkSource Function(LineParams line);

/// Draws a text mark (underline, highlight, strike, circle, …) on the text
/// in [child], measured from its laid-out line boxes: one drawing per line
/// that starts and stops where the words do, or with [box] one around
/// every line.
///
/// The text stays ordinary text; the drawings are excluded from semantics
/// and hit testing. Line `i` is drawn with seed `seed:i` and, with
/// [animate], draws on `i × 380 ms` after [delay].
///
/// Mirrors upstream `useMarkInk` (`src/hooks/use-mark-ink.tsx`). Text is
/// found in every [RenderParagraph] under [child]; a child without text is
/// marked as one box. Inside a [WidgetSpan] the text takes the enclosing
/// span's style ([SpanTextStyle]), like the inline element it mirrors.
class InkMark extends StatefulWidget {
  const InkMark({
    super.key,
    required this.source,
    required this.seed,
    required this.child,
    this.box = false,
    this.over = false,
    this.draw = InkMarkDraw.wipe,
    this.animate = false,
    this.show = true,
    this.delay = Duration.zero,
  });

  /// The source of each line.
  final InkMarkSourceBuilder source;

  final String seed;

  /// The marked content, usually a [Text].
  final Widget child;

  /// Draw one mark around all lines (upstream `mode: "box"`).
  final bool box;

  /// Draw over the text instead of behind it.
  final bool over;

  final InkMarkDraw draw;
  final bool animate;

  /// Show the mark; turning it back on replays the draw-on.
  final bool show;
  final Duration delay;

  /// The wait between one line's draw-on and the next.
  static const Duration lineStagger = Duration(milliseconds: 380);

  @override
  State<InkMark> createState() => _InkMarkState();
}

class _InkMarkState extends State<InkMark> {
  InkMarkMeasure? _measured;
  bool _scheduled = false;

  void _onLayout(RenderBox box) {
    if (_scheduled) return;
    _scheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!mounted || !box.attached) return;
      final family = LooseleafTheme.of(context).typography.fontFamily;
      final next = InkMarkMeasure.of(box, kevinSansFamily: family);
      if (next == null || next == _measured) return;
      setState(() => _measured = next);
    });
  }

  @override
  Widget build(BuildContext context) {
    final measured = _measured;
    final marks = <Widget>[
      if (widget.show && measured != null)
        for (final (index, (rect, line))
            in measured.lines(box: widget.box, animate: widget.animate).indexed)
          Positioned.fromRect(
            rect: rect,
            child: InkMarkSurface(
              source: widget.source(line),
              seed: '${widget.seed}:$index',
              draw: widget.draw,
              animate: widget.animate,
              delay: widget.delay + InkMark.lineStagger * index,
            ),
          ),
    ];
    final layer = _MarkLayer(
      child: Stack(clipBehavior: Clip.none, children: marks),
    );
    return SpanTextStyle(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (!widget.over) Positioned.fill(child: layer),
          _LayoutReporter(onLayout: _onLayout, child: widget.child),
          if (widget.over) Positioned.fill(child: layer),
        ],
      ),
    );
  }
}

class _LayoutReporter extends SingleChildRenderObjectWidget {
  const _LayoutReporter({required this.onLayout, super.child});

  final ValueChanged<RenderBox> onLayout;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderLayoutReporter(onLayout);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderLayoutReporter renderObject,
  ) {
    renderObject
      ..onLayout = onLayout
      ..markNeedsLayout();
  }
}

class _RenderLayoutReporter extends RenderProxyBox {
  _RenderLayoutReporter(this.onLayout);

  ValueChanged<RenderBox> onLayout;

  @override
  void performLayout() {
    super.performLayout();
    onLayout(this);
  }
}

/// The drawings' layer: never hit, left out of semantics, and without a
/// baseline, so the marked text alone sets where the mark sits in a line.
class _MarkLayer extends SingleChildRenderObjectWidget {
  const _MarkLayer({super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderMarkLayer();
}

class _RenderMarkLayer extends RenderProxyBox {
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) => false;

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {}

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) => null;

  @override
  double? computeDryBaseline(
    BoxConstraints constraints,
    TextBaseline baseline,
  ) => null;
}
