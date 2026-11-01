import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';
import '../../support/paper_panel.dart';

const _invoices = [
  ('INV001', 'Paid', 'Credit card', r'$250.00'),
  ('INV002', 'Pending', 'PayPal', r'$150.00'),
  ('INV003', 'Unpaid', 'Bank transfer', r'$350.00'),
  ('INV004', 'Paid', 'Credit card', r'$450.00'),
  ('INV005', 'Paid', 'PayPal', r'$550.00'),
];

Widget _invoiceTable() => SizedBox(
  width: 560,
  child: InkTable(
    columnWidths: const {3: IntrinsicColumnWidth()},
    header: const TableHeader(
      rows: [
        InkTableRow(
          cells: [
            TableHead(child: Text('Invoice')),
            TableHead(child: Text('Status')),
            TableHead(child: Text('Method')),
            TableHead(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text('Amount'),
              ),
            ),
          ],
        ),
      ],
    ),
    body: TableBody(
      rows: [
        for (final (index, (invoice, status, method, amount))
            in _invoices.indexed)
          InkTableRow(
            selected: index == 1,
            expanded: index == 3,
            cells: [
              InkTableCell(child: Text(invoice)),
              InkTableCell(child: Text(status)),
              InkTableCell(child: Text(method)),
              InkTableCell(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(amount),
                ),
              ),
            ],
          ),
      ],
    ),
    footer: const TableFooter(
      rows: [
        InkTableRow(
          cells: [
            InkTableCell(child: Text('Total')),
            SizedBox(),
            SizedBox(),
            InkTableCell(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(r'$1,750.00'),
              ),
            ),
          ],
        ),
      ],
    ),
    caption: const TableCaption(child: Text('A list of your recent invoices.')),
  ),
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  for (final density in [LooseleafDensity.comfortable, LooseleafDensity.calm]) {
    testWidgets('table-invoices-${density.name} in the light theme', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1300, 1000);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        componentHost(
          paperPanel(_invoiceTable()),
          theme: LooseleafThemeData(density: density),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(RepaintBoundary).last,
        matchesGoldenFile('../goldens/table-invoices-${density.name}.png'),
      );
    });
  }
}
