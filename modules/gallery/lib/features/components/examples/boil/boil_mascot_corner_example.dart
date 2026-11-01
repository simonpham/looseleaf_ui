import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class BoilMascotCornerExample extends StatelessWidget {
  const BoilMascotCornerExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return SizedBox(
      width: 320,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Paper(
            stock: StockName.card,
            tilt: false,
            padding: const EdgeInsets.all(Spacing.d24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 30,
                    cssLineHeight: 1,
                    color: theme.colors.ink,
                  ),
                ),
                const Boil(child: _Underline()),
                const SizedBox(height: Spacing.d12),
                Text(
                  'The text holds still. Only the pencil is nervous.',
                  style: theme.typography.interface(
                    cssSize: 14,
                    color: theme.colors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            top: -Spacing.d32,
            end: -Spacing.d16,
            child: Boil(
              builder: (context, frame, seed) =>
                  Mascot(pose: 'wave', size: 88, seed: seed('wave')),
            ),
          ),
        ],
      ),
    );
  }
}

class _Underline extends StatelessWidget {
  const _Underline();

  static const _wobbles = [0, 2, 1, 3];

  @override
  Widget build(BuildContext context) {
    final wobble = _wobbles[BoilScope.frameOf(context) % _wobbles.length];
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.d4),
      child: ExcludeSemantics(
        child: CustomPaint(
          size: const Size(192, Spacing.d10),
          painter: _UnderlinePainter(
            wobble: wobble.toDouble(),
            color: LooseleafTheme.of(context).colors.inkYou,
          ),
        ),
      ),
    );
  }
}

class _UnderlinePainter extends CustomPainter {
  const _UnderlinePainter({required this.wobble, required this.color});

  final double wobble;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 200;
    canvas.scale(scale, size.height / 10);
    final control = 2 + wobble * 2;
    final path = Path()
      ..moveTo(2, 6)
      ..quadraticBezierTo(50, control, 100, 5)
      ..quadraticBezierTo(150, 10 - control, 198, 4 + wobble);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_UnderlinePainter oldDelegate) =>
      oldDelegate.wobble != wobble || oldDelegate.color != color;
}
