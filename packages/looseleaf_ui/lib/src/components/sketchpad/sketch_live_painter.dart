import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/sketchpad/sketchpad.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';
import 'package:looseleaf_ui/src/textures/textures.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Paints what moves on a sketch: the stroke being drawn (its quick,
/// undried [live] markup) and the keyboard [cursor] crosshair, scaled from
/// the drawing's [width] × [height].
///
/// Mirrors the `sketchpad-live` and `sketchpad-cursor` groups of upstream
/// `src/components/ui/sketchpad.tsx`.
class SketchLivePainter extends CustomPainter {
  SketchLivePainter({
    required this.live,
    required this.cursor,
    required this.width,
    required this.height,
    required this.theme,
  }) : super(repaint: InkTextures.instance);

  /// The live stroke, parsed; none when null.
  final InkDocument? live;

  /// The crosshair and where it sits, in drawing units.
  final ({InkDocument document, Offset at})? cursor;

  final double width;
  final double height;
  final LooseleafThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || width <= 0 || height <= 0) return;
    canvas
      ..save()
      ..clipRect(Offset.zero & size)
      ..scale(size.width / width, size.height / height);
    final context = InkPaintContext(theme: theme);
    if (live case final document?) SketchInk.paint(canvas, document, context);
    if (cursor case (:final document, :final at)) {
      canvas
        ..save()
        ..translate(at.dx, at.dy);
      SketchInk.paint(canvas, document, context);
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(SketchLivePainter oldDelegate) =>
      !identical(oldDelegate.live, live) ||
      oldDelegate.cursor != cursor ||
      oldDelegate.width != width ||
      oldDelegate.height != height ||
      oldDelegate.theme != theme;
}
