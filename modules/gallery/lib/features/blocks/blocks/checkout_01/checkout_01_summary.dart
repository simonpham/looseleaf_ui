import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/checkout_01/checkout_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The basket, the receipt as it writes itself, the pay button and a
/// pinned hint about free delivery and PAPER10.
class Checkout01Summary extends StatelessWidget {
  const Checkout01Summary({
    super.key,
    required this.qty,
    required this.onQty,
    required this.code,
    required this.onCode,
    required this.totals,
    required this.orderNumber,
    required this.onPay,
    this.placing = false,
  });

  final List<int> qty;
  final void Function(int index, int value) onQty;
  final String? code;
  final ValueChanged<String?> onCode;
  final CheckoutTotals totals;
  final String orderNumber;
  final VoidCallback onPay;
  final bool placing;

  static const double _hintWidth = 224;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final empty = qty.every((count) => count == 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d24,
      children: [
        Checkout01Basket(qty: qty, onQty: onQty, code: code, onCode: onCode),
        switch (empty) {
          true => const Paper(
            stock: StockName.slip,
            tiltDegrees: -0.3,
            seed: 'empty-basket',
            child: Empty(
              seed: 'basket-empty',
              padding: EdgeInsets.all(Spacing.d16),
              children: [
                EmptyHeader(
                  children: [
                    EmptyMedia(pose: 'shrug', size: 96),
                    EmptyTitle(child: Text('Nothing in the basket')),
                    EmptyDescription(
                      child: Text(
                        'Add a notebook with the plus and the receipt starts writing itself.',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          false => Center(
            child: Checkout01OrderReceipt(
              qty: qty,
              totals: totals,
              code: code,
              orderNumber: orderNumber,
              seed: 'checkout-receipt',
              semanticLabel: 'Your order',
            ),
          ),
        },
        Semantics(
          liveRegion: true,
          label: switch (empty) {
            true => 'The basket is empty.',
            false => 'Total €${checkoutMoney(totals.total)}.',
          },
          child: const SizedBox.shrink(),
        ),
        Button(
          size: ButtonSize.lg,
          disabled: empty,
          onPressed: onPay,
          child: Text(switch (placing) {
            true => 'Placing your order…',
            false => 'Pay €${checkoutMoney(totals.total)}',
          }),
        ),
        Padding(
          padding: const EdgeInsets.only(top: Spacing.d12),
          child: Center(
            child: StickyNote(
              fastener: FastenerKind.pin,
              tiltDegrees: 2,
              seed: 'checkout-hint',
              width: _hintWidth,
              minHeight: Spacing.d40,
              children: [
                StickyNoteContent(
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'psst: free delivery over ${checkoutMoney(checkoutFreeShippingFrom)}, and ',
                        ),
                        TextSpan(
                          text: 'PAPER10',
                          style: theme.typography
                              .stamp(cssSize: 16)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(text: ' takes a tenth off the paper.'),
                      ],
                    ),
                    style: theme.typography.face(
                      KevinSansFace.hand,
                      cssSize: 18,
                      cssLineHeight: 1.375,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
