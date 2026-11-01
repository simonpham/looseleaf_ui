import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/sketchpad/sketchpad.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';
import 'package:looseleaf_ui/src/textures/textures.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// When a stroke starts drawing on during a replay, and for how long, in
/// seconds.
typedef SketchReplayTiming = ({double delay, double duration});

/// Paints a sketch's finished strokes, scaled from the drawing's [width] ×
/// [height] to the canvas: the strokes the eraser is over at 22%, and
/// during a replay each stroke drawn on along its centre line as [clock]
/// (seconds) passes its [timings].
///
/// Mirrors `StrokeShape` in upstream `src/components/ui/sketchpad.tsx`.
class SketchStrokesPainter extends CustomPainter {
  SketchStrokesPainter({
    required this.strokes,
    required this.width,
    required this.height,
    required this.theme,
    this.dimmed = const {},
    this.timings = const {},
    this.clock,
  }) : super(
         repaint: Listenable.merge([InkTextures.instance, ?clock]),
       );

  /// The dimmed strokes' opacity (upstream `opacity: 0.22`).
  static const double dimOpacity = 0.22;

  final List<SketchStroke> strokes;
  final double width;
  final double height;
  final LooseleafThemeData theme;

  /// Ids of the strokes the eraser would remove.
  final Set<String> dimmed;

  /// Replay timings by stroke id; strokes without one show whole.
  final Map<String, SketchReplayTiming> timings;

  /// The replay clock in seconds.
  final ValueListenable<double>? clock;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || width <= 0 || height <= 0) return;
    canvas
      ..save()
      ..clipRect(Offset.zero & size)
      ..scale(size.width / width, size.height / height);
    final context = InkPaintContext(theme: theme);
    final tier = SketchInk.tier(theme);
    final now = clock?.value ?? double.infinity;
    for (final stroke in strokes) {
      final markup = strokeMarkup(stroke, tier: tier);
      final opacity = switch (dimmed.contains(stroke.id)) {
        true => dimOpacity,
        false => 1.0,
      };
      final progress = switch (timings[stroke.id]) {
        null => 1.0,
        final timing => ((now - timing.delay) / timing.duration).clamp(
          0.0,
          1.0,
        ),
      };
      if (progress <= 0) continue;
      final document = SketchInk.document(markup);
      if (progress >= 1) {
        SketchInk.paint(canvas, document, context, opacity: opacity);
        continue;
      }
      _paintDrawingOn(canvas, stroke, markup, progress, context, opacity);
    }
    canvas.restore();
  }

  void _paintDrawingOn(
    Canvas canvas,
    SketchStroke stroke,
    StrokeMarkup markup,
    double progress,
    InkPaintContext context,
    double opacity,
  ) {
    final maskWidth = SketchInk.replayMaskWidth(stroke);
    final (x0, y0, x1, y1) = markup.bbox;
    final bounds = Rect.fromLTRB(x0, y0, x1, y1).inflate(maskWidth);
    canvas.saveLayer(bounds, Paint());
    canvas.drawPath(
      _partial(SketchInk.centre(markup), progress),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = maskWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF000000),
    );
    canvas.saveLayer(bounds, Paint()..blendMode = BlendMode.srcIn);
    SketchInk.paint(
      canvas,
      SketchInk.document(markup),
      context,
      opacity: opacity,
    );
    canvas
      ..restore()
      ..restore();
  }

  static Path _partial(Path centre, double progress) {
    final metrics = centre.computeMetrics().toList();
    final total = metrics.fold(0.0, (sum, metric) => sum + metric.length);
    var left = total * progress;
    final out = Path();
    for (final metric in metrics) {
      if (left <= 0) break;
      out.addPath(metric.extractPath(0, left), Offset.zero);
      left -= metric.length;
    }
    return out;
  }

  @override
  bool shouldRepaint(SketchStrokesPainter oldDelegate) =>
      !identical(oldDelegate.strokes, strokes) ||
      oldDelegate.width != width ||
      oldDelegate.height != height ||
      oldDelegate.theme != theme ||
      !setEquals(oldDelegate.dimmed, dimmed) ||
      !identical(oldDelegate.timings, timings) ||
      oldDelegate.clock != clock;
}
