import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-lg`.
const _maxWidth = Spacing.d512;

const _reply =
    'Tags now sit under each note as small chips. Pick one or two and the '
    'list narrows. I kept the count at the top honest, so it always shows '
    'what is left.';

class MessageStreamingExample extends StatefulWidget {
  const MessageStreamingExample({super.key});

  @override
  State<MessageStreamingExample> createState() =>
      _MessageStreamingExampleState();
}

class _MessageStreamingExampleState extends State<MessageStreamingExample> {
  final _words = _reply.split(' ');
  int _count = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _run();
  }

  void _run() {
    _timer?.cancel();
    setState(() => _count = 0);
    _timer = Timer.periodic(const Duration(milliseconds: 140), (timer) {
      if (_count >= _words.length) {
        timer.cancel();
        return;
      }
      setState(() => _count++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
            Spacing.d16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d12,
            children: [
              Message(
                children: [
                  MessageContent(
                    children: [
                      const MessageHeader(child: Text('Stubby')),
                      Bubble(
                        variant: BubbleVariant.muted,
                        children: [
                          BubbleContent(
                            seed: 'stream',
                            child: switch (_count) {
                              0 => Text(
                                '...',
                                style: TextStyle(color: theme.colors.inkMuted),
                              ),
                              _ => MessageText(
                                _words.take(_count).join(' '),
                                streaming: _count < _words.length,
                                seed: 'stream-words',
                              ),
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Button(
                variant: ButtonVariant.ghost,
                size: ButtonSize.sm,
                onPressed: _run,
                child: const Text('Replay'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
