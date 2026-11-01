import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/art/art.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Paints a spinner mark with its pad inside the box (upstream's `viewBox`
/// of `-pad -pad w+2pad h+2pad`), with [effects] on its `reveal` part: the
/// moving dash of the scribble.
class SpinnerPainter extends CustomPainter {
  const SpinnerPainter({
    required this.frame,
    required this.theme,
    required this.color,
    this.effects = InkStateEffects.none,
  });

  final InkArtFrame frame;
  final LooseleafThemeData theme;
  final Color color;
  final InkStateEffects effects;

  /// The mark's `viewBox`, its pad included.
  Rect get viewBox => Rect.fromLTWH(
    -frame.pad,
    -frame.pad,
    frame.width + 2 * frame.pad,
    frame.height + 2 * frame.pad,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final box = viewBox;
    canvas
      ..save()
      ..scale(size.width / box.width, size.height / box.height)
      ..translate(-box.left, -box.top);
    final painter = InkPainter(
      frame.document,
      InkPaintContext(theme: theme, currentColor: color, state: effects),
    );
    painter.paintLayer(canvas, 'rest');
    canvas.restore();
  }

  @override
  bool shouldRepaint(SpinnerPainter oldDelegate) =>
      oldDelegate.frame != frame ||
      oldDelegate.theme != theme ||
      oldDelegate.color != color ||
      oldDelegate.effects.reveal != effects.reveal ||
      oldDelegate.effects.revealDashes != effects.revealDashes;
}
