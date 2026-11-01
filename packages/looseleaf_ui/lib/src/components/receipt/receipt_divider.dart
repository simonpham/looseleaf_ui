import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A dashed pencil rule across a receipt, 1 px thick. Decorative.
///
/// Mirrors `ReceiptDivider` in upstream `src/components/ui/receipt.tsx`.
class ReceiptDivider extends StatelessWidget {
  const ReceiptDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final color = LooseleafTheme.of(context).colors.pencilMark;
    return ExcludeSemantics(
      child: CustomPaint(
        painter: _DashedRule(color),
        child: const SizedBox(height: Spacing.d1, width: double.infinity),
      ),
    );
  }
}

class _DashedRule extends CustomPainter {
  const _DashedRule(this.color);

  static const double _dash = 3;

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var x = 0.0; x < size.width; x += _dash * 2) {
      final end = switch (x + _dash > size.width) {
        true => size.width,
        false => x + _dash,
      };
      canvas.drawRect(Rect.fromLTRB(x, 0, end, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_DashedRule oldDelegate) => oldDelegate.color != color;
}
