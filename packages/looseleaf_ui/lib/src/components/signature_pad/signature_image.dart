import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/sketchpad/sketchpad.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';
import 'package:looseleaf_ui/src/textures/textures.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A signature value (an SVG or PNG `data:` URL) shown as an image that
/// fits its box (`object-contain`); nothing for anything else.
///
/// Mirrors the `signature-image` of upstream
/// `src/components/ui/signature-pad.tsx`.
class SignatureImage extends StatelessWidget {
  const SignatureImage({super.key, required this.value});

  static const String _svgPrefix = 'data:image/svg+xml';
  static final RegExp _viewBox = RegExp(r'viewBox="([^"]+)"');
  static final Map<String, ({InkDocument document, Rect box})?> _cache = {};

  final String value;

  static ({InkDocument document, Rect box})? _svg(String value) {
    if (_cache.length > 8) _cache.clear();
    return _cache.putIfAbsent(value, () {
      final comma = value.indexOf(',');
      if (comma < 0) return null;
      final svg = Uri.decodeComponent(value.substring(comma + 1));
      final numbers = [
        for (final part in (_viewBox.firstMatch(svg)?[1] ?? '').trim().split(
          RegExp(r'[\s,]+'),
        ))
          double.tryParse(part),
      ];
      final box = switch (numbers) {
        [final x?, final y?, final w?, final h?] when w > 0 && h > 0 =>
          Rect.fromLTWH(x, y, w, h),
        _ => null,
      };
      final document = _parse(svg);
      if (box == null || document == null) return null;
      return (document: document, box: box);
    });
  }

  static final RegExp _title = RegExp(r'<title>.*?</title>', dotAll: true);
  static final RegExp _root = RegExp(r'^\s*<svg[^>]*>');
  static final RegExp _nestedOpen = RegExp(r'<svg[^>]*>');

  /// Parses the content of the document [svg] (the painter reads markup
  /// without the `<svg>` root) with nested `<svg>` wrappers read as groups,
  /// or null when the painter cannot read it.
  static InkDocument? _parse(String svg) {
    final root = _root.firstMatch(svg);
    final close = svg.lastIndexOf('</svg>');
    if (root == null || close < root.end) return null;
    final body = svg
        .substring(root.end, close)
        .replaceAll(_title, '')
        .replaceAll(_nestedOpen, '<g>')
        .replaceAll('</svg>', '</g>');
    try {
      return InkDocument.parse(body);
    } on InkMarkupError {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (value.startsWith(_svgPrefix)) {
      final art = _svg(value);
      if (art == null) return const SizedBox.shrink();
      return CustomPaint(
        painter: _ContainPainter(
          document: art.document,
          box: art.box,
          theme: LooseleafTheme.of(context),
        ),
      );
    }
    if (!value.startsWith('data:image/')) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: InkTextures.instance,
      builder: (context, _) => RawImage(
        image: InkTextures.instance.dataImage(value),
        fit: BoxFit.contain,
      ),
    );
  }
}

class _ContainPainter extends CustomPainter {
  _ContainPainter({
    required this.document,
    required this.box,
    required this.theme,
  }) : super(repaint: InkTextures.instance);

  final InkDocument document;
  final Rect box;
  final LooseleafThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / box.width, size.height / box.height);
    canvas
      ..save()
      ..translate(
        (size.width - box.width * scale) / 2,
        (size.height - box.height * scale) / 2,
      )
      ..scale(scale)
      ..translate(-box.left, -box.top);
    SketchInk.paint(canvas, document, InkPaintContext(theme: theme));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ContainPainter oldDelegate) =>
      !identical(oldDelegate.document, document) || oldDelegate.theme != theme;
}
