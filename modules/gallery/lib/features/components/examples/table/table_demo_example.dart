import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _invoices = [
  (
    invoice: 'INV001',
    paymentStatus: 'Paid',
    totalAmount: r'$250.00',
    paymentMethod: 'Credit Card',
  ),
  (
    invoice: 'INV002',
    paymentStatus: 'Pending',
    totalAmount: r'$150.00',
    paymentMethod: 'PayPal',
  ),
  (
    invoice: 'INV003',
    paymentStatus: 'Unpaid',
    totalAmount: r'$350.00',
    paymentMethod: 'Bank Transfer',
  ),
  (
    invoice: 'INV004',
    paymentStatus: 'Paid',
    totalAmount: r'$450.00',
    paymentMethod: 'Credit Card',
  ),
  (
    invoice: 'INV005',
    paymentStatus: 'Paid',
    totalAmount: r'$550.00',
    paymentMethod: 'PayPal',
  ),
  (
    invoice: 'INV006',
    paymentStatus: 'Pending',
    totalAmount: r'$200.00',
    paymentMethod: 'Bank Transfer',
  ),
  (
    invoice: 'INV007',
    paymentStatus: 'Unpaid',
    totalAmount: r'$300.00',
    paymentMethod: 'Credit Card',
  ),
];

class TableDemoExample extends StatelessWidget {
  const TableDemoExample({super.key});

  @override
  Widget build(BuildContext context) => InkTable(
    columnWidths: const {0: FixedColumnWidth(100)},
    caption: const TableCaption(child: Text('A list of your recent invoices.')),
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
        for (final invoice in _invoices)
          InkTableRow(
            cells: [
              InkTableCell(
                child: Text(
                  invoice.invoice,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              InkTableCell(child: Text(invoice.paymentStatus)),
              InkTableCell(child: Text(invoice.paymentMethod)),
              InkTableCell(child: _End(Text(invoice.totalAmount))),
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
            InkTableCell(child: _End(Text(r'$2,500.00'))),
          ],
        ),
      ],
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
