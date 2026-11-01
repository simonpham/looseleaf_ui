import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';

/// Paints [value]'s bars ([barcode] at 220 × [barHeight]), stretched to the
/// canvas like upstream's `preserveAspectRatio="none"`.
class ReceiptBarcodePainter extends CustomPainter {
  ReceiptBarcodePainter({
    required this.value,
    required this.barHeight,
    required this.color,
  }) : _bars = PathDataParser.parse(barcode(value, viewWidth, barHeight).d);

  /// The barcode's drawing width, upstream's `viewBox` width.
  static const double viewWidth = 220;

  /// The number the bars come from.
  final String value;

  /// The bars' drawing height.
  final double barHeight;

  /// The ink.
  final Color color;

  final Path _bars;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / viewWidth, size.height / barHeight)
      ..drawPath(_bars, Paint()..color = color)
      ..restore();
  }

  @override
  bool shouldRepaint(ReceiptBarcodePainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.barHeight != barHeight ||
      oldDelegate.color != color;
}
