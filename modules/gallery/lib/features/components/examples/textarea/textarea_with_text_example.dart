import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TextareaWithTextExample extends StatefulWidget {
  const TextareaWithTextExample({super.key});

  @override
  State<TextareaWithTextExample> createState() =>
      _TextareaWithTextExampleState();
}

class _TextareaWithTextExampleState extends State<TextareaWithTextExample> {
  static const _help = 'Your message will be copied to the support team.';

  final _messageFocus = FocusNode();

  @override
  void dispose() {
    _messageFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d384),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d12,
        children: [
          Label(focusNode: _messageFocus, child: const Text('Your Message')),
          Semantics(
            hint: _help,
            child: Textarea(
              focusNode: _messageFocus,
              placeholder: 'Type your message here.',
            ),
          ),
          ExcludeSemantics(
            child: Text(
              _help,
              style: theme.typography.interface(
                cssSize: 14,
                color: theme.colors.inkMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
