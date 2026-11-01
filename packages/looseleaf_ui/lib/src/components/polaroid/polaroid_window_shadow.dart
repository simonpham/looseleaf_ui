import 'package:flutter/widgets.dart';

/// The recessed window's inner shadow: a soft shade from the top edge and a
/// hairline all round (upstream `inset 0 2px 4px`, `inset 0 0 0 1px`).
class PolaroidWindowShadow extends CustomPainter {
  const PolaroidWindowShadow({required this.shade});

  /// `--ll-shade`.
  final Color shade;

  @override
  void paint(Canvas canvas, Size size) {
    final window = Offset.zero & size;
    canvas
      ..save()
      ..clipRect(window);
    final ring = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(window.inflate(size.shortestSide))
      ..addRect(window.shift(const Offset(0, 2)));
    canvas.drawPath(
      ring,
      Paint()
        ..color = shade.withValues(alpha: 0.26)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas
      ..drawRect(
        window.deflate(0.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = shade.withValues(alpha: 0.12),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(PolaroidWindowShadow oldDelegate) =>
      oldDelegate.shade != shade;
}
