import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-sm`.
const _maxWidth = Spacing.d384;

class MessageMarkdownExample extends StatelessWidget {
  const MessageMarkdownExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.d16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d32,
          children: [
            const Message(
              align: ChatAlign.end,
              children: [
                MessageContent(
                  children: [
                    Bubble(
                      children: [
                        BubbleContent(
                          child: Text('How do I render markdown in a message?'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Message(
              children: [
                MessageContent(
                  children: [
                    Bubble(
                      variant: BubbleVariant.ghost,
                      children: [
                        BubbleContent(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Here's how to render markdown in a message:",
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: Spacing.d8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _Step(
                                      number: 1,
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                'Render assistant text '
                                                'through ',
                                          ),
                                          TextSpan(
                                            text: 'Markdown',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          TextSpan(text: '.'),
                                        ],
                                      ),
                                    ),
                                    const _Step(
                                      number: 2,
                                      text: TextSpan(
                                        text:
                                            'Keep user messages as plain '
                                            'text.',
                                      ),
                                    ),
                                    _Step(
                                      number: 3,
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(text: 'Use a '),
                                          TextSpan(
                                            text: 'ghost',
                                            style: theme.typography.mono(
                                              cssSize: 14,
                                            ),
                                          ),
                                          const TextSpan(
                                            text:
                                                ' bubble so the response is '
                                                'unframed.',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final InlineSpan text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(width: Spacing.d20, child: Text('$number.')),
      Expanded(child: Text.rich(text)),
    ],
  );
}
