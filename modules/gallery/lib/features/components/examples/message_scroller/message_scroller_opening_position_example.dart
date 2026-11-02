import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/message_scroller/message_scroller.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _messages = <MessageScrollerTurn>[
  (
    id: 'open-1',
    mine: true,
    text: 'This is the first message the user sent in the conversation.',
  ),
  (
    id: 'open-2',
    mine: false,
    text:
        'Workspace creation rose 8%, but first invite completion only rose '
        '2%.',
  ),
  (
    id: 'open-3',
    mine: true,
    text: 'This is the last message the user sent in the conversation.',
  ),
  (
    id: 'open-4',
    mine: false,
    text:
        'Start with the invite step. Teams are creating workspaces but '
        'waiting to add collaborators.\n\nRecommended follow-up:\n\n1. '
        'Compare invite drop-off by account size.\n2. Check whether users '
        'who skip invites still return within 24 hours.\n3. Review the '
        'empty-state copy on the first project screen.\n4. Segment '
        'activation by template, since template users may not need invites '
        'right away.\n\nIf that pattern holds, the next experiment should '
        'make collaboration useful earlier instead of prompting for invites '
        'harder.',
  ),
];

const _positions = [
  (MessageScrollerPosition.start, 'start'),
  (MessageScrollerPosition.end, 'end'),
  (MessageScrollerPosition.lastAnchor, 'last-anchor'),
];

class MessageScrollerOpeningPositionExample extends StatefulWidget {
  const MessageScrollerOpeningPositionExample({super.key});

  @override
  State<MessageScrollerOpeningPositionExample> createState() =>
      _MessageScrollerOpeningPositionExampleState();
}

class _MessageScrollerOpeningPositionExampleState
    extends State<MessageScrollerOpeningPositionExample> {
  MessageScrollerPosition _position = MessageScrollerPosition.lastAnchor;

  @override
  Widget build(BuildContext context) => MessageScrollerDemoCard(
    title: 'Opening Position',
    description: 'Choose where a saved transcript opens.',
    caption:
        'Toggle the defaultPosition to see where the transcript starts when '
        'you open the thread.',
    body: MessageScrollerProvider(
      key: ValueKey(_position),
      defaultPosition: _position,
      child: MessageScroller(
        children: [
          MessageScrollerViewport(
            child: MessageScrollerContent(
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
    ),
    footer: ToggleGroup<MessageScrollerPosition>(
      value: {_position},
      semanticLabel: 'Opening position',
      size: ToggleSize.sm,
      onChanged: (value) {
        if (value.firstOrNull case final position?) {
          setState(() => _position = position);
        }
      },
      children: [
        for (final (position, label) in _positions)
          Expanded(
            child: ToggleGroupItem(value: position, child: Text(label)),
          ),
      ],
    ),
  );
}
