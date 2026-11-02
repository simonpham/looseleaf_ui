import 'dart:async';

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
        "stays visible above the anchor, so context isn't lost.",
  ),
  (id: 'u3', mine: true, text: 'Last one: does this work with assistive tech?'),
  (
    id: 'a3',
    mine: false,
    text:
        'MessageScrollerContent is a log that announces new messages. The '
        'jump button is a real button, and it leaves the tab order when you '
        'are already at the end.',
  ),
];

class MessageScrollerDemoExample extends StatefulWidget {
  const MessageScrollerDemoExample({super.key});

  @override
  State<MessageScrollerDemoExample> createState() =>
      _MessageScrollerDemoExampleState();
}

class _MessageScrollerDemoExampleState
    extends State<MessageScrollerDemoExample> {
  List<MessageScrollerTurn> _messages = const [];
  bool _streaming = false;
  int _run = 0;
  Timer? _timer;

  MessageScrollerTurn? get _next => _script
      .where(
        (turn) =>
            turn.mine && !_messages.any((message) => message.id == turn.id),
      )
      .firstOrNull;

  void _send() {
    final next = _next;
    if (next == null || _streaming) return;
    final reply = _script[_script.indexOf(next) + 1];
    final words = reply.text.split(' ');
    var n = 0;
    setState(() {
      _messages = [..._messages, next, (id: reply.id, mine: false, text: '')];
      _streaming = true;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 45), (timer) {
      n++;
      setState(() {
        _messages = [
          for (final message in _messages)
            switch (message.id == reply.id) {
              true => (
                id: reply.id,
                mine: false,
                text: words.take(n).join(' '),
              ),
              false => message,
            },
        ];
        if (n < words.length) return;
        timer.cancel();
        _streaming = false;
      });
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _streaming = false;
      _messages = const [];
      _run++;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MessageScrollerDemoCard(
    title: 'New Chat',
    description: 'How can I help you today?',
    action: Button(
      variant: ButtonVariant.outline,
      size: ButtonSize.icon,
      semanticLabel: 'Reset conversation',
      disabled: _streaming,
      onPressed: _reset,
      child: const InkIcon('rotate-cw'),
    ),
    caption: 'Demo is read only. Press send to send the next message.',
    body: switch (_messages.isEmpty) {
      true => const Empty(
        children: [
          EmptyHeader(
            children: [
              EmptyMedia(
                variant: EmptyMediaVariant.icon,
                child: InkIcon('message-circle'),
              ),
              EmptyTitle(child: Text('Morning, Ada!')),
              EmptyDescription(
                child: Text(
                  'What are we working on today? Press send to start a new '
                  'conversation',
                ),
              ),
            ],
          ),
        ],
      ),
      false => MessageScrollerProvider(
        key: ValueKey(_run),
        autoScroll: true,
        child: MessageScroller(
          children: [
            MessageScrollerViewport(
              child: MessageScrollerContent(
                children: [
                  for (final (i, turn) in _messages.indexed)
                    MessageScrollerItem(
                      key: ValueKey(turn.id),
                      messageId: turn.id,
                      scrollAnchor: turn.mine,
                      child: MessageScrollerTurnMessage(
                        turn: turn,
                        text: MessageText(
                          turn.text,
                          streaming: _streaming && i == _messages.length - 1,
                          seed: turn.id,
                        ),
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
    footer: MessageScrollerQueuedComposer(
      queued: _next?.text,
      emptyText: 'No messages queued. Reset the conversation.',
      busy: _streaming,
      onSend: _send,
      tools: DropdownMenu(
        content: const DropdownMenuContent(
          align: OverlayAlign.start,
          side: OverlaySide.top,
          width: 176,
          children: [
            DropdownMenuItem(
              leading: InkIcon('paperclip'),
              child: Text('Add Photos & Files'),
            ),
            DropdownMenuSeparator(),
            DropdownMenuItem(
              leading: InkIcon('image'),
              child: Text('Create Image'),
            ),
            DropdownMenuItem(
              leading: InkIcon('sparkles'),
              child: Text('Deep Research'),
            ),
            DropdownMenuItem(
              leading: InkIcon('globe'),
              child: Text('Web Search'),
            ),
          ],
        ),
        child: DropdownMenuTrigger.builder(
          builder: (context, menu) => InputGroupButton(
            variant: ButtonVariant.outline,
            size: InputGroupButtonSize.iconSm,
            semanticLabel: 'Add files',
            onPressed: menu.toggle,
            child: const InkIcon('plus'),
          ),
        ),
      ),
    ),
  );
}
