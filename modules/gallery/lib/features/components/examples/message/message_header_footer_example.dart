import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-lg`.
const _maxWidth = 512.0;

class MessageHeaderFooterExample extends StatelessWidget {
  const MessageHeaderFooterExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.d12,
            0,
            Spacing.d12,
            Spacing.d24,
          ),
          child: MessageGroup(
            gap: Spacing.d24,
            children: [
              Message(
                children: [
                  MessageContent(
                    children: [
                      MessageHeader(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: Spacing.d8,
                          children: [
                            Text(
                              'Lin',
                              style: TextStyle(color: theme.colors.ink),
                            ),
                            const Text(
                              'Thursday 9:12',
                              style: TextStyle(fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: Spacing.d12),
                        child: Bubble(
                          variant: BubbleVariant.secondary,
                          children: [
                            BubbleContent(
                              seed: 'hf-1',
                              child: Text(
                                'The chips look great. Ship it after lunch?',
                              ),
                            ),
                            BubbleReactions(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: Spacing.d4,
                                children: [
                                  InkIcon('check', size: Spacing.d14),
                                  Text('2'),
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
              const Message(
                align: ChatAlign.end,
                children: [
                  MessageContent(
                    children: [
                      Bubble(
                        children: [
                          BubbleContent(
                            seed: 'hf-2',
                            child: Text('After lunch, yes.'),
                          ),
                        ],
                      ),
                      MessageFooter(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: Spacing.d4,
                          children: [
                            InkIcon('check', size: Spacing.d14),
                            Text('seen 9:14'),
                          ],
                        ),
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
}
