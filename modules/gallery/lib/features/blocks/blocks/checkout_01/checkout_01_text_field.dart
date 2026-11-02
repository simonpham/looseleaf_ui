import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// One labelled text input on the checkout form, with its message.
class Checkout01TextField extends StatelessWidget {
  const Checkout01TextField({
    super.key,
    required this.name,
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.focusNode,
    required this.validator,
    this.keyboardType,
    this.autofillHints,
    this.inputFormatters,
    this.leadingIcon,
  });

  final String name;
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FormValidator? validator;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;

  /// An icon in an input group addon before the text, like the card number's.
  final String? leadingIcon;

  @override
  Widget build(BuildContext context) => InkFormField<String>(
    name: name,
    validator: validator,
    builder: (context, field) => FormItem(
      children: [
        FormLabel(Text(label)),
        FormControl(
          child: switch (leadingIcon) {
            final icon? => InputGroup(
              focusNode: focusNode,
              invalid: field.invalid,
              children: [
                InputGroupAddon(child: InkIcon(icon)),
                InputGroupInput(
                  controller: controller,
                  placeholder: placeholder,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  onChanged: field.onChanged,
                ),
              ],
            ),
            null => Input(
              controller: controller,
              focusNode: focusNode,
              invalid: field.invalid,
              placeholder: placeholder,
              keyboardType: keyboardType,
              autofillHints: autofillHints,
              inputFormatters: inputFormatters,
              onChanged: field.onChanged,
            ),
          },
        ),
        const FormMessage(),
      ],
    ),
  );
}
