import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/checkout_01/checkout_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The three steps of the checkout: contact, delivery and payment.
class Checkout01Form extends StatefulWidget {
  const Checkout01Form({
    super.key,
    required this.form,
    required this.validators,
    required this.shipping,
  });

  final FormController form;

  /// The checks by field name, from [checkoutValidators].
  final Map<String, FormValidator> validators;

  /// What each delivery method would cost on this basket, in cents.
  final Map<String, int> shipping;

  @override
  State<Checkout01Form> createState() => _Checkout01FormState();
}

class _Checkout01FormState extends State<Checkout01Form> {
  static const List<String> _texts = [
    'email',
    'name',
    'address',
    'city',
    'postcode',
    'cardName',
    'cardNumber',
    'expiry',
    'cvc',
  ];
  static const double _postcodeWidth = 144;

  late final Map<String, TextEditingController> _controllers = {
    for (final name in _texts)
      name: TextEditingController(text: widget.form.value<String>(name)),
  };
  final Map<String, FocusNode> _focus = {
    for (final name in checkoutFieldLabels.keys) name: FocusNode(),
  };

  static final _cardNumber = TextInputFormatter.withFunction(
    (_, next) => _formatted(checkoutCardNumber(next.text)),
  );
  static final _expiry = TextInputFormatter.withFunction(
    (_, next) => _formatted(checkoutExpiry(next.text)),
  );

  static TextEditingValue _formatted(String text) => TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: text.length),
  );

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final node in _focus.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _focusField(String name) {
    final node = _focus[name];
    if (node == null) return;
    (node.traversalDescendants.firstOrNull ?? node).requestFocus();
  }

  Widget _text(
    String name, {
    required String placeholder,
    TextInputType? keyboardType,
    Iterable<String>? autofillHints,
    List<TextInputFormatter>? inputFormatters,
    String? leadingIcon,
  }) => Checkout01TextField(
    name: name,
    label: checkoutFieldLabels[name] ?? name,
    placeholder: placeholder,
    controller: _controllers[name] ?? TextEditingController(),
    focusNode: _focus[name] ?? FocusNode(),
    validator: widget.validators[name],
    keyboardType: keyboardType,
    autofillHints: autofillHints,
    inputFormatters: inputFormatters,
    leadingIcon: leadingIcon,
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final form = widget.form;
    final pickup = form.value<String>('method') == 'pickup';
    return InkForm(
      controller: form,
      semanticLabel: 'Checkout',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final city = _text(
            'city',
            placeholder: 'Lisbon',
            autofillHints: const [AutofillHints.addressCity],
          );
          final postcode = _text(
            'postcode',
            placeholder: '1100-148',
            autofillHints: const [AutofillHints.postalCode],
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d32,
            children: [
              if (form.isSubmitted && form.errors.isNotEmpty)
                Checkout01ErrorSummary(form: form, onFocus: _focusField),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d20,
                children: [
                  const Checkout01Heading(number: 1, text: 'Who is it for?'),
                  _text(
                    'email',
                    placeholder: 'ada@notes.dev',
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                  ),
                  _text(
                    'name',
                    placeholder: 'Ada Lovelace',
                    autofillHints: const [AutofillHints.name],
                  ),
                ],
              ),
              const Separator(variant: SeparatorVariant.dashed),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d20,
                children: [
                  const Checkout01Heading(
                    number: 2,
                    text: 'Where does it go?',
                  ),
                  Checkout01Delivery(
                    shipping: widget.shipping,
                    focusNode: _focus['method'] ?? FocusNode(),
                  ),
                  if (pickup)
                    Text(
                      'We will write to you when it is on the counter. Bring the email.',
                      style: theme.typography.interface(
                        cssSize: 14,
                        color: theme.colors.inkMuted,
                      ),
                    ),
                  if (!pickup) ...[
                    _text(
                      'address',
                      placeholder: "12 rue de l'Eau",
                      autofillHints: const [AutofillHints.fullStreetAddress],
                    ),
                    switch (constraints.maxWidth >= 448) {
                      true => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Spacing.d20,
                        children: [
                          Expanded(child: city),
                          SizedBox(width: _postcodeWidth, child: postcode),
                        ],
                      ),
                      false => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: Spacing.d20,
                        children: [city, postcode],
                      ),
                    },
                    InkFormField<String>(
                      name: 'country',
                      validator: widget.validators['country'],
                      builder: (context, field) => FormItem(
                        children: [
                          const FormLabel(Text('Country')),
                          FormControl(
                            child: NativeSelect(
                              value: field.value,
                              focusNode: _focus['country'],
                              invalid: field.invalid,
                              onChanged: field.onChanged,
                              options: [
                                for (final country in checkoutCountries)
                                  NativeSelectOption(
                                    value: country,
                                    label: country,
                                  ),
                              ],
                            ),
                          ),
                          const FormMessage(),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const Separator(variant: SeparatorVariant.dashed),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d20,
                children: [
                  const Checkout01Heading(
                    number: 3,
                    text: 'How are you paying?',
                  ),
                  _text(
                    'cardName',
                    placeholder: 'Ada Lovelace',
                    autofillHints: const [AutofillHints.creditCardName],
                  ),
                  _text(
                    'cardNumber',
                    placeholder: '4242 4242 4242 4242',
                    keyboardType: TextInputType.number,
                    autofillHints: const [AutofillHints.creditCardNumber],
                    inputFormatters: [_cardNumber],
                    leadingIcon: 'credit-card',
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Spacing.d20,
                    children: [
                      Expanded(
                        child: _text(
                          'expiry',
                          placeholder: 'MM/YY',
                          keyboardType: TextInputType.number,
                          autofillHints: const [
                            AutofillHints.creditCardExpirationDate,
                          ],
                          inputFormatters: [_expiry],
                        ),
                      ),
                      Expanded(
                        child: _text(
                          'cvc',
                          placeholder: '123',
                          keyboardType: TextInputType.number,
                          autofillHints: const [
                            AutofillHints.creditCardSecurityCode,
                          ],
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(4),
                          ],
                        ),
                      ),
                    ],
                  ),
                  InkFormField<bool>(
                    name: 'terms',
                    validator: widget.validators['terms'],
                    builder: (context, field) {
                      final ticked = field.value ?? false;
                      return FormItem(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: Spacing.d12,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: Spacing.d2),
                                child: FormControl(
                                  child: Checkbox(
                                    value: ticked,
                                    focusNode: _focus['terms'],
                                    invalid: field.invalid,
                                    onChanged: field.onChanged,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Label(
                                  onPressed: () => field.onChanged(!ticked),
                                  child: const Text(
                                    'I have read the small print: returns within 30 days, in their box.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      height: 1.375,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const FormMessage(),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
