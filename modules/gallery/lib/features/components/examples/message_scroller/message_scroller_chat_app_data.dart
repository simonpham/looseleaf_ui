/// One piece of a chat turn in the "A whole chat" example.
sealed class MessageScrollerChatPart {
  const MessageScrollerChatPart();
}

/// Words in the turn.
class MessageScrollerChatText extends MessageScrollerChatPart {
  const MessageScrollerChatText(this.text);

  final String text;
}

/// A tool call and its result.
class MessageScrollerChatTool extends MessageScrollerChatPart {
  const MessageScrollerChatTool({required this.title, required this.result});

  final String title;
  final String result;
}

/// A code slip with a diff.
class MessageScrollerChatCode extends MessageScrollerChatPart {
  const MessageScrollerChatCode({required this.filename, required this.code});

  final String filename;
  final String code;
}

/// A file sent with a message.
typedef MessageScrollerChatFile = ({String name, String size});

/// One turn: yours or Stubby's.
class MessageScrollerChatTurn {
  const MessageScrollerChatTurn({
    required this.id,
    required this.mine,
    required this.parts,
    required this.time,
    this.files = const [],
  });

  final String id;
  final bool mine;
  final List<MessageScrollerChatPart> parts;
  final String time;
  final List<MessageScrollerChatFile> files;

  MessageScrollerChatTurn withParts(List<MessageScrollerChatPart> parts) =>
      MessageScrollerChatTurn(
        id: id,
        mine: mine,
        parts: parts,
        time: time,
        files: files,
      );
}

const _diff = '''-const shown = notes;
+const shown = picked.size
+  ? notes.filter((n) => n.tags.some((t) => picked.has(t)))
+  : notes;''';

/// Stubby's scripted reply.
const messageScrollerChatScript = <MessageScrollerChatPart>[
  MessageScrollerChatText(
    'I read src/notes/list.tsx first. Tags become a string array on Note, '
    'and the chips sit in a row above the list.',
  ),
  MessageScrollerChatTool(title: 'ran npm test', result: '12 passed'),
  MessageScrollerChatCode(filename: 'src/notes/filter.ts', code: _diff),
  MessageScrollerChatText(
    'Try #recipes first: the list narrows to the notes that carry it, and '
    'the count at the top stays honest.',
  ),
];

/// The transcript the chat opens with.
const messageScrollerChatStart = [
  MessageScrollerChatTurn(
    id: 'a0',
    mine: false,
    time: '9:40',
    parts: [MessageScrollerChatText('Good morning. What are we making?')],
  ),
  MessageScrollerChatTurn(
    id: 'u1',
    mine: true,
    time: '9:41',
    parts: [
      MessageScrollerChatText(
        'Can you add tags to my notes, and a filter row above the list?',
      ),
    ],
    files: [(name: 'field-notes.pdf', size: '2.4 MB')],
  ),
  MessageScrollerChatTurn(
    id: 'a1',
    mine: false,
    time: '9:41',
    parts: messageScrollerChatScript,
  ),
];

/// The files the paperclip attaches, in order.
const messageScrollerChatFiles = <MessageScrollerChatFile>[
  (name: 'tags-list.tsx', size: '4 KB'),
  (name: 'recipes.csv', size: '18 KB'),
  (name: 'harbour.jpg', size: '1.8 MB'),
];

/// One step of the streamed reply: how long to wait, and how it changes
/// the parts so far.
typedef MessageScrollerChatStep = ({
  Duration wait,
  List<MessageScrollerChatPart> Function(List<MessageScrollerChatPart>) apply,
});

/// The reply as steps: word by word for text, whole for the rest.
List<MessageScrollerChatStep> messageScrollerChatSteps() => [
  for (final part in messageScrollerChatScript)
    ...switch (part) {
      MessageScrollerChatText(:final text) => [
        for (final (k, word) in text.split(' ').indexed)
          (
            wait: const Duration(milliseconds: 85),
            apply: (List<MessageScrollerChatPart> parts) {
              final last = parts.lastOrNull;
              if (k > 0 && last is MessageScrollerChatText) {
                return [
                  ...parts.take(parts.length - 1),
                  MessageScrollerChatText('${last.text} $word'),
                ];
              }
              return [...parts, MessageScrollerChatText(word)];
            },
          ),
      ],
      _ => [
        (
          wait: const Duration(milliseconds: 700),
          apply: (List<MessageScrollerChatPart> parts) => [...parts, part],
        ),
      ],
    },
];
