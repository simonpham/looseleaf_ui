import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/typography/typography_quote_bars.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Paints one of the [typographyQuoteBars] stretched over the box in
/// [color]: a blockquote's marker bar. The bars are masks (black paths), so
/// the color is laid through them, like upstream's masked `::before`.
class QuoteBarPainter extends CustomPainter {
  QuoteBarPainter({
    required this.index,
    required this.color,
    required this.theme,
  });

  /// Which of the three bars.
  final int index;
  final Color color;
  final LooseleafThemeData theme;

  /// The bars' `viewBox`.
  static const Size tile = Size(10, 120);

  static final List<InkDocument> _documents = [
    for (final url in typographyQuoteBars) _parse(url),
  ];

  static const String _prefix = 'url("data:image/svg+xml,';

  static InkDocument _parse(String url) {
    final svg = Uri.decodeComponent(
      url.substring(_prefix.length, url.length - 2),
    );
    return InkDocument.parse(
      svg.substring(svg.indexOf('>') + 1, svg.lastIndexOf('</svg>')),
    );
  }

  /// The parsed bar [index], for tests.
  static InkDocument document(int index) => _documents[index];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final box = Offset.zero & size;
    canvas
      ..saveLayer(box, Paint())
      ..save()
      ..scale(size.width / tile.width, size.height / tile.height)
      ..clipRect(Offset.zero & tile);
    InkPainter(
      _documents[index],
      InkPaintContext(theme: theme, currentColor: color),
    ).paintLayer(canvas, 'rest');
    canvas
      ..restore()
      ..drawRect(
        box,
        Paint()
          ..color = color
          ..blendMode = BlendMode.srcIn,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(QuoteBarPainter oldDelegate) =>
      oldDelegate.index != index ||
      oldDelegate.color != color ||
      oldDelegate.theme != theme;
}
