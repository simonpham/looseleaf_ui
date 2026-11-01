import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One item on a receipt: the item (after `qty x` when [qty] is set) wraps
/// onto further lines as a thermal printer would, never cut short; the
/// [price] sits at the end of the first line in tabular figures. Screen
/// readers hear the item with its price.
///
/// Mirrors `ReceiptLine` in upstream `src/components/ui/receipt.tsx`.
class ReceiptLine extends StatelessWidget {
  const ReceiptLine({
    super.key,
    required this.child,
    required this.price,
    this.qty,
  });

  /// The item, usually a [Text].
  final Widget child;

  /// The price, usually a [Text].
  final Widget price;

  /// How many, printed before the item as `2 x`.
  final int? qty;

  /// `ll-num`: tabular, lining figures.
  static const List<FontFeature> figures = [
    FontFeature.tabularFigures(),
    FontFeature.liningFigures(),
  ];

  @override
  Widget build(BuildContext context) {
    final item = switch (qty) {
      null => child,
      final count => Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$count x ',
              style: const TextStyle(fontFeatures: figures),
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: child,
            ),
          ],
        ),
      ),
    };
    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        spacing: Spacing.d8,
        children: [
          Expanded(child: item),
          DefaultTextStyle.merge(
            style: const TextStyle(fontFeatures: figures),
            textAlign: TextAlign.end,
            child: price,
          ),
        ],
      ),
    );
  }
}
