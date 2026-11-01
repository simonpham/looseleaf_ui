import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The two fold creases across a [BubbleShape.note]: a shaded valley and a
/// lit ridge at a third and two thirds of the slip, multiplied over it.
///
/// Mirrors `CREASES` in upstream `src/components/ui/bubble.tsx`.
class BubbleCreases extends StatelessWidget {
  const BubbleCreases({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    return CustomPaint(
      painter: _CreasesPainter(shade: colors.shade, photo: colors.photo),
      child: const SizedBox.expand(),
    );
  }
}

class _CreasesPainter extends CustomPainter {
  const _CreasesPainter({required this.shade, required this.photo});

  final Color shade;
  final Color photo;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    const clear = Color(0x00000000);
    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      colors: [
        clear,
        shade.withValues(alpha: 0.16),
        photo.withValues(alpha: 0.5),
        clear,
        clear,
        shade.withValues(alpha: 0.12),
        photo.withValues(alpha: 0.45),
        clear,
      ],
      stops: const [0.316, 0.322, 0.329, 0.355, 0.64, 0.646, 0.653, 0.68],
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = gradient.createShader(rect)
        ..blendMode = BlendMode.multiply,
    );
  }

  @override
  bool shouldRepaint(_CreasesPainter oldDelegate) =>
      oldDelegate.shade != shade || oldDelegate.photo != photo;
}
