import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TextareaDemoExample extends StatelessWidget {
  const TextareaDemoExample({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: Spacing.d384),
    child: const SizedBox(
      width: double.infinity,
      child: Textarea(
        placeholder: 'Type your message here.',
        semanticLabel: 'Message',
      ),
    ),
  );
}
