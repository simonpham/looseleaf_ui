import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/checkout_01/checkout_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The order written up as a till receipt; [full] adds the subtotal,
/// discount, delivery and VAT lines, the barcode and the euro footer.
class Checkout01OrderReceipt extends StatelessWidget {
  const Checkout01OrderReceipt({
    super.key,
    required this.qty,
    required this.totals,
    required this.orderNumber,
    required this.seed,
    required this.semanticLabel,
    this.code,
    this.full = true,
  });

  final List<int> qty;
  final CheckoutTotals totals;
  final String orderNumber;
  final String seed;
  final String semanticLabel;
  final String? code;
  final bool full;

  @override
  Widget build(BuildContext context) => Receipt(
    seed: seed,
    semanticLabel: semanticLabel,
    children: [
      ReceiptHeader(
        children: [
          const Text('Looseleaf shop'),
          Text('Order $orderNumber'),
        ],
      ),
      ReceiptLines(
        children: [
          for (final (index, product) in checkoutProducts.indexed)
            if (qty[index] > 0)
              ReceiptLine(
                qty: qty[index],
                price: Text(checkoutMoney(product.cents * qty[index])),
                child: Text(product.name),
              ),
        ],
      ),
      if (full)
        ReceiptLines(
          children: [
            ReceiptLine(
              price: Text(checkoutMoney(totals.subtotal)),
              child: const Text('subtotal'),
            ),
            if (totals.discount > 0)
              ReceiptLine(
                price: Text('-${checkoutMoney(totals.discount)}'),
                child: Text('code $code'),
              ),
            ReceiptLine(
              price: Text(switch (totals.shipping) {
                0 => 'free',
                final cents => checkoutMoney(cents),
              }),
              child: const Text('delivery'),
            ),
            ReceiptLine(
              price: Text(checkoutMoney(totals.vat)),
              child: const Text('of which VAT $checkoutVatPercent%'),
            ),
          ],
        ),
      ReceiptTotal(
        circled: ReceiptPen.redfelt,
        child: Text(checkoutMoney(totals.total)),
      ),
      if (full) ...[
        const ReceiptDivider(),
        ReceiptBarcode(value: orderNumber),
        const ReceiptFooter(Text('prices in euro, VAT included')),
      ],
      if (!full) const ReceiptFooter(Text('paid by card - thank you')),
    ],
  );
}
