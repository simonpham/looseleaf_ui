import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/skeleton/skeleton_frame.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Paints a skeleton: a pale paper-shade wash, pencil hatching over it and a
/// ruled pencil outline (a pencil circle when [circle]), from [frame].
///
/// Mirrors the `[data-slot=skeleton]` rules of `skeletonCss` in upstream
/// `src/lib/ink/recipes/skeleton-ink.ts`.
class SkeletonPainter extends CustomPainter {
  SkeletonPainter({
    required this.frame,
    required this.theme,
    required this.circle,
    super.repaint,
  });

  final ValueNotifier<int> frame;
  final LooseleafThemeData theme;
  final bool circle;

  static const double _washAlpha = 0.55;
  static const double _hatchOpacity = 0.4;
  static const double _outlineOpacity = 0.78;
  static const double _circleInset = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final tiles = SkeletonFrame.all[frame.value];
    final colors = theme.colors;
    final box = Offset.zero & size;
    final shape = switch (circle) {
      true => Path()..addOval(box),
      false => Path()..addRect(box),
    };
    canvas.drawPath(
      shape,
      Paint()
        ..color = colors.paperShade.withValues(
          alpha: colors.paperShade.a * _washAlpha,
        ),
    );
    _layer(canvas, box.inflate(_circleInset + edgeTh), _hatchOpacity, () {
      canvas.clipPath(shape);
      _hatch(canvas, tiles.hatch, size, colors.pencilMark);
    });
    _layer(canvas, box.inflate(_circleInset + edgeTh), _outlineOpacity, () {
      final pencil = InkPainter(
        tiles.edgeH,
        InkPaintContext(theme: theme, currentColor: colors.pencil),
      );
      if (circle) {
        _stretch(
          canvas,
          InkPainter(
            tiles.circle,
            InkPaintContext(theme: theme, currentColor: colors.pencil),
          ),
          box.inflate(_circleInset),
          const Size(circleSize, circleSize),
        );
        return;
      }
      _outline(canvas, tiles, box.inflate(edgeTh / 2), pencil);
    });
  }

  void _layer(Canvas canvas, Rect bounds, double opacity, VoidCallback draw) {
    canvas.saveLayer(
      bounds,
      Paint()..color = Color.fromRGBO(0, 0, 0, opacity),
    );
    draw();
    canvas.restore();
  }

  void _hatch(Canvas canvas, InkDocument hatch, Size size, Color color) {
    final painter = InkPainter(
      hatch,
      InkPaintContext(theme: theme, currentColor: color),
    );
    for (var y = 0.0; y < size.height; y += hatchSize) {
      for (var x = 0.0; x < size.width; x += hatchSize) {
        canvas
          ..save()
          ..translate(x, y)
          ..clipRect(const Rect.fromLTWH(0, 0, hatchSize, hatchSize));
        painter.paintLayer(canvas, 'rest');
        canvas.restore();
      }
    }
  }

  /// The four ruled edges, each `calc(100% - 4px)` long and 2 px in from
  /// the corners, as upstream's `mask-size` and `mask-position`.
  void _outline(
    Canvas canvas,
    SkeletonFrame tiles,
    Rect outer,
    InkPainter horizontal,
  ) {
    final vertical = InkPainter(
      tiles.edgeV,
      InkPaintContext(theme: theme, currentColor: theme.colors.pencil),
    );
    const end = edgeTh / 2 - 0.5;
    final spanW = outer.width - (edgeTh - 1);
    final spanH = outer.height - (edgeTh - 1);
    const along = Size(edgeLen, edgeTh);
    const across = Size(edgeTh, edgeLen);
    for (final (painter, rect, tile) in [
      (
        horizontal,
        Rect.fromLTWH(outer.left + end, outer.top, spanW, edgeTh),
        along,
      ),
      (
        horizontal,
        Rect.fromLTWH(outer.left + end, outer.bottom - edgeTh, spanW, edgeTh),
        along,
      ),
      (
        vertical,
        Rect.fromLTWH(outer.left, outer.top + end, edgeTh, spanH),
        across,
      ),
      (
        vertical,
        Rect.fromLTWH(outer.right - edgeTh, outer.top + end, edgeTh, spanH),
        across,
      ),
    ]) {
      _stretch(canvas, painter, rect, tile);
    }
  }

  /// Paints a tile [tile] big into [rect], stretched like
  /// `preserveAspectRatio="none"`.
  void _stretch(Canvas canvas, InkPainter painter, Rect rect, Size tile) {
    if (rect.isEmpty) return;
    canvas
      ..save()
      ..translate(rect.left, rect.top)
      ..scale(rect.width / tile.width, rect.height / tile.height)
      ..clipRect(Offset.zero & tile);
    painter.paintLayer(canvas, 'rest');
    canvas.restore();
  }

  @override
  bool shouldRepaint(SkeletonPainter oldDelegate) =>
      oldDelegate.frame != frame ||
      oldDelegate.theme != theme ||
      oldDelegate.circle != circle;
}
