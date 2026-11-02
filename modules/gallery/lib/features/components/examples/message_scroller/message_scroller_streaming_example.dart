import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _reply =
    'Tags now sit under each note as small chips. Pick one or two and the '
    'list narrows. I kept the count at the top honest, so it always shows '
    'what is left. Archived notes no longer count, which was the '
    'off-by-one. There is a test for it now, and it fails on the old code. '
    'The chips are two pixels tighter, as you asked, and the filter row '
    'lives above the list so it does not jump when the list is empty.';

final _replyWords = _reply.split(' ');

class MessageScrollerStreamingExample extends StatefulWidget {
  const MessageScrollerStreamingExample({super.key});

  @override
  State<MessageScrollerStreamingExample> createState() =>
      _MessageScrollerStreamingExampleState();
}

class _MessageScrollerStreamingExampleState
    extends State<MessageScrollerStreamingExample> {
  final List<({int id, bool mine, String text})> _turns = [
    (id: 1, mine: true, text: 'Can you add tags to my notes?'),
    (
      id: 2,
      mine: false,
      text: 'Done: a tags array on Note, and a chip row above the list.',
    ),
  ];
  int _next = 3;
  int _shown = 0;
  Timer? _timer;

  bool get _streaming => _timer?.isActive ?? false;

  void _send() {
    setState(() {
      _turns.add((id: _next++, mine: true, text: 'Show me what changed.'));
      _shown = 0;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 110), (timer) {
      setState(() => _shown++);
      if (_shown < _replyWords.length) return;
      timer.cancel();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streaming = _streaming;
    final replying = streaming || _shown > 0;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Spacing.d448),
        child: SizedBox(
          height: 420,
          child: Column(
            children: [
              Expanded(
                child: MessageScrollerProvider(
                  autoScroll: true,
                  child: MessageScroller(
                    children: [
                      MessageScrollerViewport(
                        child: MessageScrollerContent(
                          children: [
                            for (final turn in _turns)
                              MessageScrollerItem(
                                key: ValueKey(turn.id),
                                messageId: 't${turn.id}',
                                scrollAnchor: turn.mine,
                                child: Message(
                                  align: switch (turn.mine) {
                                    true => ChatAlign.end,
                                    false => ChatAlign.start,
                                  },
                                  children: [
                                    MessageContent(
                                      children: [
                                        Bubble(
                                          variant: switch (turn.mine) {
                                            true => BubbleVariant.primary,
                                            false => BubbleVariant.muted,
                                          },
                                          children: [
                                            BubbleContent(
                                              seed: 'turn-${turn.id}',
                                              child: Text(turn.text),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            if (replying)
                              MessageScrollerItem(
                                key: const ValueKey('reply'),
                                messageId: 'reply',
                                child: Message(
                                  children: [
                                    MessageContent(
                                      children: [
                                        Bubble(
                                          variant: BubbleVariant.ghost,
                                          children: [
                                            BubbleContent(
                                              child: MessageText(
                                                _replyWords
                                                    .take(_shown)
                                                    .join(' '),
                                                streaming: streaming,
                                                seed: 'reply',
                                              ),
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
              Semantics(
                liveRegion: true,
                label: switch (replying && !streaming) {
                  true => 'Stubby replied',
                  false => '',
                },
                child: const SizedBox(height: Spacing.d12),
              ),
              Button(
                size: ButtonSize.sm,
                disabled: streaming,
                onPressed: _send,
                child: const Text('Send a message'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
