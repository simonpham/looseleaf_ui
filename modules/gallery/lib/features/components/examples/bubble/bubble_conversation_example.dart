import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class BubbleConversationExample extends StatelessWidget {
  const BubbleConversationExample({super.key});

  static const _maxWidth = 512.0;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(
          Spacing.d12,
          0,
          Spacing.d12,
          Spacing.d24,
        ),
        child: MessageGroup(
          gap: Spacing.d20,
          children: [
            Message(
              children: [
                MessageAvatar(
                  child: Mascot(pose: 'idle', size: 36, seed: 'stubby'),
                ),
                MessageContent(
                  children: [
                    MessageHeader(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: 'Stubby '),
                            TextSpan(
                              text: '9:41',
                              style: TextStyle(fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    ),
                    BubbleGroup(
                      children: [
                        Bubble(
                          variant: BubbleVariant.muted,
                          children: [
                            BubbleContent(
                              seed: 'a1',
                              child: Text('I read src/notes/list.tsx first.'),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: Spacing.d8),
                          child: Bubble(
                            variant: BubbleVariant.muted,
                            children: [
                              BubbleContent(
                                seed: 'a2',
                                child: Text(
                                  'Tags become a string array on Note, with a chip row above the list. Want me to draw the chips small?',
                                ),
                              ),
                              BubbleReactions(
                                align: ChatAlign.start,
                                child: Text('+1'),
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
            Message(
              align: ChatAlign.end,
              children: [
                MessageContent(
                  children: [
                    MessageHeader(child: Text('you')),
                    BubbleGroup(
                      children: [
                        Bubble(
                          children: [
                            BubbleContent(
                              seed: 'u1',
                              child: Text(
                                'Yes, small. And can you put the filter row above the list?',
                              ),
                            ),
                          ],
                        ),
                        Bubble(
                          children: [
                            BubbleContent(
                              seed: 'u2',
                              child: Text('Thank you!'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    MessageFooter(child: Text('seen')),
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
