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

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Spacing.d16),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.d40,
        children: [
          for (var row = 0; row < _ends.length; row += 2)
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d32,
              children: [
                for (final ends in _ends.skip(row).take(2))
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
        ],
      ),
    ),
  );
}
