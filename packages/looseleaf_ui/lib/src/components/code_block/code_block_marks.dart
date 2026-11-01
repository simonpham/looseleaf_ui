import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';

double _fixed(double value) => double.parse(JsMath.toFixed(value, 2));

/// The red pencil strike through a removed line: two seeded strokes across
/// a 100 × 8 box stretched over the text, 2 px past each end.
///
/// Mirrors `Strike` and `strikePath` in upstream
/// `src/components/ui/code-block.tsx`.
class CodeStrikePainter extends CustomPainter {
  CodeStrikePainter({required this.seed, required this.color});

  final String seed;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Rng(seed);
    double y(double v) => _fixed(4 + v + rng.gauss(0, 0.35));
    final a = [y(0.1), y(-0.8), y(0.9), y(-0.2), y(0.6), y(-0.4)];
    final b = [y(1.1), y(0.4), y(1.6), y(0.9)];
    final sx = size.width / 100;
    final top = size.height / 2 - 4;
    Offset at(double x, double y) => Offset(x * sx, top + y);
    final main = Path()
      ..moveTo(at(0, a[0]).dx, at(0, a[0]).dy)
      ..cubicTo(
        at(24, a[1]).dx,
        at(24, a[1]).dy,
        at(44, a[2]).dx,
        at(44, a[2]).dy,
        at(66, a[3]).dx,
        at(66, a[3]).dy,
      )
      ..cubicTo(
        at(88, 2 * a[3] - a[2]).dx,
        at(88, 2 * a[3] - a[2]).dy,
        at(92, a[4]).dx,
        at(92, a[4]).dy,
        at(100, a[5]).dx,
        at(100, a[5]).dy,
      );
    final echo = Path()
      ..moveTo(at(2, b[0]).dx, at(2, b[0]).dy)
      ..cubicTo(
        at(30, b[1]).dx,
        at(30, b[1]).dy,
        at(58, b[2]).dx,
        at(58, b[2]).dy,
        at(98, b[3]).dx,
        at(98, b[3]).dy,
      );
    final pen = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawPath(
        echo,
        pen
          ..strokeWidth = 1
          ..color = color.withValues(alpha: color.a * 0.5),
      )
      ..drawPath(
        main,
        pen
          ..strokeWidth = 1.7
          ..color = color,
      );
  }

  @override
  bool shouldRepaint(CodeStrikePainter oldDelegate) =>
      oldDelegate.seed != seed || oldDelegate.color != color;
}

/// The green tick before an added line, in a 14 × 14 box.
///
/// Mirrors `Tick` and `tickPath` in upstream
/// `src/components/ui/code-block.tsx`.
class CodeTickPainter extends CustomPainter {
  CodeTickPainter({required this.seed, required this.color});

  final String seed;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Rng(seed);
    double j(double base) => _fixed(base + rng.gauss(0, 0.5));
    final path = Path()
      ..moveTo(j(1.6), j(7.4))
      ..lineTo(j(5.1), j(11.4))
      ..lineTo(j(12.6), j(2.2));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.9
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(CodeTickPainter oldDelegate) =>
      oldDelegate.seed != seed || oldDelegate.color != color;
}
