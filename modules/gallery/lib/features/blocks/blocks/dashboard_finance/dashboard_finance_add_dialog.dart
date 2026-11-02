import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/dashboard_finance/dashboard_finance.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The "Add transaction" button and its dialog: a name, an amount, in or
/// out, and the pot it came from.
class DashboardFinanceAddDialog extends StatefulWidget {
  const DashboardFinanceAddDialog({
    super.key,
    required this.date,
    required this.onAdd,
  });

  /// The date the new transaction gets.
  final String date;

  /// Gets the new transaction; its id is the caller's to give.
  final ValueChanged<FinanceTransaction> onAdd;

  @override
  State<DashboardFinanceAddDialog> createState() =>
      _DashboardFinanceAddDialogState();
}

class _DashboardFinanceAddDialogState extends State<DashboardFinanceAddDialog> {
  final _description = TextEditingController();
  final _amount = TextEditingController();
  final _descriptionFocus = FocusNode();
  final _amountFocus = FocusNode();
  final _categoryFocus = FocusNode();
  var _open = false;
  var _kind = 'out';
  var _category = 'Groceries';
  String? _descriptionError;
  String? _amountError;

  @override
  void dispose() {
    _description.dispose();
    _amount.dispose();
    _descriptionFocus.dispose();
    _amountFocus.dispose();
    _categoryFocus.dispose();
    super.dispose();
  }

  void _openChanged(bool next) {
    if (next) {
      _description.clear();
      _amount.clear();
      _kind = 'out';
      _category = 'Groceries';
      _descriptionError = null;
      _amountError = null;
    }
    setState(() => _open = next);
  }

  void _submit() {
    final cents = financeParseAmount(_amount.text);
    final description = _description.text.trim();
    setState(() {
      _descriptionError = switch (description.isEmpty) {
        true => 'Give it a name so you can find it later.',
        false => null,
      };
      _amountError = switch (cents) {
        null => 'Write an amount above zero, like 12.50.',
        _ => null,
      };
    });
    if (_descriptionError != null) {
      _descriptionFocus.requestFocus();
      return;
    }
    if (cents == null) {
      _amountFocus.requestFocus();
      return;
    }
    final income = _kind == 'in';
    widget.onAdd((
      id: 0,
      date: widget.date,
      description: description,
      account: 'Checking',
      category: switch (income) {
        true => 'Income',
        false => _category,
      },
      cents: switch (income) {
        true => cents,
        false => -cents,
      },
      status: FinanceStatus.pending,
    ));
    setState(() => _open = false);
  }

  @override
  Widget build(BuildContext context) => Dialog(
    open: _open,
    onOpenChange: _openChanged,
    content: DialogContent(
      tape: PaperTape.both,
      tapeKind: TapeKind.washiDots,
      children: [
        const DialogHeader(
          children: [
            DialogTitle(Text('Add a transaction')),
            DialogDescription(
              Text('It goes in as pending until the bank agrees.'),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d16,
          children: [
            Field(
              invalid: _descriptionError != null,
              children: [
                FieldLabel(
                  focusNode: _descriptionFocus,
                  child: const Text('What was it?'),
                ),
                Input(
                  controller: _description,
                  focusNode: _descriptionFocus,
                  invalid: _descriptionError != null,
                  placeholder: 'Ramen night',
                  onSubmitted: (_) => _submit(),
                ),
                if (_descriptionError case final error?)
                  FieldError(child: Text(error)),
              ],
            ),
            Field(
              invalid: _amountError != null,
              children: [
                FieldLabel(
                  focusNode: _amountFocus,
                  child: const Text('How much?'),
                ),
                Input(
                  controller: _amount,
                  focusNode: _amountFocus,
                  invalid: _amountError != null,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  placeholder: '12.50',
                  onSubmitted: (_) => _submit(),
                ),
                if (_amountError case final error?)
                  FieldError(child: Text(error)),
              ],
            ),
            InkRadioGroup<String>(
              value: _kind,
              direction: Axis.horizontal,
              semanticLabel: 'Money in or out',
              onChanged: (next) => setState(() => _kind = next),
              children: [
                for (final (value, label) in const [
                  ('out', 'Money out'),
                  ('in', 'Money in'),
                ])
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: Spacing.d8,
                    children: [
                      InkRadioGroupItem(value: value),
                      Label(
                        onPressed: () => setState(() => _kind = value),
                        child: Text(label),
                      ),
                    ],
                  ),
              ],
            ),
            if (_kind == 'out')
              Field(
                children: [
                  FieldLabel(
                    focusNode: _categoryFocus,
                    child: const Text('Which pot?'),
                  ),
                  Select(
                    value: _category,
                    onChanged: (next) => setState(() => _category = next),
                    content: SelectContent(
                      children: [
                        for (final category in financeCategories)
                          if (category != 'Income')
                            SelectItem(value: category, child: Text(category)),
                      ],
                    ),
                    child: SelectTrigger(focusNode: _categoryFocus),
                  ),
                ],
              ),
          ],
        ),
        DialogFooter(
          children: [
            Button(
              variant: ButtonVariant.outline,
              onPressed: () => setState(() => _open = false),
              child: const Text('Cancel'),
            ),
            Button(onPressed: _submit, child: const Text('Add it')),
          ],
        ),
      ],
    ),
    child: DialogTrigger.builder(
      builder: (context, dialog) => Button(
        onPressed: dialog.show,
        leading: const InkIcon('plus'),
        child: const Text('Add transaction'),
      ),
    ),
  );
}
