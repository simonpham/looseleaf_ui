import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TextareaDefaultExample extends StatefulWidget {
  const TextareaDefaultExample({super.key});

  @override
  State<TextareaDefaultExample> createState() => _TextareaDefaultExampleState();
}

class _TextareaDefaultExampleState extends State<TextareaDefaultExample> {
  final _storyFocus = FocusNode();

  @override
  void dispose() {
    _storyFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: Spacing.d112 * 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d8,
      children: [
        Label(focusNode: _storyFocus, child: const Text('Your message')),
        Textarea(
          focusNode: _storyFocus,
          placeholder: 'Tell us what happened...',
        ),
      ],
    ),
  );
}
