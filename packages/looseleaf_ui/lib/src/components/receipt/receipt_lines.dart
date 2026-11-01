import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/receipt/receipt.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A receipt's items between two dashed rules, 10 px inside them and 4 px
/// apart: put a [ReceiptLine] in it for each item.
///
/// Mirrors `ReceiptLines` in upstream `src/components/ui/receipt.tsx`.
class ReceiptLines extends StatelessWidget {
  const ReceiptLines({super.key, required this.children});

  /// The [ReceiptLine]s.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const ReceiptDivider(),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.d10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d4,
          children: children,
        ),
      ),
      const ReceiptDivider(),
    ],
  );
}
