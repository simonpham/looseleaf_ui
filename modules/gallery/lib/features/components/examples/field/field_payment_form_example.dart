import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FieldPaymentFormExample extends StatefulWidget {
  const FieldPaymentFormExample({super.key});

  @override
  State<FieldPaymentFormExample> createState() =>
      _FieldPaymentFormExampleState();
}

class _FieldPaymentFormExampleState extends State<FieldPaymentFormExample> {
  static const _maxWidth = Spacing.d448;
  static const _months = [
    '01', '02', '03', '04', '05', '06', //
    '07', '08', '09', '10', '11', '12',
  ];
  static const _years = ['2026', '2027', '2028', '2029', '2030', '2031'];

  var _sameAsShipping = true;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: FieldGroup(
      children: [
        FieldSet(
          children: [
            const FieldLegend(Text('Payment Method')),
            const FieldDescription(
              Text('All transactions are secure and encrypted'),
            ),
            FieldGroup(
              children: [
                const Field(
                  children: [
                    FieldLabel(child: Text('Name on Card')),
                    Input(placeholder: 'Evil Rabbit'),
                  ],
                ),
                const Field(
                  children: [
                    FieldLabel(child: Text('Card Number')),
                    Input(placeholder: '1234 5678 9012 3456'),
                    FieldDescription(Text('Enter your 16-digit card number')),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d16,
                  children: [
                    Expanded(
                      child: Field(
                        children: [
                          const FieldLabel(child: Text('Month')),
                          Select(
                            content: SelectContent(
                              children: [
                                for (final month in _months)
                                  SelectItem(value: month, child: Text(month)),
                              ],
                            ),
                            child: const SelectTrigger(
                              child: SelectValue(placeholder: 'MM'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Field(
                        children: [
                          const FieldLabel(child: Text('Year')),
                          Select(
                            content: SelectContent(
                              children: [
                                for (final year in _years)
                                  SelectItem(value: year, child: Text(year)),
                              ],
                            ),
                            child: const SelectTrigger(
                              child: SelectValue(placeholder: 'YYYY'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Expanded(
                      child: Field(
                        children: [
                          FieldLabel(child: Text('CVV')),
                          Input(placeholder: '123'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const FieldSeparator(),
        FieldSet(
          children: [
            const FieldLegend(Text('Billing Address')),
            const FieldDescription(
              Text('The billing address associated with your payment method'),
            ),
            FieldGroup(
              children: [
                Field(
                  orientation: FieldOrientation.horizontal,
                  children: [
                    Checkbox(
                      value: _sameAsShipping,
                      onChanged: (value) =>
                          setState(() => _sameAsShipping = value),
                    ),
                    FieldLabel(
                      onPressed: () =>
                          setState(() => _sameAsShipping = !_sameAsShipping),
                      child: const Text(
                        'Same as shipping address',
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const FieldSet(
          children: [
            FieldGroup(
              children: [
                Field(
                  children: [
                    FieldLabel(child: Text('Comments')),
                    Textarea(
                      placeholder: 'Add any additional comments',
                      resizable: false,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Field(
          orientation: FieldOrientation.horizontal,
          children: [
            Button(onPressed: () {}, child: const Text('Submit')),
            Button(
              variant: ButtonVariant.outline,
              onPressed: () {},
              child: const Text('Cancel'),
            ),
          ],
        ),
      ],
    ),
  );
}
