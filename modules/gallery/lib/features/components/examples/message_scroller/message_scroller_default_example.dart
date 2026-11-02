import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _lines = [
  'Did the tags make it into the build?',
  'They did. The filter row is next.',
  'Can you draw the chips a little smaller?',
  'Smaller, yes. Two pixels off the padding.',
  'And the count at the top?',
  'It says 12 but the list has 11.',
  'Off by one, as ever.',
  'Found it: the archived note still counts.',
  'Fixed. Do you want a test for it?',
  'Yes please. One that would have caught it.',
  'Written. It fails on the old code and passes on the new.',
  'Lovely. Ship it after lunch?',
];

class MessageScrollerDefaultExample extends StatelessWidget {
  const MessageScrollerDefaultExample({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d448),
      child: SizedBox(
        height: 380,
        child: MessageScrollerProvider(
          child: MessageScroller(
            children: [
              MessageScrollerViewport(
                child: MessageScrollerContent(
                  children: [
                    for (final (i, text) in _lines.indexed)
                      MessageScrollerItem(
                        messageId: 'm$i',
                        child: Message(
                          align: switch (i.isOdd) {
                            true => ChatAlign.end,
                            false => ChatAlign.start,
                          },
                          children: [
                            MessageContent(
                              children: [
                                Bubble(
                                  variant: switch (i.isOdd) {
                                    true => BubbleVariant.primary,
                                    false => BubbleVariant.muted,
                                  },
                                  children: [
                                    BubbleContent(
                                      seed: 'line-$i',
                                      child: Text(text),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const MessageScrollerButton(),
            ],
          ),
        ),
      ),
    ),
  );
}
