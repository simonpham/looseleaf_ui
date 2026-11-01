import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:looseleaf_ui/src/components/art/ink_art_frame.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';
import 'package:looseleaf_ui/src/textures/textures.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Paints an [InkArtFrame] the way upstream's art `<svg>` shows it: the
/// viewBox stretched over the widget, overflow visible, and with [shadow]
/// the `ll-drop-sticker` filter (two warm drop shadows under the art).
class InkArtPainter extends CustomPainter {
  InkArtPainter({
    required this.frame,
    required this.theme,
    required this.currentColor,
    this.shadow = false,
  }) : super(repaint: InkTextures.instance);

  final InkArtFrame frame;
  final LooseleafThemeData theme;
  final Color currentColor;
  final bool shadow;

  static const List<({double dy, double blur, double alpha})> _drops = [
    (dy: 1, blur: 0.6, alpha: 0.26),
    (dy: 3, blur: 3, alpha: 0.14),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || frame.width <= 0 || frame.height <= 0) return;
    canvas.save();
    canvas.scale(size.width / frame.width, size.height / frame.height);
    switch (shadow && theme.shadowK > 0) {
      case true:
        _paintWithShadow(canvas, size);
      case false:
        _paintArt(canvas);
    }
    canvas.restore();
  }

  Rect get _bounds => Rect.fromLTWH(
    -frame.pad,
    -frame.pad,
    frame.width + 2 * frame.pad,
    frame.height + 2 * frame.pad,
  );

  void _paintArt(Canvas canvas) {
    final document = frame.document;
    final painter = InkPainter(
      document,
      InkPaintContext(theme: theme, currentColor: currentColor),
    );
    if (document.usesBlend) canvas.saveLayer(_bounds.inflate(1), Paint());
    for (final layer in document.layers.keys) {
      painter.paintLayer(canvas, layer);
    }
    if (document.usesBlend) canvas.restore();
  }

  void _paintWithShadow(Canvas canvas, Size size) {
    final recorder = ui.PictureRecorder();
    _paintArt(Canvas(recorder));
    final picture = recorder.endRecording();
    final scale = size.width / frame.width;
    for (final drop in _drops) {
      final sigma = drop.blur / 2 / scale;
      canvas.save();
      canvas.translate(0, drop.dy / scale);
      canvas.saveLayer(
        _bounds.inflate(sigma * 3 + 1),
        Paint()
          ..colorFilter = ColorFilter.mode(
            theme.colors.shade.withValues(
              alpha: (drop.alpha * theme.shadowK).clamp(0.0, 1.0),
            ),
            BlendMode.srcIn,
          )
          ..imageFilter = ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      );
      canvas.drawPicture(picture);
      canvas.restore();
      canvas.restore();
    }
    canvas.drawPicture(picture);
    picture.dispose();
  }

  @override
  bool shouldRepaint(InkArtPainter oldDelegate) =>
      !identical(oldDelegate.frame, frame) ||
      oldDelegate.theme != theme ||
      oldDelegate.currentColor != currentColor ||
      oldDelegate.shadow != shadow;
}
