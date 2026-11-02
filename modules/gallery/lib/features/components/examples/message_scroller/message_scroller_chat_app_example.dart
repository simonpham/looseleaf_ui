import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/message_scroller/message_scroller.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class MessageScrollerChatAppExample extends StatefulWidget {
  const MessageScrollerChatAppExample({super.key});

  @override
  State<MessageScrollerChatAppExample> createState() =>
      _MessageScrollerChatAppExampleState();
}

class _MessageScrollerChatAppExampleState
    extends State<MessageScrollerChatAppExample> {
  List<MessageScrollerChatTurn> _turns = messageScrollerChatStart;
  PromptInputStatus _status = PromptInputStatus.ready;
  List<MessageScrollerChatFile> _files = const [];
  String _announce = '';
  final List<Timer> _timers = [];
  int _counter = 2;

  bool get _busy => _status != PromptInputStatus.ready;

  void _stop() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
    setState(() => _status = PromptInputStatus.ready);
  }

  void _updateLast(MessageScrollerChatStep step) {
    final last = _turns.last;
    _turns = [
      ..._turns.take(_turns.length - 1),
      last.withParts(step.apply(last.parts)),
    ];
  }

  void _send(String text) {
    final n = _counter++;
    final attached = _files;
    setState(() {
      _files = const [];
      _turns = [
        ..._turns,
        MessageScrollerChatTurn(
          id: 'u$n',
          mine: true,
          time: 'now',
          parts: [
            MessageScrollerChatText(switch (text.isEmpty) {
              true => '(the files)',
              false => text,
            }),
          ],
          files: attached,
        ),
      ];
      _status = PromptInputStatus.submitted;
      _announce = '';
    });
    final steps = messageScrollerChatSteps();
    var at = const Duration(milliseconds: 700);
    _timers.add(
      Timer(
        at,
        () => setState(() {
          _status = PromptInputStatus.streaming;
          _turns = [
            ..._turns,
            MessageScrollerChatTurn(
              id: 'a$n',
              mine: false,
              time: 'now',
              parts: const [],
            ),
          ];
        }),
      ),
    );
    for (final (i, step) in steps.indexed) {
      at += step.wait;
      _timers.add(
        Timer(
          at,
          () => setState(() {
            _updateLast(step);
            if (i < steps.length - 1) return;
            _status = PromptInputStatus.ready;
            _announce = 'Stubby replied';
          }),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final busy = _busy;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 672),
        child: SizedBox(
          height: 740,
          child: Paper(
            stock: StockName.card,
            tilt: false,
            child: Padding(
              padding: const EdgeInsets.only(
                top: Spacing.d16,
                bottom: Spacing.d12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: Spacing.d24,
                      right: Spacing.d24,
                      bottom: Spacing.d8,
                    ),
                    child: Row(
                      spacing: Spacing.d12,
                      children: [
                        const Mascot(size: Spacing.d32, seed: 'header'),
                        Text(
                          'field-notes',
                          style: theme.typography.title(cssSize: 27),
                        ),
                        Flexible(
                          child: Text(
                            'on feature/tags',
                            style: theme.typography.interface(
                              cssSize: 14,
                              color: theme.colors.inkMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: MessageScrollerProvider(
                      autoScroll: true,
                      child: MessageScroller(
                        children: [
                          MessageScrollerViewport(
                            child: MessageScrollerContent(
                              children: [
                                const Marker(
                                  variant: MarkerVariant.separator,
                                  children: [
                                    MarkerContent(child: Text('Today')),
                                  ],
                                ),
                                for (final (i, turn) in _turns.indexed)
                                  MessageScrollerItem(
                                    key: ValueKey(turn.id),
                                    messageId: turn.id,
                                    scrollAnchor: turn.mine,
                                    child: MessageScrollerChatAppTurn(
                                      turn: turn,
                                      live:
                                          busy &&
                                          i == _turns.length - 1 &&
                                          !turn.mine,
                                    ),
                                  ),
                                if (_status == PromptInputStatus.submitted)
                                  const MessageScrollerItem(
                                    key: ValueKey('typing'),
                                    messageId: 'typing',
                                    child: Message(
                                      children: [
                                        MessageContent(
                                          children: [
                                            Bubble(
                                              variant: BubbleVariant.muted,
                                              children: [
                                                BubbleContent(
                                                  seed: 'typing',
                                                  child: TypingIndicator(
                                                    variant:
                                                        TypingVariant.squiggle,
                                                    label:
                                                        'Stubby is writing a reply',
                                                    seed: 'typing',
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
                  Semantics(liveRegion: true, label: _announce),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: Spacing.d12,
                      right: Spacing.d12,
                      top: Spacing.d4,
                    ),
                    child: PromptInput(
                      seed: 'chat',
                      status: _status,
                      onSubmit: _send,
                      onStop: _stop,
                      allowEmpty: _files.isNotEmpty,
                      children: [
                        PromptInputAttachments(
                          children: [
                            for (final file in _files)
                              Attachment(
                                key: ValueKey(file.name),
                                size: AttachmentSize.sm,
                                seed: file.name,
                                children: [
                                  const AttachmentMedia(
                                    child: InkIcon('file-text'),
                                  ),
                                  AttachmentContent(
                                    children: [
                                      AttachmentTitle(child: Text(file.name)),
                                      AttachmentDescription(
                                        child: Text(file.size),
                                      ),
                                    ],
                                  ),
                                  AttachmentActions(
                                    children: [
                                      _RemoveFile(
                                        name: file.name,
                                        onRemove: () => setState(
                                          () => _files = [
                                            for (final other in _files)
                                              if (other.name != file.name)
                                                other,
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const PromptInputBody(child: PromptInputTextarea()),
                        PromptInputFooter(
                          children: [
                            PromptInputTools(
                              children: [
                                PromptInputButton(
                                  size: ButtonSize.iconSm,
                                  semanticLabel: 'Attach a file',
                                  disabled:
                                      _files.length >=
                                      messageScrollerChatFiles.length,
                                  onPressed: () => setState(
                                    () => _files = [
                                      ..._files,
                                      messageScrollerChatFiles[_files.length],
                                    ],
                                  ),
                                  child: const InkIcon('paperclip'),
                                ),
                              ],
                            ),
                            PromptInputHint(
                              Text(switch (busy) {
                                true => 'Press stop to interrupt',
                                false => 'Enter to send',
                              }),
                            ),
                            const PromptInputSubmit(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RemoveFile extends StatelessWidget {
  const _RemoveFile({required this.name, required this.onRemove});

  final String name;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => AttachmentAction(
    semanticLabel: 'Remove $name',
    onPressed: () {
      onRemove();
      PromptInputModel.of(context).focus();
    },
    child: const InkIcon('x'),
  );
}
