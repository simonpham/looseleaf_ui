import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ReceiptOrderSummaryExample extends StatefulWidget {
  const ReceiptOrderSummaryExample({super.key});

  @override
  State<ReceiptOrderSummaryExample> createState() =>
      _ReceiptOrderSummaryExampleState();
}

class _ReceiptOrderSummaryExampleState
    extends State<ReceiptOrderSummaryExample> {
  static const _menu = [
    (name: 'oat latte', price: 4.5),
    (name: 'almond croissant', price: 3.1),
    (name: 'washi tape', price: 3.0),
  ];

  final _qty = [1, 2, 0];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    var total = 0.0;
    for (final (i, item) in _menu.indexed) {
      total += item.price * _qty[i];
    }
    return Wrap(
      spacing: Spacing.d48,
      runSpacing: Spacing.d32,
      alignment: WrapAlignment.center,
      children: [
        Semantics(
          liveRegion: true,
          child: Receipt(
            seed: 'order',
            semanticLabel: 'Your order',
            children: [
              const ReceiptHeader(
                children: [Text('Your order'), Text('no. 0042')],
              ),
              ReceiptLines(
                children: [
                  for (final (i, item) in _menu.indexed)
                    if (_qty[i] > 0)
                      ReceiptLine(
                        qty: _qty[i],
                        price: Text((item.price * _qty[i]).toStringAsFixed(2)),
                        child: Text(item.name),
                      ),
                ],
              ),
              ReceiptTotal(
                circled: switch (total > 10) {
                  true => ReceiptPen.redfelt,
                  false => null,
                },
                child: Text(total.toStringAsFixed(2)),
              ),
              const ReceiptDivider(),
              const ReceiptBarcode(value: '0042 1187'),
              const ReceiptFooter(Text('circled when it is over ten')),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: Spacing.d24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: Spacing.d12,
            children: [
              for (final (i, item) in _menu.indexed)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Spacing.d12,
                  children: [
                    Button(
                      size: ButtonSize.iconSm,
                      variant: ButtonVariant.outline,
                      semanticLabel: 'One less ${item.name}',
                      disabled: _qty[i] == 0,
                      onPressed: () => setState(() => _qty[i]--),
                      child: const InkIcon('minus'),
                    ),
                    SizedBox(
                      width: 144,
                      child: Text(
                        item.name,
                        style: TextStyle(color: theme.colors.ink),
                      ),
                    ),
                    Button(
                      size: ButtonSize.iconSm,
                      semanticLabel: 'One more ${item.name}',
                      onPressed: () => setState(() => _qty[i]++),
                      child: const InkIcon('plus'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
