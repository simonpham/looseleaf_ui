import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/code_block/code_block.dart';

/// The dark tone's face: the slate colour with its faint sheen
/// (`--ll-paper-light: linear-gradient(160deg, …)`) and no tooth, turned by
/// the sheet's tilt so it covers the slip exactly.
///
/// Mirrors the `[data-tone="dark"]` paper variables in upstream
/// `src/styles/looseleaf.css`.
class CodeBlockSlate extends StatelessWidget {
  const CodeBlockSlate({super.key, required this.angle});

  /// The sheet's tilt in radians.
  final double angle;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: angle,
    child: const CustomPaint(
      painter: _SlatePainter(),
      child: SizedBox.expand(),
    ),
  );
}

class _SlatePainter extends CustomPainter {
  const _SlatePainter();

  static const double _angle = 160 * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final box = Offset.zero & size;
    final sheet = RRect.fromRectAndRadius(box, const Radius.circular(1));
    final direction = Offset(math.sin(_angle), -math.cos(_angle));
    final half =
        (size.width * direction.dx.abs() + size.height * direction.dy.abs()) /
        2;
    canvas
      ..drawRRect(sheet, Paint()..color = CodeBlockTone.slate)
      ..drawRRect(
        sheet,
        Paint()
          ..shader = ui.Gradient.linear(
            box.center - direction * half,
            box.center + direction * half,
            const [Color(0x0FFFFFFF), Color(0x00FFFFFF)],
            const [0, 0.55],
          ),
      );
  }

  @override
  bool shouldRepaint(_SlatePainter oldDelegate) => false;
}
