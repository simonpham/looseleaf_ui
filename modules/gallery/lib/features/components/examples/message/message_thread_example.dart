import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-lg`.
const _maxWidth = 512.0;

class MessageThreadExample extends StatelessWidget {
  const MessageThreadExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(Spacing.d12, 0, Spacing.d12, Spacing.d16),
        child: MessageGroup(
          gap: Spacing.d20,
          children: [
            Message(
              align: ChatAlign.end,
              children: [
                MessageContent(
                  children: [
                    MessageHeader(child: Text('Ada')),
                    Bubble(
                      children: [
                        BubbleContent(
                          seed: 'thread-1',
                          child: Text('Which of these should I fix first?'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Message(
              children: [
                MessageAvatar(
                  child: Mascot(
                    pose: 'write',
                    size: Spacing.d40,
                    seed: 'thread-mascot',
                  ),
                ),
                MessageContent(
                  children: [
                    MessageHeader(child: Text('Stubby')),
                    BubbleGroup(
                      children: [
                        Bubble(
                          variant: BubbleVariant.muted,
                          children: [
                            BubbleContent(
                              seed: 'thread-2',
                              child: Text(
                                'The failing test. Everything else can wait '
                                'until it is green.',
                              ),
                            ),
                          ],
                        ),
                        Bubble(
                          variant: BubbleVariant.muted,
                          children: [
                            BubbleContent(
                              seed: 'thread-3',
                              child: Text('It is a one-line fix in filter.ts.'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    MessageFooter(child: Text('edited a minute ago')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
