import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputStatesExample extends StatefulWidget {
  const InputStatesExample({super.key});

  @override
  State<InputStatesExample> createState() => _InputStatesExampleState();
}

class _InputStatesExampleState extends State<InputStatesExample> {
  static const _maxWidth = Spacing.d384;

  final _filled = TextEditingController(text: 'ada@analytical.engine');
  final _invalid = TextEditingController(text: 'not-an-email');
  final _disabled = TextEditingController(text: "Can't touch this");
  final _readOnly = TextEditingController(text: 'Order #2049');

  @override
  void dispose() {
    _filled.dispose();
    _invalid.dispose();
    _disabled.dispose();
    _readOnly.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d20,
      children: [
        Input(controller: _filled, semanticLabel: 'Filled'),
        Input(controller: _invalid, invalid: true, semanticLabel: 'Invalid'),
        Input(controller: _disabled, disabled: true, semanticLabel: 'Disabled'),
        Input(
          controller: _readOnly,
          readOnly: true,
          semanticLabel: 'Read only',
        ),
      ],
    ),
  );
}
