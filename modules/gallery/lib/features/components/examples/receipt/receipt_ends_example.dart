import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ReceiptEndsExample extends StatelessWidget {
  const ReceiptEndsExample({super.key});

  static const _ends = [
    EdgeKind.zig,
    EdgeKind.perf,
    EdgeKind.torn,
    EdgeKind.cut,
  ];

  static const _pairWidth = 2 * Spacing.d176 + Spacing.d32;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Spacing.d16),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _pairWidth),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: Spacing.d32,
          runSpacing: Spacing.d40,
          children: [
            for (final ends in _ends)
              Receipt(
                ends: ends,
                seed: ends.name,
                width: Spacing.d176,
                semanticLabel: 'Receipt, ${ends.name} ends',
                children: [
                  ReceiptHeader(children: [Text(ends.name)]),
                  const ReceiptLines(
                    children: [
                      ReceiptLine(price: Text('2.20'), child: Text('tea')),
                    ],
                  ),
                  const ReceiptTotal(child: Text('2.20')),
                ],
              ),
          ],
        ),
      ),
    ),
  );
}
