import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _invoices = [
  (
    invoice: 'INV001',
    status: 'Paid',
    method: 'Credit card',
    amount: r'$250.00',
  ),
  (invoice: 'INV002', status: 'Pending', method: 'PayPal', amount: r'$150.00'),
  (
    invoice: 'INV003',
    status: 'Unpaid',
    method: 'Bank transfer',
    amount: r'$350.00',
  ),
  (
    invoice: 'INV004',
    status: 'Paid',
    method: 'Credit card',
    amount: r'$450.00',
  ),
  (invoice: 'INV005', status: 'Paid', method: 'PayPal', amount: r'$550.00'),
];

class TableInvoicesExample extends StatelessWidget {
  const TableInvoicesExample({super.key});

  static const _maxWidth = 576.0;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: InkTable(
      columnWidths: const {0: FixedColumnWidth(Spacing.d112)},
      caption: const TableCaption(
        child: Text('A list of your recent invoices.'),
      ),
      header: const TableHeader(
        rows: [
          InkTableRow(
            cells: [
              TableHead(child: Text('Invoice')),
              TableHead(child: Text('Status')),
              TableHead(child: Text('Method')),
              TableHead(child: _End(Text('Amount'))),
            ],
          ),
        ],
      ),
      body: TableBody(
        rows: [
          for (final row in _invoices)
            InkTableRow(
              cells: [
                InkTableCell(
                  child: Text(
                    row.invoice,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                InkTableCell(child: Text(row.status)),
                InkTableCell(child: Text(row.method)),
                InkTableCell(child: _End(_Figures(row.amount))),
              ],
            ),
        ],
      ),
      footer: const TableFooter(
        rows: [
          InkTableRow(
            cells: [
              InkTableCell(child: Text('Total')),
              InkTableCell(child: SizedBox.shrink()),
              InkTableCell(child: SizedBox.shrink()),
              InkTableCell(child: _End(_Figures(r'$1,750.00'))),
            ],
          ),
        ],
      ),
    ),
  );
}

class _End extends StatelessWidget {
  const _End(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Align(alignment: AlignmentDirectional.centerEnd, child: child);
}

class _Figures extends StatelessWidget {
  const _Figures(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
  );
}
