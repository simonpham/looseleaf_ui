import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ReceiptDefaultExample extends StatelessWidget {
  const ReceiptDefaultExample({super.key});

  @override
  Widget build(BuildContext context) => const Receipt(
    seed: 'till',
    semanticLabel: 'Receipt from Looseleaf Cafe',
    children: [
      ReceiptHeader(
        children: [
          Text('Looseleaf Cafe'),
          Text("12 rue de l'Eau"),
          Text('25 sep 2026 14:02'),
        ],
      ),
      ReceiptLines(
        children: [
          ReceiptLine(qty: 1, price: Text('4.50'), child: Text('oat latte')),
          ReceiptLine(qty: 1, price: Text('3.40'), child: Text('flat white')),
          ReceiptLine(
            qty: 2,
            price: Text('6.20'),
            child: Text('almond croissant'),
          ),
        ],
      ),
      ReceiptTotal(child: Text('14.10')),
      ReceiptFooter(Text('thank you - come again')),
    ],
  );
}
