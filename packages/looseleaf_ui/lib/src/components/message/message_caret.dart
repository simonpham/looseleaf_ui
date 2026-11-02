import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The felt-tip caret after a streaming [MessageText]: a 2 px rounded bar,
/// 1.05 em tall, in your ink, pulsing (`animate-pulse`). Reduced motion
/// holds it still.
class MessageCaret extends StatefulWidget {
  const MessageCaret({super.key, required this.fontSize});

  /// The text's font size, which sizes the bar.
  final double fontSize;

  @override
  State<MessageCaret> createState() => _MessageCaretState();
}

class _MessageCaretState extends State<MessageCaret>
    with SingleTickerProviderStateMixin {
  static const Duration _period = Duration(seconds: 2);
  static const Curve _pulse = Cubic(0.4, 0, 0.6, 1);

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _period,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = InkMotion.reducedIn(context);
    if (still) {
      _controller.stop();
      return;
    }
    if (!_controller.isAnimating) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final bar = Padding(
      padding: const EdgeInsetsDirectional.only(start: Spacing.d2),
      child: CustomPaint(
        size: Size(Spacing.d2, widget.fontSize * 1.05),
        painter: _CaretPainter(theme.colors.inkYou),
      ),
    );
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final wave = switch (t < 0.5) {
          true => _pulse.transform(t * 2),
          false => _pulse.transform((1 - t) * 2),
        };
        return Opacity(opacity: 1 - 0.5 * wave, child: child);
      },
      child: bar,
    );
  }
}

class _CaretPainter extends CustomPainter {
  const _CaretPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(size.width / 2),
      ),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_CaretPainter oldDelegate) => oldDelegate.color != color;
}
