import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/message_scroller/message_scroller.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _script = <MessageScrollerTurn>[
  (
    id: 'u1',
    mine: true,
    text:
        "I'm building a chat for our app and the scroll behavior is driving "
        'me nuts. Every time the AI streams a reply, the whole thread jumps '
        'around.',
  ),
  (
    id: 'a1',
    mine: false,
    text:
        "That's the classic streaming scroll problem. Wrap your message "
        'list in MessageScroller and turn on autoScroll: the viewport pins '
        'to the bottom as words arrive, so the reader sees each one land in '
        'place.\n\nIt only follows while the reader is already at the '
        'bottom. The moment they scroll up, it backs off and their place is '
        'kept.',
  ),
  (
    id: 'u2',
    mine: true,
    text:
        'Okay, but when someone sends a new message the view still feels '
        'jarring, like the whole conversation reloads from the top.',
  ),
  (
    id: 'a2',
    mine: false,
    text:
        'MessageScrollerItem fixes that with turn anchoring. Set '
        'scrollAnchor on the turn that should settle near the top instead '
        'of snapping to the bottom.\n\nA small peek of the previous exchange '
        "stays visible above the anchor, so context isn't lost. The reply "
        'starts in view without that disorienting jump you get from a plain '
        'overflow container.',
  ),
  (
    id: 'u3',
    mine: true,
    text:
        "And if they've scrolled up to re-read an older answer? I don't "
        'want to yank them back down.',
  ),
  (
    id: 'a3',
    mine: false,
    text:
        "You won't. Auto-scroll only runs when the viewport is already "
        'pinned to the bottom, so scrolling up is a deliberate opt-out. '
        'Their place stays put even as new words keep arriving below.\n\n'
        "When there is content they haven't seen yet, the jump button "
        'appears at the bottom of the viewport. One tap returns them to the '
        'newest message.',
  ),
];

const _defaultPeek = 64.0;

class MessageScrollerPreviousContextExample extends StatefulWidget {
  const MessageScrollerPreviousContextExample({super.key});

  @override
  State<MessageScrollerPreviousContextExample> createState() =>
      _MessageScrollerPreviousContextExampleState();
}

class _MessageScrollerPreviousContextExampleState
    extends State<MessageScrollerPreviousContextExample> {
  int _demoKey = 0;
  double _peek = _defaultPeek;
  int _shown = 2;

  MessageScrollerTurn? get _next => switch (_shown < _script.length) {
    true => _script[_shown],
    false => null,
  };

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return MessageScrollerProvider(
      key: ValueKey(_demoKey),
      scrollMargin: Spacing.d24,
      previousItemPeek: _peek,
      child: MessageScrollerDemoCard(
        title: 'Keeping Context Visible',
        description: 'New turns keep part of the previous reply in view.',
        action: Button(
          variant: ButtonVariant.outline,
          size: ButtonSize.icon,
          semanticLabel: 'Reset context example',
          onPressed: () => setState(() {
            _shown = 2;
            _peek = _defaultPeek;
            _demoKey++;
          }),
          child: const InkIcon('rotate-cw'),
        ),
        caption:
            'Adjust the slider and send. Observe the previous message peek.',
        body: MessageScroller(
          children: [
            MessageScrollerViewport(
              child: MessageScrollerContent(
                children: [
                  for (final message in _script.take(_shown))
                    MessageScrollerItem(
                      key: ValueKey(message.id),
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
        footerDivider: false,
        footer: MessageScrollerQueuedComposer(
          queued: _next?.text,
          emptyText: 'No messages queued. Reset the context.',
          onSend: () => setState(() => _shown += 2),
          tools: SizedBox(
            width: Spacing.d112,
            child: Row(
              spacing: Spacing.d8,
              children: [
                Text(
                  '${_peek.round()}px',
                  style: theme.typography
                      .interface(cssSize: 12, color: theme.colors.inkMuted)
                      .copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                ),
                Expanded(
                  child: Slider(
                    values: [_peek],
                    min: 64,
                    max: 128,
                    semanticLabel: 'Previous context peek',
                    onChanged: (values) => setState(
                      () => _peek = values.firstOrNull ?? _defaultPeek,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
