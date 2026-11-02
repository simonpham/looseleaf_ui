import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/checkout_01/checkout_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The delivery choice: one card per method with what it costs today.
class Checkout01Delivery extends StatelessWidget {
  const Checkout01Delivery({
    super.key,
    required this.shipping,
    required this.focusNode,
  });

  /// What each method would cost on this basket, in cents.
  final Map<String, int> shipping;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) => InkFormField<String>(
    name: 'method',
    builder: (context, field) => FormItem(
      children: [
        FormControl(
          child: InkRadioGroup<String>(
            value: field.value,
            onChanged: field.onChanged,
            semanticLabel: 'Delivery',
            children: [
              for (final (index, method) in checkoutMethods.indexed)
                Padding(
                  padding: EdgeInsets.only(
                    top: switch (index) {
                      0 => 0,
                      _ => Spacing.d12,
                    },
                  ),
                  child: FieldLabel(
                    checked: field.value == method.id,
                    onPressed: () => field.onChanged(method.id),
                    child: Field(
                      orientation: FieldOrientation.horizontal,
                      children: [
                        FieldContent(
                          children: [
                            FieldTitle(
                              Row(
                                children: [
                                  Expanded(child: Text(method.name)),
                                  Text(
                                    switch (shipping[method.id] ?? 0) {
                                      0 => 'free',
                                      final cents => '€${money(cents)}',
                                    },
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FieldDescription(Text(method.help)),
                          ],
                        ),
                        InkRadioGroupItem(
                          value: method.id,
                          focusNode: switch (index) {
                            0 => focusNode,
                            _ => null,
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
