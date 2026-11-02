import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/settings_billing/settings_billing.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The newest invoices as till receipts, each with a download button, and
/// a link that shows the older ones.
class SettingsBillingInvoices extends StatefulWidget {
  const SettingsBillingInvoices({
    super.key,
    required this.invoices,
    this.onDownload,
  });

  final List<Invoice> invoices;
  final ValueChanged<Invoice>? onDownload;

  @override
  State<SettingsBillingInvoices> createState() =>
      _SettingsBillingInvoicesState();
}

class _SettingsBillingInvoicesState extends State<SettingsBillingInvoices> {
  static const int _first = 3;

  var _all = false;

  Widget _invoice(Invoice invoice, int index, double width) => Column(
    spacing: Spacing.d12,
    children: [
      Receipt(
        width: width,
        seed: 'invoice-${invoice.number}',
        semanticLabel: 'Invoice ${invoice.number}',
        ends: switch (index.isOdd) {
          true => EdgeKind.perf,
          false => EdgeKind.zig,
        },
        children: [
          ReceiptHeader(
            children: [
              const Text('Looseleaf'),
              Text('Invoice ${invoice.number}'),
              Text(invoice.date),
            ],
          ),
          ReceiptLines(
            children: [
              for (final line in invoice.lines)
                ReceiptLine(price: Text(line.price), child: Text(line.name)),
            ],
          ),
          ReceiptTotal(
            circled: switch (index) {
              0 => ReceiptPen.redfelt,
              _ => null,
            },
            child: Text(invoice.total),
          ),
          ReceiptFooter(Text('paid by ${invoice.paidWith} - thank you')),
        ],
      ),
      Button(
        variant: ButtonVariant.outline,
        size: ButtonSize.sm,
        semanticLabel: 'Download invoice ${invoice.number}',
        onPressed: () => widget.onDownload?.call(invoice),
        leading: const InkIcon('download'),
        child: const Text('Download PDF'),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final invoices = widget.invoices;
    final shown = switch (_all) {
      true => invoices,
      false => invoices.take(_first).toList(),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d24,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = switch (constraints.maxWidth < Receipt.defaultWidth) {
              true => constraints.maxWidth,
              false => Receipt.defaultWidth,
            };
            return Wrap(
              spacing: Spacing.d24,
              runSpacing: Spacing.d40,
              children: [
                for (final (index, invoice) in shown.indexed)
                  _invoice(invoice, index, width),
              ],
            );
          },
        ),
        if (invoices.length > _first)
          Semantics(
            expanded: _all,
            child: Button(
              variant: ButtonVariant.link,
              onPressed: () => setState(() => _all = !_all),
              child: Text(switch (_all) {
                true => 'Show fewer invoices',
                false => 'Show ${invoices.length - _first} older invoices',
              }),
            ),
          ),
      ],
    );
  }
}
