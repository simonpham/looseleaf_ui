import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TextareaDisabledExample extends StatelessWidget {
  const TextareaDisabledExample({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: Spacing.d96 * 4),
    child: const SizedBox(
      width: double.infinity,
      child: Textarea(
        placeholder: 'Type your message here.',
        semanticLabel: 'Message',
        disabled: true,
      ),
    ),
  );
}
