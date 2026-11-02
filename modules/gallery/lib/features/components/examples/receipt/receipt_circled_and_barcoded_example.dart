import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ReceiptCircledAndBarcodedExample extends StatelessWidget {
  const ReceiptCircledAndBarcodedExample({super.key});

  @override
  Widget build(BuildContext context) => const Receipt(
    fastener: FastenerKind.clip,
    fastenerTone: Accent.sky,
    seed: 'checked',
    semanticLabel: 'Receipt from The Stationer',
    children: [
      ReceiptHeader(
        children: [Text('The Stationer'), Text('25 sep 2026 09:41')],
      ),
      ReceiptLines(
        children: [
          ReceiptLine(qty: 3, price: Text('9.00'), child: Text('washi tape')),
          ReceiptLine(price: Text('2.10'), child: Text('glue stick')),
          ReceiptLine(qty: 12, price: Text('18.00'), child: Text('felt tips')),
        ],
      ),
      ReceiptTotal(circled: ReceiptPen.redfelt, child: Text('29.10')),
      ReceiptBarcode(value: '0042 1187 0925'),
      ReceiptFooter(Text('keep for your records')),
    ],
  );
}
