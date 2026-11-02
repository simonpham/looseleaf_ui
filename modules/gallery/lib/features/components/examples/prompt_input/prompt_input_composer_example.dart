import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PromptInputComposerExample extends StatefulWidget {
  const PromptInputComposerExample({super.key});

  @override
  State<PromptInputComposerExample> createState() =>
      _PromptInputComposerExampleState();
}

class _PromptInputComposerExampleState
    extends State<PromptInputComposerExample> {
  static const _maxWidth = 576.0;

  final List<String> _sent = [];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.d8,
            0,
            Spacing.d8,
            Spacing.d12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d16,
            children: [
              PromptInput(
                seed: 'composer',
                onSubmit: (text) => setState(() => _sent.add(text)),
                children: [
                  const PromptInputBody(child: PromptInputTextarea()),
                  PromptInputFooter(
                    children: [
                      PromptInputTools(
                        children: [
                          PromptInputButton(
                            size: ButtonSize.iconSm,
                            semanticLabel: 'Attach a file',
                            onPressed: () {},
                            child: const InkIcon('paperclip'),
                          ),
                        ],
                      ),
                      const PromptInputHint(
                        Text('Enter to send, Shift+Enter for a new line'),
                      ),
                      const PromptInputSubmit(),
                    ],
                  ),
                ],
              ),
              Semantics(
                label: 'Sent',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d4,
                  children: [
                    for (final message in _sent)
                      Text(
                        message,
                        style: theme.typography.interface(
                          cssSize: 14,
                          color: theme.colors.ink,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
