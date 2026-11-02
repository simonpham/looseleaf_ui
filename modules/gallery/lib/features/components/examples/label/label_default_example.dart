import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class LabelDefaultExample extends StatefulWidget {
  const LabelDefaultExample({super.key});

  @override
  State<LabelDefaultExample> createState() => _LabelDefaultExampleState();
}

class _LabelDefaultExampleState extends State<LabelDefaultExample> {
  final _nickFocus = FocusNode();

  @override
  void dispose() {
    _nickFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: Spacing.d384),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d8,
      children: [
        Label(focusNode: _nickFocus, child: const Text('Nickname')),
        Input(focusNode: _nickFocus, placeholder: 'What do they call you?'),
      ],
    ),
  );
}
