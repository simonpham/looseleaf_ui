import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputTypesExample extends StatefulWidget {
  const InputTypesExample({super.key});

  @override
  State<InputTypesExample> createState() => _InputTypesExampleState();
}

class _InputTypesExampleState extends State<InputTypesExample> {
  static const _maxWidth = Spacing.d384;
  static const _dateWidth = 176.0;

  final _password = TextEditingController(text: 'hunter2hunter2');
  final _quantity = TextEditingController(text: '3');
  final _passwordFocus = FocusNode();
  final _quantityFocus = FocusNode();
  final _dueFocus = FocusNode();

  @override
  void dispose() {
    _password.dispose();
    _quantity.dispose();
    _passwordFocus.dispose();
    _quantityFocus.dispose();
    _dueFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d16,
      children: [
        _Row(
          label: Label(
            focusNode: _passwordFocus,
            child: const Text('Password'),
          ),
          input: Input(
            controller: _password,
            focusNode: _passwordFocus,
            obscureText: true,
          ),
        ),
        _Row(
          label: Label(
            focusNode: _quantityFocus,
            child: const Text('Quantity'),
          ),
          input: SizedBox(
            width: Spacing.d96,
            child: Input(
              controller: _quantity,
              focusNode: _quantityFocus,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
        ),
        _Row(
          label: Label(focusNode: _dueFocus, child: const Text('Due')),
          input: SizedBox(
            width: _dateWidth,
            child: Input(
              focusNode: _dueFocus,
              keyboardType: TextInputType.datetime,
              placeholder: 'yyyy-mm-dd',
            ),
          ),
        ),
      ],
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.input});

  final Widget label;
  final Widget input;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d8,
    children: [label, input],
  );
}
