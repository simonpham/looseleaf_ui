import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

List<({int id, String text})> _make(int from, int to) => [
  for (var id = from; id < to; id++) (id: id, text: 'Message number $id'),
];

class MessageScrollerEarlierMessagesExample extends StatefulWidget {
  const MessageScrollerEarlierMessagesExample({super.key});

  @override
  State<MessageScrollerEarlierMessagesExample> createState() =>
      _MessageScrollerEarlierMessagesExampleState();
}

class _MessageScrollerEarlierMessagesExampleState
    extends State<MessageScrollerEarlierMessagesExample> {
  List<({int id, String text})> _messages = _make(20, 40);

  void _loadEarlier() {
    final first = _messages.first.id;
    setState(
      () =>
          _messages = [..._make(math.max(0, first - 10), first), ..._messages],
    );
  }

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d448),
      child: SizedBox(
        height: 420,
        child: MessageScrollerProvider(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d12,
            children: [
              _Toolbar(onEarlier: _loadEarlier),
              Expanded(
                child: MessageScroller(
                  children: [
                    MessageScrollerViewport(
                      child: MessageScrollerContent(
                        children: [
                          if (_messages.first.id == 0)
                            const Marker(
                              variant: MarkerVariant.separator,
                              children: [
                                MarkerContent(child: Text('The beginning')),
                              ],
                            ),
                          for (final message in _messages)
                            MessageScrollerItem(
                              key: ValueKey(message.id),
                              messageId: 'm${message.id}',
                              child: _Line(id: message.id, text: message.text),
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
      ),
    ),
  );
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.onEarlier});

  final VoidCallback onEarlier;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final scroller = MessageScrollerProvider.of(context);
    return Wrap(
      spacing: Spacing.d8,
      runSpacing: Spacing.d8,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Button(
          variant: ButtonVariant.secondary,
          size: ButtonSize.sm,
          onPressed: onEarlier,
          child: const Text('Load 10 earlier'),
        ),
        Button(
          variant: ButtonVariant.ghost,
          size: ButtonSize.sm,
          onPressed: () => scroller.scrollToMessage(
            'm20',
            align: MessageScrollerAlign.center,
          ),
          child: const Text('Jump to 20'),
        ),
        ValueListenableBuilder(
          valueListenable: scroller.visibility,
          builder: (context, visibility, _) {
            final ids = visibility.visibleMessageIds;
            return Text(
              'in view: ${switch (ids.isEmpty) {
                true => 'none',
                false => ids.map((id) => id.substring(1)).join(', '),
              }}',
              style: theme.typography.interface(
                cssSize: 14,
                color: theme.colors.inkMuted,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.id, required this.text});

  final int id;
  final String text;

  @override
  Widget build(BuildContext context) {
    final mine = id % 3 == 0;
    return Message(
      align: switch (mine) {
        true => ChatAlign.end,
        false => ChatAlign.start,
      },
      children: [
        MessageContent(
          children: [
            Bubble(
              variant: switch (mine) {
                true => BubbleVariant.primary,
                false => BubbleVariant.muted,
              },
              children: [BubbleContent(seed: 'n-$id', child: Text(text))],
            ),
          ],
        ),
      ],
    );
  }
}
