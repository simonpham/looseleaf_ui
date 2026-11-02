import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PromptInputCommandsAndMentionsExample extends StatefulWidget {
  const PromptInputCommandsAndMentionsExample({super.key});

  @override
  State<PromptInputCommandsAndMentionsExample> createState() =>
      _PromptInputCommandsAndMentionsExampleState();
}

class _PromptInputCommandsAndMentionsExampleState
    extends State<PromptInputCommandsAndMentionsExample> {
  static const _maxWidth = 576.0;

  final TextEditingController _text = TextEditingController(text: 'Thanks @');

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.d8,
          Spacing.d160,
          Spacing.d8,
          Spacing.d12,
        ),
        child: PromptInput(
          seed: 'mentions',
          controller: _text,
          triggers: const [
            PromptInputTrigger('/', atStart: true),
            PromptInputTrigger('@'),
          ],
          children: const [
            _Lists(),
            PromptInputBody(child: PromptInputTextarea()),
            PromptInputFooter(
              children: [
                PromptInputHint(Text('Type / for commands, @ for people')),
                PromptInputSubmit(),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _Lists extends StatelessWidget {
  const _Lists();

  static const _commands = [
    (name: 'summarize', hint: 'Sum up the thread'),
    (name: 'draw', hint: 'Sketch a diagram'),
    (name: 'clear', hint: 'Start a fresh page'),
  ];
  static const _people = ['Ada', 'Lin', 'Stubby', 'Grace'];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final model = PromptInputModel.of(context);
    final trigger = model.trigger;
    final query = (trigger?.query ?? '').toLowerCase();
    final commands = [
      if (trigger?.char == '/')
        for (final command in _commands)
          if (command.name.startsWith(query)) command,
    ];
    final people = [
      if (trigger?.char == '@')
        for (final person in _people)
          if (person.toLowerCase().startsWith(query)) person,
    ];
    final bold = TextStyle(
      fontWeight: FontWeight.w700,
      color: theme.colors.ink,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PromptInputSuggestions(
          trigger: '/',
          semanticLabel: 'Commands',
          open: commands.isNotEmpty,
          children: [
            for (final command in commands)
              PromptInputSuggestion(
                key: ValueKey(command.name),
                onSelect: () => model.replaceTrigger('/${command.name}'),
                children: [
                  const InkIcon('slash', size: Spacing.d14),
                  Text(command.name, style: bold),
                  Text(
                    command.hint,
                    style: TextStyle(color: theme.colors.inkMuted),
                  ),
                ],
              ),
          ],
        ),
        PromptInputSuggestions(
          trigger: '@',
          semanticLabel: 'People',
          open: people.isNotEmpty,
          children: [
            for (final person in people)
              PromptInputSuggestion(
                key: ValueKey(person),
                onSelect: () => model.replaceTrigger('@$person'),
                children: [
                  const InkIcon('user', size: Spacing.d14),
                  Text(person, style: bold),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
