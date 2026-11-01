import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

void main() {
  testWidgets('is 288 wide, padded 20 × 32, zig ends on receipt stock', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const Receipt(
          seed: 'r',
          children: [
            ReceiptHeader(children: [Text('Cafe')]),
            ReceiptFooter(Text('thanks')),
          ],
        ),
      ),
    );
    final paper = tester.widget<Paper>(find.byType(Paper));
    expect(paper.stock, StockName.receipt);
    expect(paper.rules, RuleName.none);
    expect(paper.edge?.top, EdgeKind.zig);
    expect(paper.edge?.bottom, EdgeKind.zig);
    final sheet = tester.getRect(find.byType(Paper));
    expect(sheet.width, 288);
    final header = tester.getRect(find.byType(ReceiptHeader));
    expect(header.top - sheet.top, 32);
    expect(header.left - sheet.left, 20);
    expect(
      tester.getTopLeft(find.byType(ReceiptFooter)).dy - header.bottom,
      12,
    );
  });

  testWidgets('a line wraps the item and keeps the price at the end', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        Receipt(
          width: 160,
          children: [
            ReceiptLines(
              children: [
                ReceiptLine(
                  qty: 2,
                  price: const Text('6.20'),
                  child: Text('almond croissant ' * 3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    final line = tester.getRect(find.byType(ReceiptLine));
    final price = tester.getRect(find.text('6.20'));
    expect(price.right, line.right);
    expect(line.height, greaterThan(price.height * 2));
    expect(find.text('2 x ', findRichText: true), findsNothing);
  });

  testWidgets('a line reads as the item with its price', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(
        const ReceiptLine(price: Text('4.50'), child: Text('oat latte')),
      ),
    );
    expect(
      tester.getSemantics(find.byType(ReceiptLine)).label,
      'oat latte\n4.50',
    );
    handle.dispose();
  });

  testWidgets('the total is circled only when asked', (tester) async {
    await tester.pumpWidget(
      componentHost(const ReceiptTotal(child: Text('14.10'))),
    );
    expect(find.byType(InkSurface), findsNothing);
    expect(find.text('TOTAL'), findsOneWidget);
    await tester.pumpWidget(
      componentHost(
        const ReceiptTotal(
          circled: ReceiptPen.blue,
          seed: 'loop',
          child: Text('14.10'),
        ),
      ),
    );
    final surface = tester.widget<InkSurface>(find.byType(InkSurface));
    expect(surface.seed, 'loop');
  });

  testWidgets('the barcode is an image named after its number', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(
        const SizedBox(width: 220, child: ReceiptBarcode(value: '0042 1187')),
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Barcode 0042 1187')),
      matchesSemantics(label: 'Barcode 0042 1187', isImage: true),
    );
    final bars = find.byWidgetPredicate(
      (widget) =>
          widget is CustomPaint && widget.painter is ReceiptBarcodePainter,
    );
    expect(tester.getSize(bars), const Size(220, 44));
    handle.dispose();
  });

  testWidgets('the divider is a dashed hairline, decorative', (tester) async {
    await tester.pumpWidget(
      componentHost(const SizedBox(width: 100, child: ReceiptDivider())),
    );
    expect(tester.getSize(find.byType(ReceiptDivider)), const Size(100, 1));
  });

  testWidgets('a label names the receipt', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(const Receipt(semanticLabel: 'Receipt from Cafe')),
    );
    expect(find.bySemanticsLabel('Receipt from Cafe'), findsOneWidget);
    handle.dispose();
  });
}
