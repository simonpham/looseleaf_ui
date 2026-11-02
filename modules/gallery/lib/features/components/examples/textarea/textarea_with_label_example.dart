import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TextareaWithLabelExample extends StatefulWidget {
  const TextareaWithLabelExample({super.key});

  @override
  State<TextareaWithLabelExample> createState() =>
      _TextareaWithLabelExampleState();
}

class _TextareaWithLabelExampleState extends State<TextareaWithLabelExample> {
  final _messageFocus = FocusNode();

  @override
  void dispose() {
    _messageFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: Spacing.d96 * 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d12,
      children: [
        Label(focusNode: _messageFocus, child: const Text('Your message')),
        Textarea(
          focusNode: _messageFocus,
          placeholder: 'Type your message here.',
        ),
      ],
    ),
  );
}
