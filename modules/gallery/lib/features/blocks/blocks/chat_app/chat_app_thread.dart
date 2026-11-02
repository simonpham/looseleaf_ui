import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/chat_app/chat_app.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The open conversation on a taped card: who it is with, the turns in a
/// message scroller, and a composer that attaches files and can stop a
/// reply half-way.
///
/// Mirrors `ChatAppThread` in upstream
/// `src/blocks/chat-app/components/chat-app-thread.tsx`.
class ChatAppThread extends StatefulWidget {
  const ChatAppThread({
    super.key,
    required this.conversation,
    required this.status,
    required this.announce,
    required this.onSend,
    required this.onStop,
    required this.onBack,
    required this.wide,
  });

  final ChatAppConversation conversation;
  final PromptInputStatus status;

  /// Read out when a reply lands.
  final String announce;
  final void Function(String text, List<ChatAppFile> files) onSend;
  final VoidCallback onStop;
  final VoidCallback onBack;

  /// Shows the list beside the thread, so there is no way back to draw.
  final bool wide;

  @override
  State<ChatAppThread> createState() => _ChatAppThreadState();
}

class _ChatAppThreadState extends State<ChatAppThread> {
  List<ChatAppFile> _files = const [];

  void _attach() {
    final attachable = widget.conversation.attachable;
    if (_files.length >= attachable.length) return;
    setState(() => _files = [..._files, attachable[_files.length]]);
  }

  void _remove(ChatAppFile file) => setState(
    () => _files = [
      for (final other in _files)
        if (other.name != file.name) other,
    ],
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final conversation = widget.conversation;
    final status = widget.status;
    final busy = status != PromptInputStatus.ready;
    final turns = conversation.turns;
    return Paper(
      stock: StockName.card,
      tiltDegrees: 0.25,
      tape: PaperTape.top,
      tapeKind: TapeKind.washiDots,
      seed: 'chat-thread',
      padding: const EdgeInsets.only(top: Spacing.d20, bottom: Spacing.d12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: switch (widget.wide) {
                true => Spacing.d24,
                false => Spacing.d16,
              },
              right: switch (widget.wide) {
                true => Spacing.d24,
                false => Spacing.d16,
              },
              bottom: Spacing.d8,
            ),
            child: Row(
              spacing: Spacing.d12,
              children: [
                if (!widget.wide)
                  Button(
                    variant: ButtonVariant.ghost,
                    size: ButtonSize.iconSm,
                    semanticLabel: 'Back to chats',
                    onPressed: widget.onBack,
                    child: InkIcon(
                      'arrow-left',
                      flip: switch (Directionality.of(context)) {
                        TextDirection.rtl => IconFlip.x,
                        TextDirection.ltr => IconFlip.none,
                      },
                    ),
                  ),
                ChatAppFace(conversation: conversation, size: Spacing.d40),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          conversation.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.face(
                            KevinSansFace.script,
                            cssSize: 27.2,
                            cssLineHeight: 1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        conversation.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.face(
                          KevinSansFace.hand,
                          cssSize: 14,
                          color: theme.colors.inkMuted,
                        ),
                      ),
                    ],
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
                    semanticLabel: 'Messages with ${conversation.name}',
                    child: MessageScrollerContent(
                      children: [
                        const Marker(
                          variant: MarkerVariant.separator,
                          children: [MarkerContent(child: Text('Today'))],
                        ),
                        for (final (i, turn) in turns.indexed)
                          MessageScrollerItem(
                            key: ValueKey(turn.id),
                            messageId: turn.id,
                            scrollAnchor: turn.mine,
                            child: ChatAppTurnView(
                              turn: turn,
                              conversation: conversation,
                              live:
                                  status == PromptInputStatus.streaming &&
                                  i == turns.length - 1 &&
                                  !turn.mine,
                            ),
                          ),
                        if (status == PromptInputStatus.submitted)
                          MessageScrollerItem(
                            key: const ValueKey('typing'),
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
                                                switch (conversation.kind) {
                                                  ChatAppKind.assistant =>
                                                    TypingVariant.squiggle,
                                                  _ => TypingVariant.dots,
                                                },
                                            label:
                                                '${conversation.replyFrom ?? conversation.name} is writing a reply',
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
          Semantics(liveRegion: true, label: widget.announce),
          Padding(
            padding: const EdgeInsets.only(
              left: Spacing.d12,
              right: Spacing.d12,
              top: Spacing.d4,
            ),
            child: PromptInput(
              seed: 'chat-composer',
              status: status,
              allowEmpty: _files.isNotEmpty,
              onStop: widget.onStop,
              onSubmit: (text) {
                widget.onSend(text, _files);
                setState(() => _files = const []);
              },
              children: [
                PromptInputAttachments(
                  children: [
                    for (final file in _files)
                      ChatAppFileChip(
                        key: ValueKey(file.name),
                        file: file,
                        actions: AttachmentActions(
                          children: [
                            ChatAppRemoveFile(
                              name: file.name,
                              onRemove: () => _remove(file),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                PromptInputBody(
                  child: PromptInputTextarea(
                    semanticLabel: 'Message ${conversation.name}',
                    placeholder: 'write something kind',
                  ),
                ),
                PromptInputFooter(
                  children: [
                    PromptInputTools(
                      children: [
                        PromptInputButton(
                          size: ButtonSize.iconSm,
                          semanticLabel: 'Attach a file',
                          disabled:
                              _files.length >= conversation.attachable.length,
                          onPressed: _attach,
                          child: const InkIcon('paperclip'),
                        ),
                      ],
                    ),
                    if (widget.wide)
                      PromptInputHint(
                        Text(switch (busy) {
                          true => 'Press stop to interrupt',
                          false => 'Enter to send, Shift+Enter for a new line',
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
    );
  }
}
