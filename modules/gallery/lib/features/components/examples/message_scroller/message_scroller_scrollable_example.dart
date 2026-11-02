import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/message_scroller/message_scroller.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

final _messages = <MessageScrollerTurn>[
  for (var index = 0; index < 12; index++)
    (
      id: 'scrollable-${index + 1}',
      mine: index.isEven,
      text: switch (index.isEven) {
        true => 'Review scroll checkpoint ${index + 1}.',
        false =>
          'Checkpoint ${index + 1} is synced. The scrollable state updates '
              'as the viewport moves.\n\nWhen the reader is at the first '
              'message, the footer should only point them down. Once they '
              'move into the middle of the transcript, it should explain '
              'that both directions are available.\n\nAt the latest '
              'message, the footer should switch again and only point them '
              'back up.',
      },
    ),
];

class MessageScrollerScrollableExample extends StatelessWidget {
  const MessageScrollerScrollableExample({super.key});

  @override
  Widget build(BuildContext context) => MessageScrollerProvider(
    defaultPosition: MessageScrollerPosition.start,
    child: MessageScrollerDemoCard(
      title: 'Scroll Status',
      description:
          'Where the reader can go scroll to based on current scroll '
          'position.',
      caption: 'Scroll the transcript to see the footer update.',
      body: MessageScroller(
        children: [
          MessageScrollerViewport(
            child: MessageScrollerContent(
              gap: Spacing.d16,
              children: [
                for (final message in _messages)
                  MessageScrollerItem(
                    messageId: message.id,
                    scrollAnchor: message.mine,
                    child: MessageScrollerTurnMessage(turn: message),
                  ),
              ],
            ),
          ),
          const MessageScrollerButton(),
        ],
      ),
      footer: const _ScrollStatus(),
    ),
  );
}

class _ScrollStatus extends StatelessWidget {
  const _ScrollStatus();

  static String _status(MessageScrollerScrollable scrollable) =>
      switch ((scrollable.start, scrollable.end)) {
        (true, true) => 'You can scroll both ways.',
        (false, true) => 'You are at the top. You can only scroll down.',
        (true, false) => 'You are at the bottom. You can only scroll up.',
        (false, false) => 'All messages fit in the viewport.',
      };

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ValueListenableBuilder(
      valueListenable: MessageScrollerProvider.of(context).scrollable,
      builder: (context, scrollable, _) => Semantics(
        liveRegion: true,
        child: Text(
          _status(scrollable),
          textAlign: TextAlign.center,
          style: theme.typography.interface(
            cssSize: 14,
            color: theme.colors.inkMuted,
          ),
        ),
      ),
    );
  }
}
