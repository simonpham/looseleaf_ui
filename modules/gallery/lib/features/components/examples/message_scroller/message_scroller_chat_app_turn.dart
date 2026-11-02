import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/message_scroller/message_scroller.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// One turn of the "A whole chat" example: your outlined bubble with its
/// files, or Stubby's words, tool notes and code slips.
class MessageScrollerChatAppTurn extends StatelessWidget {
  const MessageScrollerChatAppTurn({
    super.key,
    required this.turn,
    required this.live,
  });

  final MessageScrollerChatTurn turn;

  /// Stubby is writing this turn right now.
  final bool live;

  @override
  Widget build(BuildContext context) {
    if (turn.mine) {
      final text = switch (turn.parts.firstOrNull) {
        MessageScrollerChatText(:final text) => text,
        _ => '',
      };
      return Message(
        align: ChatAlign.end,
        children: [
          MessageContent(
            children: [
              MessageHeader(child: Text('you · ${turn.time}')),
              Bubble(
                variant: BubbleVariant.outline,
                pen: BubblePen.you,
                children: [BubbleContent(seed: turn.id, child: Text(text))],
              ),
              if (turn.files.isNotEmpty) _Files(files: turn.files),
            ],
          ),
        ],
      );
    }
    return Message(
      children: [
        MessageAvatar(
          child: Mascot(
            pose: switch (live) {
              true => 'write',
              false => 'idle',
            },
            size: Spacing.d36,
            seed: 'stubby',
          ),
        ),
        MessageContent(
          children: [
            MessageHeader(child: Text('Stubby · ${turn.time}')),
            for (final (i, part) in turn.parts.indexed)
              switch (part) {
                MessageScrollerChatText(:final text) => Bubble(
                  variant: BubbleVariant.ghost,
                  children: [
                    BubbleContent(
                      child: MessageText(
                        text,
                        streaming: live && i == turn.parts.length - 1,
                        seed: '${turn.id}-$i',
                      ),
                    ),
                  ],
                ),
                MessageScrollerChatTool(:final title, :final result) =>
                  _ToolNote(title: title, result: result),
                MessageScrollerChatCode(:final filename, :final code) =>
                  Padding(
                    padding: const EdgeInsets.only(top: Spacing.d12),
                    child: CodeBlock(
                      diff: true,
                      language: 'ts',
                      filename: filename,
                      code: code,
                      seed: '${turn.id}-$i',
                    ),
                  ),
              },
          ],
        ),
      ],
    );
  }
}

class _ToolNote extends StatelessWidget {
  const _ToolNote({required this.title, required this.result});

  final String title;
  final String result;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final style = theme.typography.face(
      KevinSansFace.type,
      cssSize: 13,
      cssLineHeight: 1.375,
    );
    return Bubble(
      shape: BubbleShape.note,
      variant: BubbleVariant.muted,
      children: [
        BubbleContent(
          paper: const BubblePaper(tiltDegrees: -0.7, curl: false),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.d16,
            vertical: Spacing.d8,
          ),
          child: DefaultTextStyle.merge(
            style: style,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Spacing.d8,
              children: [
                const InkIcon('terminal', size: Spacing.d14),
                Flexible(child: Text(title)),
                Text(
                  result,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: theme.colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Files extends StatelessWidget {
  const _Files({required this.files});

  final List<MessageScrollerChatFile> files;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: Spacing.d8),
    child: Wrap(
      alignment: WrapAlignment.end,
      spacing: Spacing.d12,
      runSpacing: Spacing.d12,
      children: [
        for (final file in files)
          Attachment(
            size: AttachmentSize.sm,
            seed: file.name,
            children: [
              const AttachmentMedia(child: InkIcon('file-text')),
              AttachmentContent(
                children: [
                  AttachmentTitle(child: Text(file.name)),
                  AttachmentDescription(child: Text(file.size)),
                ],
              ),
            ],
          ),
      ],
    ),
  );
}
