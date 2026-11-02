import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A short chat on graph paper: Ada asks, Sam answers in two bubbles.
///
/// Mirrors upstream `src/docs/content/home/chat-card.tsx`.
class ChatCard extends StatelessWidget {
  const ChatCard({super.key});

  @override
  Widget build(BuildContext context) => Paper(
    stock: StockName.graph,
    tape: PaperTape.both,
    seed: 'home-chat',
    padding: const EdgeInsets.fromLTRB(
      Spacing.d16,
      Spacing.d28,
      Spacing.d16,
      Spacing.d20,
    ),
    child: Semantics(
      container: true,
      label: 'A conversation with Sam',
      child: const MessageGroup(
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
                        seed: 'home-chat-1',
                        child: Text('Can I keep my shadcn habits?'),
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
                child: Avatar(children: [AvatarFallback(name: 'Sam Reyes')]),
              ),
              MessageContent(
                children: [
                  MessageHeader(child: Text('Sam')),
                  BubbleGroup(
                    children: [
                      Bubble(
                        variant: BubbleVariant.muted,
                        children: [
                          BubbleContent(
                            seed: 'home-chat-2',
                            child: Text('Yes. Same parts, same props.'),
                          ),
                        ],
                      ),
                      Bubble(
                        variant: BubbleVariant.muted,
                        children: [
                          BubbleContent(
                            seed: 'home-chat-3',
                            child: Text('Now they are Flutter widgets.'),
                          ),
                        ],
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
