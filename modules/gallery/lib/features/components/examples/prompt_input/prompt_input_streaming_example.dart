import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PromptInputStreamingExample extends StatefulWidget {
  const PromptInputStreamingExample({super.key});

  @override
  State<PromptInputStreamingExample> createState() =>
      _PromptInputStreamingExampleState();
}

class _PromptInputStreamingExampleState
    extends State<PromptInputStreamingExample> {
  static const _maxWidth = 576.0;

  PromptInputStatus _status = PromptInputStatus.ready;
  final List<Timer> _timers = [];

  @override
  void dispose() {
    _clear();
    super.dispose();
  }

  void _clear() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  void _setStatus(PromptInputStatus status) => setState(() => _status = status);

  void _send(String _) {
    _clear();
    _setStatus(PromptInputStatus.submitted);
    _timers
      ..add(
        Timer(
          const Duration(milliseconds: 700),
          () => _setStatus(PromptInputStatus.streaming),
        ),
      )
      ..add(
        Timer(
          const Duration(milliseconds: 4200),
          () => _setStatus(PromptInputStatus.ready),
        ),
      );
  }

  void _stop() {
    _clear();
    _setStatus(PromptInputStatus.ready);
  }

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.d8,
          0,
          Spacing.d8,
          Spacing.d12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d12,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: Spacing.d32),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: TypingIndicator(
                  active: _status != PromptInputStatus.ready,
                  label: switch (_status) {
                    PromptInputStatus.submitted => 'Sent, waiting for a reply',
                    _ => 'Stubby is writing',
                  },
                  variant: TypingVariant.squiggle,
                  seed: 'stream',
                ),
              ),
            ),
            PromptInput(
              seed: 'stream',
              status: _status,
              onSubmit: _send,
              onStop: _stop,
              children: [
                const PromptInputBody(
                  child: PromptInputTextarea(placeholder: 'Ask something...'),
                ),
                PromptInputFooter(
                  children: [
                    PromptInputHint(
                      Text(switch (_status) {
                        PromptInputStatus.ready => 'Enter to send',
                        _ => 'Press stop to interrupt',
                      }),
                    ),
                    const PromptInputSubmit(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
