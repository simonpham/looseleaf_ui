import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/message_scroller/message_scroller.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _script = <MessageScrollerTurn>[
  (
    id: 'anchor-1-user',
    mine: true,
    text:
        'Can you show me how anchoring behaves when a new prompt starts the '
        'turn?',
  ),
  (
    id: 'anchor-1-assistant',
    mine: false,
    text:
        'Append the user prompt first, then append the assistant response. '
        'With User selected, the prompt settles near the top and the '
        'assistant response fills in below it.',
  ),
  (
    id: 'anchor-2-user',
    mine: true,
    text: 'What changes when assistant messages are the anchor?',
  ),
  (
    id: 'anchor-2-assistant',
    mine: false,
    text:
        'Now each assistant response is the item MessageScroller keeps in '
        'view. This is useful when the reply is the moment you want readers '
        'to land on after each turn.',
  ),
  (
    id: 'anchor-3-user',
    mine: true,
    text: 'Can I switch roles and keep adding turns?',
  ),
  (
    id: 'anchor-3-assistant',
    mine: false,
    text:
        'Yes. The next appended message with the selected role becomes the '
        'anchor, so you can compare user and assistant anchoring without '
        'resetting the demo.',
  ),
];

class MessageScrollerAnchoringExample extends StatefulWidget {
  const MessageScrollerAnchoringExample({super.key});

  @override
  State<MessageScrollerAnchoringExample> createState() =>
      _MessageScrollerAnchoringExampleState();
}

class _MessageScrollerAnchoringExampleState
    extends State<MessageScrollerAnchoringExample> {
  bool _anchorUser = true;
  int _sent = 0;

  @override
  Widget build(BuildContext context) => MessageScrollerDemoCard(
    title: 'Anchoring Turns',
    description: 'Choose which role settles near the top edge.',
    action: Button(
      variant: ButtonVariant.outline,
      size: ButtonSize.icon,
      semanticLabel: 'Reset anchored turns',
      disabled: _sent == 0,
      onPressed: () => setState(() => _sent = 0),
      child: const InkIcon('rotate-cw'),
    ),
    caption:
        'Toggle the anchor role, then send messages to compare where turns '
        'settle.',
    body: switch (_sent == 0) {
      true => const Empty(
        children: [
          EmptyHeader(
            children: [
              EmptyMedia(
                variant: EmptyMediaVariant.icon,
                child: InkIcon('message-circle'),
              ),
              EmptyTitle(child: Text('No anchored messages yet')),
              EmptyDescription(
                child: Text(
                  'Send the first message to see the selected role anchor.',
                ),
              ),
            ],
          ),
        ],
      ),
      false => MessageScrollerProvider(
        child: MessageScroller(
          children: [
            MessageScrollerViewport(
              child: MessageScrollerContent(
                children: [
                  for (final message in _script.take(_sent))
                    MessageScrollerItem(
                      key: ValueKey(message.id),
                      messageId: message.id,
                      scrollAnchor: message.mine == _anchorUser,
                      child: MessageScrollerTurnMessage(
                        turn: message,
                        paragraphs: false,
                      ),
                    ),
                ],
              ),
            ),
            const MessageScrollerButton(),
          ],
        ),
      ),
    },
    footerDivider: false,
    footer: Row(
      children: [
        ToggleGroup<bool>(
          value: {_anchorUser},
          semanticLabel: 'Select scroll anchor role',
          onChanged: (value) {
            if (value.firstOrNull case final anchorUser?) {
              setState(() {
                _anchorUser = anchorUser;
                _sent = 0;
              });
            }
          },
          children: const [
            ToggleGroupItem(value: true, child: Text('User')),
            ToggleGroupItem(value: false, child: Text('Assistant')),
          ],
        ),
        const Spacer(),
        Button(
          size: ButtonSize.icon,
          semanticLabel: 'Send Message',
          disabled: _sent >= _script.length,
          onPressed: () => setState(() => _sent++),
          child: const InkIcon('arrow-up'),
        ),
      ],
    ),
  );
}
