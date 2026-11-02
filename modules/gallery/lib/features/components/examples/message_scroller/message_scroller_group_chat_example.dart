import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/message_scroller/message_scroller.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

enum _RockyTurn { idle, marker, message }

typedef _GroupMessage = ({
  String id,
  String sender,
  bool assistant,
  String text,
  bool scrollAnchor,
});

const _currentUser = 'Grace';

const _initial = <_GroupMessage>[
  (
    id: 'group-1',
    sender: 'Grace',
    assistant: false,
    text:
        '@mary, the astrophage line keeps matching Venus energy output. Can '
        'you check my math?',
    scrollAnchor: false,
  ),
  (
    id: 'group-2',
    sender: 'Mary (Agent)',
    assistant: true,
    text:
        'Yes. Confirmed. The curve points to a microorganism harvesting '
        'stellar energy and breeding near carbon dioxide. If @rocky agrees, '
        'this is the clue we need.',
    scrollAnchor: false,
  ),
  (
    id: 'group-3',
    sender: 'Grace',
    assistant: false,
    text: 'ping @rocky',
    scrollAnchor: true,
  ),
];

const _rockyMessage = (
  id: 'group-5',
  sender: 'Rocky',
  assistant: false,
  text:
      'Amaze. Astrophage eats light, makes heat, goes to carbon dioxide. '
      'Rocky has fuel model. Grace is smart.',
  scrollAnchor: false,
);

class MessageScrollerGroupChatExample extends StatefulWidget {
  const MessageScrollerGroupChatExample({super.key});

  @override
  State<MessageScrollerGroupChatExample> createState() =>
      _MessageScrollerGroupChatExampleState();
}

class _MessageScrollerGroupChatExampleState
    extends State<MessageScrollerGroupChatExample> {
  int _demoKey = 0;
  _RockyTurn _rockyTurn = _RockyTurn.idle;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final idle = _rockyTurn == _RockyTurn.idle;
    return MessageScrollerDemoCard(
      title: 'Group Chat',
      description:
          'A group chat with several participants and an assistant. The '
          'Marker is marked as a turn.',
      action: Button(
        variant: ButtonVariant.outline,
        size: ButtonSize.icon,
        semanticLabel: 'Reset conversation',
        disabled: idle,
        onPressed: () => setState(() {
          _rockyTurn = _RockyTurn.idle;
          _demoKey++;
        }),
        child: const InkIcon('rotate-cw'),
      ),
      caption:
          'When a user joins, a marker is created. scrollAnchor on the '
          'marker marks it as the next turn.',
      body: MessageScrollerProvider(
        key: ValueKey(_demoKey),
        child: MessageScroller(
          children: [
            MessageScrollerViewport(
              child: MessageScrollerContent(
                children: [
                  for (final message in _initial)
                    _GroupChatMessage(key: ValueKey(message.id), item: message),
                  if (!idle)
                    const MessageScrollerItem(
                      key: ValueKey('group-4'),
                      scrollAnchor: true,
                      child: Marker(
                        variant: MarkerVariant.separator,
                        children: [
                          MarkerContent(
                            child: Text('Rocky has joined the chat'),
                          ),
                        ],
                      ),
                    ),
                  if (_rockyTurn == _RockyTurn.message)
                    _GroupChatMessage(
                      key: ValueKey(_rockyMessage.id),
                      item: _rockyMessage,
                    ),
                ],
              ),
            ),
            const MessageScrollerButton(),
          ],
        ),
      ),
      footer: Column(
        spacing: Spacing.d8,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Button(
            variant: ButtonVariant.secondary,
            disabled: _rockyTurn == _RockyTurn.message,
            onPressed: () => setState(
              () => _rockyTurn = switch (idle) {
                true => _RockyTurn.marker,
                false => _RockyTurn.message,
              },
            ),
            child: Text(switch (idle) {
              true => 'Add Rocky',
              false => 'Send Message as Rocky',
            }),
          ),
          Text(
            switch (idle) {
              true => 'This will create a marker and make it the anchor',
              false => "Now send Rocky's reply into the conversation",
            },
            textAlign: TextAlign.center,
            style: theme.typography.interface(
              cssSize: 12,
              color: theme.colors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupChatMessage extends StatelessWidget {
  const _GroupChatMessage({super.key, required this.item});

  final _GroupMessage item;

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = item.sender == _currentUser;
    return MessageScrollerItem(
      messageId: item.id,
      scrollAnchor: item.scrollAnchor,
      child: Message(
        align: switch (isCurrentUser) {
          true => ChatAlign.end,
          false => ChatAlign.start,
        },
        children: [
          MessageContent(
            children: [
              if (!isCurrentUser) MessageHeader(child: Text(item.sender)),
              Bubble(
                variant: switch ((isCurrentUser, item.assistant)) {
                  (true, _) => BubbleVariant.muted,
                  (false, true) => BubbleVariant.ghost,
                  (false, false) => BubbleVariant.tinted,
                },
                children: [BubbleContent(child: Text(item.text))],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
