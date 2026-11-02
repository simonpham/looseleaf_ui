import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TypingIndicatorStatusExample extends StatelessWidget {
  const TypingIndicatorStatusExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d384),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(Spacing.d16, 0, Spacing.d16, Spacing.d16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d16,
          children: [
            Message(
              children: [
                MessageAvatar(
                  child: Mascot(
                    pose: 'write',
                    size: Spacing.d40,
                    seed: 'ti-mascot',
                  ),
                ),
                MessageContent(
                  children: [
                    MessageHeader(child: Text('Stubby')),
                    Bubble(
                      variant: BubbleVariant.muted,
                      children: [
                        BubbleContent(
                          seed: 'ti-3',
                          child: TypingIndicator(
                            variant: TypingVariant.squiggle,
                            label: 'Stubby is writing a reply',
                            seed: 'ti-3',
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
                MessageContent(
                  children: [
                    MessageHeader(child: Text('Lin')),
                    Bubble(
                      variant: BubbleVariant.outline,
                      pen: BubblePen.you,
                      children: [
                        BubbleContent(
                          seed: 'ti-4',
                          child: TypingIndicator(
                            pen: TypingPen.you,
                            label: 'Lin is typing',
                            seed: 'ti-4',
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
