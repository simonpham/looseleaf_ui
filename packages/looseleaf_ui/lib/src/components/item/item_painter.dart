import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/item/item_frame.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// What an [ItemPainter] draws.
enum ItemPaint {
  /// The four ruled pencil edges around the box, `inset: -2.5px`.
  outline,

  /// A repeated rule centred on the box's bottom edge (a ruled row).
  rule,

  /// A repeated rule through the box's middle (a pencil separator).
  separator,
}

/// Paints an item's pencil tiles from [frame] in [color] at [opacity].
///
/// Mirrors the `::before` / `::after` rules of `itemCss` in upstream
/// `src/lib/ink/recipes/item-ink.ts`.
class ItemPainter extends CustomPainter {
  const ItemPainter({
    required this.frame,
    required this.kind,
    required this.color,
    required this.opacity,
    required this.theme,
  });

  final ItemFrame frame;
  final ItemPaint kind;
  final Color color;
  final double opacity;
  final LooseleafThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    final box = Offset.zero & size;
    canvas.saveLayer(
      box.inflate(edgeTh * 2),
      Paint()..color = Color.fromRGBO(0, 0, 0, opacity),
    );
    switch (kind) {
      case ItemPaint.outline:
        _outline(canvas, box.inflate(edgeTh / 2));
      case ItemPaint.rule:
        _repeat(canvas, size.width, size.height - edgeTh / 2);
      case ItemPaint.separator:
        _repeat(canvas, size.width, size.height / 2 - edgeTh / 2);
    }
    canvas.restore();
  }

  InkPainter _painter(InkDocument document) =>
      InkPainter(document, InkPaintContext(theme: theme, currentColor: color));

  /// The four edges, each `calc(100% - 4px)` long and 2 px in from the
  /// corners, as upstream's `mask-size` and `mask-position`.
  void _outline(Canvas canvas, Rect outer) {
    final horizontal = _painter(frame.edgeH);
    final vertical = _painter(frame.edgeV);
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

  /// `mask-size: 96px 5px; mask-repeat: repeat-x` across [width] at [top].
  void _repeat(Canvas canvas, double width, double top) {
    final painter = _painter(frame.rule);
    canvas
      ..save()
      ..clipRect(Rect.fromLTWH(0, top, width, edgeTh));
    for (var x = 0.0; x < width; x += edgeLen) {
      canvas
        ..save()
        ..translate(x, top)
        ..clipRect(const Rect.fromLTWH(0, 0, edgeLen, edgeTh));
      painter.paintLayer(canvas, 'rest');
      canvas.restore();
    }
    canvas.restore();
  }

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
  bool shouldRepaint(ItemPainter oldDelegate) =>
      oldDelegate.frame != frame ||
      oldDelegate.kind != kind ||
      oldDelegate.color != color ||
      oldDelegate.opacity != opacity ||
      oldDelegate.theme != theme;
}
