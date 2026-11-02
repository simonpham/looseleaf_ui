import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-lg`.
const _maxWidth = Spacing.d512;

class MessageYourOwnHandExample extends StatelessWidget {
  const MessageYourOwnHandExample({super.key});

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
                    MessageHeader(child: Text('you')),
                    Bubble(
                      variant: BubbleVariant.tinted,
                      pen: BubblePen.you,
                      children: [
                        BubbleContent(
                          seed: 'hand-1',
                          child: MessageText(
                            'Call me when the old road is closed, and bring '
                            'the good umbrella!',
                            seed: 'hand-words-1',
                          ),
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
                    seed: 'hand-mascot',
                  ),
                ),
                MessageContent(
                  children: [
                    MessageHeader(child: Text('Stubby')),
                    Bubble(
                      variant: BubbleVariant.muted,
                      children: [
                        BubbleContent(
                          seed: 'hand-2',
                          child: MessageText(
                            'Noted. I will call at six and read you the '
                            'whole plan aloud.',
                            seed: 'hand-words-2',
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
    ),
  );
}
