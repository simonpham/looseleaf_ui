import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/chat_app/chat_app.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// One turn of a thread: your outlined bubble with its files, or their
/// words, tool notes and code slips under their face.
///
/// Mirrors `TurnView` and `Parts` in upstream
/// `src/blocks/chat-app/components/chat-app-thread.tsx`.
class ChatAppTurnView extends StatelessWidget {
  const ChatAppTurnView({
    super.key,
    required this.turn,
    required this.conversation,
    required this.live,
  });

  final ChatAppTurn turn;
  final ChatAppConversation conversation;

  /// They are writing this turn right now.
  final bool live;

  Widget _files(WrapAlignment alignment) => Padding(
    padding: const EdgeInsets.only(top: Spacing.d8),
    child: Wrap(
      alignment: alignment,
      spacing: Spacing.d12,
      runSpacing: Spacing.d12,
      children: [for (final file in turn.files) ChatAppFileChip(file: file)],
    ),
  );

  Widget _part(int index, ChatAppPart part) {
    final prose = conversation.kind == ChatAppKind.assistant;
    final seed = '${turn.id}-$index';
    return switch (part) {
      ChatAppTool(:final title, :final result) => ChatAppToolNote(
        title: title,
        result: result,
      ),
      ChatAppCode(:final filename, :final code) => Padding(
        padding: const EdgeInsets.only(top: Spacing.d4),
        child: CodeBlock(
          diff: true,
          language: 'ts',
          filename: filename,
          code: code,
          seed: seed,
        ),
      ),
      ChatAppText(:final text) => Bubble(
        variant: switch (prose) {
          true => BubbleVariant.ghost,
          false => BubbleVariant.muted,
        },
        children: [
          BubbleContent(
            seed: seed,
            child: MessageText(
              text,
              streaming: live && index == turn.parts.length - 1,
              seed: seed,
            ),
          ),
        ],
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (turn.mine) {
      final text = switch (turn.parts.firstOrNull) {
        ChatAppText(:final text) => text,
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
              if (turn.files.isNotEmpty) _files(WrapAlignment.end),
            ],
          ),
        ],
      );
    }
    final name = turn.who ?? conversation.name;
    return Message(
      children: [
        MessageAvatar(
          child: ChatAppFace(
            conversation: conversation,
            name: name,
            size: switch (conversation.kind) {
              ChatAppKind.assistant => Spacing.d36,
              _ => Spacing.d32,
            },
          ),
        ),
        MessageContent(
          children: [
            MessageHeader(child: Text('$name · ${turn.time}')),
            for (final (i, part) in turn.parts.indexed) _part(i, part),
            if (turn.files.isNotEmpty) _files(WrapAlignment.start),
          ],
        ),
      ],
    );
  }
}
