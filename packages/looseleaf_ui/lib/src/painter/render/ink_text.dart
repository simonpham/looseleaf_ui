import 'dart:ui';

import 'package:looseleaf_ui/src/painter/markup/markup.dart';
import 'package:looseleaf_ui/src/painter/render/ink_paint_context.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Paints `<text>` in Kevin Sans, positioned by its baseline and anchor.
abstract final class InkText {
  static void paint(
    Canvas canvas,
    InkTextNode node,
    InkStyle style,
    InkPaintContext context,
    Color? Function(InkPaint paint) resolve,
    double alpha,
  ) {
    final color = resolve(style.fill ?? const InkNoPaint());
    if (color == null || node.text.isEmpty) return;
    final opacity = (style.fillOpacity?.resolve(context.scalar) ?? 1) * alpha;
    final face = KevinSansFace.fromCss(style.fontFamily ?? '');
    final textStyle = context.theme.typography.face(
      face,
      cssSize: style.fontSize ?? 16,
      fontWeight: style.fontWeight ?? FontWeight.w400,
    );
    final builder =
        ParagraphBuilder(
            ParagraphStyle(
              fontFamily: textStyle.fontFamily,
              fontSize: textStyle.fontSize,
              fontWeight: textStyle.fontWeight,
              maxLines: 1,
            ),
          )
          ..pushStyle(
            TextStyle(
              color: color.withValues(alpha: color.a * opacity),
              fontFamily: textStyle.fontFamily,
              fontSize: textStyle.fontSize,
              fontWeight: textStyle.fontWeight,
            ),
          )
          ..addText(node.text);
    final paragraph = builder.build()
      ..layout(const ParagraphConstraints(width: double.infinity));
    final width = paragraph.maxIntrinsicWidth;
    final dx = switch (style.textAnchor) {
      'middle' => width / 2,
      'end' => width,
      _ => 0.0,
    };
    canvas.drawParagraph(
      paragraph,
      node.position - Offset(dx, paragraph.alphabeticBaseline),
    );
    paragraph.dispose();
  }
}
