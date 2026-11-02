import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/settings_billing/settings_billing.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// "Replace card": a dialog with a checked card form that hands the new
/// card to [onSaved].
class SettingsBillingCardDialog extends StatefulWidget {
  const SettingsBillingCardDialog({
    super.key,
    required this.onSaved,
    this.today,
  });

  final ValueChanged<SavedCard> onSaved;

  /// The month cards must not have expired before; this month when null.
  final DateTime? today;

  @override
  State<SettingsBillingCardDialog> createState() =>
      _SettingsBillingCardDialogState();
}

class _SettingsBillingCardDialogState extends State<SettingsBillingCardDialog> {
  static const double _maxWidth = 448;
  static const _empty = {'name': '', 'number': '', 'expiry': '', 'cvc': ''};

  final _form = FormController(initialValues: _empty);
  final _name = TextEditingController();
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  final _cvc = TextEditingController();
  var _open = false;

  @override
  void dispose() {
    _form.dispose();
    _name.dispose();
    _number.dispose();
    _expiry.dispose();
    _cvc.dispose();
    super.dispose();
  }

  void _setOpen(bool open) {
    setState(() => _open = open);
    if (open) return;
    _form.reset();
    for (final text in [_name, _number, _expiry, _cvc]) {
      text.clear();
    }
  }

  void _submit() => unawaited(
    _form.handleSubmit((values) {
      final digits = '${values['number']}'.replaceAll(' ', '');
      widget.onSaved((
        brand: cardBrand(digits),
        last4: digits.substring(digits.length - 4),
        expiry: '${values['expiry']}',
      ));
      _setOpen(false);
    }),
  );

  static TextInputFormatter _formatter(String Function(String) format) =>
      TextInputFormatter.withFunction((old, value) {
        final text = format(value.text);
        return TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      });

  Widget _textField({
    required String name,
    required String label,
    required TextEditingController controller,
    required FormValidator validator,
    String? placeholder,
    List<TextInputFormatter>? formatters,
    List<String>? autofill,
  }) => InkFormField<String>(
    name: name,
    validator: validator,
    builder: (context, field) => FormItem(
      children: [
        FormLabel(Text(label)),
        FormControl(
          child: Input(
            controller: controller,
            invalid: field.invalid,
            placeholder: placeholder,
            keyboardType: switch (name) {
              'name' => TextInputType.name,
              _ => TextInputType.number,
            },
            inputFormatters: formatters,
            autofillHints: autofill,
            onChanged: field.onChanged,
            onSubmitted: (_) => _submit(),
          ),
        ),
        const FormMessage(),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Dialog(
    open: _open,
    onOpenChange: _setOpen,
    content: DialogContent(
      tape: PaperTape.top,
      seed: 'replace-card',
      maxWidth: _maxWidth,
      children: [
        const DialogHeader(
          children: [
            DialogTitle(Text('Replace your card')),
            DialogDescription(
              Text(
                'The next invoice is charged to the new card. The old one is forgotten as soon as you save.',
              ),
            ),
          ],
        ),
        InkForm(
          controller: _form,
          child: Semantics(
            container: true,
            label: 'Card details',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d20,
              children: [
                _textField(
                  name: 'name',
                  label: 'Name on card',
                  controller: _name,
                  validator: validateCardName,
                  placeholder: 'Jo Delacroix',
                  autofill: const [AutofillHints.creditCardName],
                ),
                InkFormField<String>(
                  name: 'number',
                  validator: validateCardNumber,
                  builder: (context, field) {
                    final brand = cardBrand(
                      digitsOf(field.value ?? ''),
                    );
                    return FormItem(
                      children: [
                        const FormLabel(Text('Card number')),
                        FormControl(
                          child: InputGroup(
                            invalid: field.invalid,
                            children: [
                              const InputGroupAddon(
                                child: InkIcon('credit-card'),
                              ),
                              InputGroupInput(
                                controller: _number,
                                placeholder: '4242 4242 4242 4242',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  _formatter(formatCardNumber),
                                ],
                                onChanged: field.onChanged,
                                onSubmitted: (_) => _submit(),
                              ),
                              if (brand != 'Card')
                                InputGroupAddon(
                                  align: InputGroupAlign.inlineEnd,
                                  child: InputGroupText(child: Text(brand)),
                                ),
                            ],
                          ),
                        ),
                        const FormMessage(),
                      ],
                    );
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d16,
                  children: [
                    Expanded(
                      child: _textField(
                        name: 'expiry',
                        label: 'Expires',
                        controller: _expiry,
                        validator: (value) => validateCardExpiry(
                          value,
                          widget.today ?? DateTime.now(),
                        ),
                        placeholder: 'MM/YY',
                        formatters: [_formatter(formatExpiry)],
                        autofill: const [
                          AutofillHints.creditCardExpirationDate,
                        ],
                      ),
                    ),
                    Expanded(
                      child: _textField(
                        name: 'cvc',
                        label: 'Security code',
                        controller: _cvc,
                        validator: validateCardCvc,
                        placeholder: '123',
                        formatters: [LengthLimitingTextInputFormatter(4)],
                        autofill: const [AutofillHints.creditCardSecurityCode],
                      ),
                    ),
                  ],
                ),
                DialogFooter(
                  children: [
                    DialogClose(
                      builder: (context, close) => Button(
                        variant: ButtonVariant.ghost,
                        onPressed: close,
                        child: const Text('Cancel'),
                      ),
                    ),
                    Button(onPressed: _submit, child: const Text('Save card')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    child: DialogTrigger.builder(
      builder: (context, dialog) => Button(
        variant: ButtonVariant.outline,
        size: ButtonSize.sm,
        onPressed: dialog.show,
        child: const Text('Replace card'),
      ),
    ),
  );
}
