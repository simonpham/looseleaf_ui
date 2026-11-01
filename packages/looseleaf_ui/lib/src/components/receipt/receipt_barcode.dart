import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/receipt/receipt.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A barcode made from [value], across the receipt and [height] px tall,
/// with the number printed under it 6 px below in widely spaced 12 px
/// figures. The same number always prints the same bars. Screen readers
/// hear it as an image named `Barcode <value>`.
///
/// Mirrors `ReceiptBarcode` in upstream `src/components/ui/receipt.tsx`.
class ReceiptBarcode extends StatelessWidget {
  const ReceiptBarcode({super.key, required this.value, this.height = 44});

  /// The number.
  final String value;

  /// The bars' height in px.
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final color = DefaultTextStyle.of(context).style.color ?? theme.colors.ink;
    final figures = theme.typography.face(
      KevinSansFace.type,
      cssSize: 12,
      cssLineHeight: 16 / 12,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d6,
      children: [
        Semantics(
          image: true,
          label: 'Barcode $value',
          child: CustomPaint(
            painter: ReceiptBarcodePainter(
              value: value,
              barHeight: height,
              color: color,
            ),
            child: SizedBox(width: double.infinity, height: height),
          ),
        ),
        ExcludeSemantics(
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: figures.copyWith(
              letterSpacing: (figures.fontSize ?? 0) * 0.3,
              fontFeatures: ReceiptLine.figures,
            ),
          ),
        ),
      ],
    );
  }
}
