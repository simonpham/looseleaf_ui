import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TextareaWithButtonExample extends StatelessWidget {
  const TextareaWithButtonExample({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: Spacing.d96 * 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d12,
      children: [
        const Textarea(
          placeholder: 'Type your message here.',
          semanticLabel: 'Message',
        ),
        Button(onPressed: () {}, child: const Text('Send message')),
      ],
    ),
  );
}
