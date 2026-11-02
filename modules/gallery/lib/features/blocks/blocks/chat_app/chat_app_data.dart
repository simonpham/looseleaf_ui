/// One piece of a chat turn.
///
/// Mirrors `ChatPart` in upstream `src/blocks/chat-app/components/chat-app-data.ts`.
sealed class ChatAppPart {
  const ChatAppPart();
}

/// Words in the turn.
class ChatAppText extends ChatAppPart {
  const ChatAppText(this.text);

  final String text;
}

/// A tool call and its result.
class ChatAppTool extends ChatAppPart {
  const ChatAppTool({required this.title, required this.result});

  final String title;
  final String result;
}

/// A code slip with a diff.
class ChatAppCode extends ChatAppPart {
  const ChatAppCode({required this.filename, required this.code});

  final String filename;
  final String code;
}

/// A file sent with a message.
typedef ChatAppFile = ({String name, String size});

/// One turn: yours or theirs.
class ChatAppTurn {
  const ChatAppTurn({
    required this.id,
    required this.mine,
    required this.time,
    required this.parts,
    this.who,
    this.files = const [],
  });

  final String id;
  final bool mine;

  /// Who in a group wrote it.
  final String? who;
  final String time;
  final List<ChatAppPart> parts;
  final List<ChatAppFile> files;

  ChatAppTurn withParts(List<ChatAppPart> parts) => ChatAppTurn(
    id: id,
    mine: mine,
    who: who,
    time: time,
    parts: parts,
    files: files,
  );
}

/// Who is on the other end.
enum ChatAppKind { assistant, person, group }

/// A conversation, with the reply it will write to whatever you send.
class ChatAppConversation {
  const ChatAppConversation({
    required this.id,
    required this.name,
    required this.kind,
    required this.subtitle,
    required this.time,
    required this.turns,
    required this.reply,
    required this.attachable,
    this.unread = 0,
    this.replyFrom,
  });

  final String id;
  final String name;
  final ChatAppKind kind;
  final String subtitle;
  final String time;
  final int unread;
  final List<ChatAppTurn> turns;
  final List<ChatAppPart> reply;
  final String? replyFrom;

  /// The files the paperclip attaches, in order.
  final List<ChatAppFile> attachable;

  ChatAppConversation copyWith({
    String? time,
    int? unread,
    List<ChatAppTurn>? turns,
  }) => ChatAppConversation(
    id: id,
    name: name,
    kind: kind,
    subtitle: subtitle,
    time: time ?? this.time,
    unread: unread ?? this.unread,
    turns: turns ?? this.turns,
    reply: reply,
    replyFrom: replyFrom,
    attachable: attachable,
  );

  /// The last line, for the list: "You: …", "Mo: …" or just the words.
  String get snippet {
    final last = turns.lastOrNull;
    if (last == null) return 'Nothing written yet';
    final text = last.parts.reversed.whereType<ChatAppText>().firstOrNull;
    final line = text?.text ?? last.files.firstOrNull?.name ?? 'An attachment';
    final who = switch ((last.mine, last.who)) {
      (true, _) => 'You: ',
      (false, final String who) => '$who: ',
      _ => '',
    };
    return '$who$line';
  }
}

/// One step of a streamed reply: how long to wait, and how it changes the
/// parts so far.
typedef ChatAppStep = ({
  Duration wait,
  List<ChatAppPart> Function(List<ChatAppPart> parts) apply,
});

/// A scripted reply as steps: word by word for text, whole for the rest.
///
/// Mirrors `replySteps` in upstream
/// `src/blocks/chat-app/components/chat-app-state.ts`.
List<ChatAppStep> chatAppReplySteps(List<ChatAppPart> script) => [
  for (final part in script)
    ...switch (part) {
      ChatAppText(:final text) => [
        for (final (k, word) in text.split(' ').indexed)
          (
            wait: const Duration(milliseconds: 85),
            apply: (List<ChatAppPart> parts) => switch ((k, parts.lastOrNull)) {
              (> 0, ChatAppText(text: final sofar)) => [
                ...parts.take(parts.length - 1),
                ChatAppText('$sofar $word'),
              ],
              _ => [...parts, ChatAppText(word)],
            },
          ),
      ],
      _ => [
        (
          wait: const Duration(milliseconds: 700),
          apply: (List<ChatAppPart> parts) => [...parts, part],
        ),
      ],
    },
];

const _diff = '''-const shown = notes;
+const shown = picked.size
+  ? notes.filter((n) => n.tags.some((t) => picked.has(t)))
+  : notes;''';

const chatAppConversations = <ChatAppConversation>[
  ChatAppConversation(
    id: 'stubby',
    name: 'Stubby',
    kind: ChatAppKind.assistant,
    subtitle: 'the pencil stub, writing with you',
    time: '9:43',
    turns: [
      ChatAppTurn(
        id: 's0',
        mine: false,
        time: '9:40',
        parts: [ChatAppText('Good morning. What are we making?')],
      ),
      ChatAppTurn(
        id: 's1',
        mine: true,
        time: '9:41',
        parts: [
          ChatAppText(
            'Can you add tags to my notes, and a filter row above the list?',
          ),
        ],
        files: [(name: 'field-notes.pdf', size: '2.4 MB')],
      ),
      ChatAppTurn(
        id: 's2',
        mine: false,
        time: '9:41',
        parts: [
          ChatAppText(
            'I read src/notes/list.tsx first. Tags become a string array on Note, and the chips sit in a row above the list.',
          ),
          ChatAppTool(title: 'ran npm test', result: '12 passed'),
          ChatAppCode(filename: 'src/notes/filter.ts', code: _diff),
          ChatAppText(
            'Try #recipes first: the list narrows to the notes that carry it, and the count at the top stays honest.',
          ),
        ],
      ),
    ],
    reply: [
      ChatAppText(
        'Good catch. The count came from the unfiltered list, so it lied for one render. I moved it below the filter.',
      ),
      ChatAppTool(title: 'ran npm test', result: '14 passed'),
      ChatAppText(
        'Twelve notes, eleven shown, and the number agrees with the page now.',
      ),
    ],
    attachable: [
      (name: 'tags-list.tsx', size: '4 KB'),
      (name: 'recipes.csv', size: '18 KB'),
      (name: 'harbour.jpg', size: '1.8 MB'),
    ],
  ),
  ChatAppConversation(
    id: 'nell',
    name: 'Nell Okafor',
    kind: ChatAppKind.person,
    subtitle: 'letterpress, mostly',
    time: '9:05',
    unread: 2,
    turns: [
      ChatAppTurn(
        id: 'n0',
        mine: false,
        time: '8:52',
        parts: [
          ChatAppText('did you see the proofs? the blue is almost right'),
        ],
      ),
      ChatAppTurn(
        id: 'n1',
        mine: true,
        time: '8:58',
        parts: [ChatAppText('Almost is doing a lot of work in that sentence.')],
      ),
      ChatAppTurn(
        id: 'n2',
        mine: false,
        time: '9:05',
        parts: [
          ChatAppText(
            'it is. bringing the good tape on saturday, and the small guillotine',
          ),
        ],
        files: [(name: 'proofs-saturday.pdf', size: '812 KB')],
      ),
    ],
    reply: [
      ChatAppText(
        "Saturday, ten o'clock. I will save you the stool by the window.",
      ),
    ],
    attachable: [(name: 'blue-swatch.jpg', size: '640 KB')],
  ),
  ChatAppConversation(
    id: 'club',
    name: 'Tuesday club',
    kind: ChatAppKind.group,
    subtitle: 'Nell, Mo, Ines and 2 more',
    time: 'Tue',
    turns: [
      ChatAppTurn(
        id: 'c0',
        mine: false,
        who: 'Mo',
        time: '18:20',
        parts: [
          ChatAppText('The proofs are drying on the line. Come and look.'),
        ],
      ),
      ChatAppTurn(
        id: 'c1',
        mine: false,
        who: 'Ines',
        time: '18:24',
        parts: [ChatAppText('Photo or it did not happen.')],
      ),
      ChatAppTurn(
        id: 'c2',
        mine: true,
        time: '18:31',
        parts: [ChatAppText('On my way, with biscuits.')],
      ),
    ],
    reply: [
      ChatAppText('Biscuits get you the stool by the window. Nell says hello.'),
    ],
    replyFrom: 'Mo',
    attachable: [(name: 'drying-line.jpg', size: '2.1 MB')],
  ),
  ChatAppConversation(
    id: 'jo',
    name: 'Jo Delacroix',
    kind: ChatAppKind.person,
    subtitle: 'paper supplier, very patient',
    time: 'Mon',
    turns: [
      ChatAppTurn(
        id: 'j0',
        mine: false,
        time: '11:02',
        parts: [
          ChatAppText(
            'Sent you the receipt for the paper order. Twelve reams, one damaged corner, no charge.',
          ),
        ],
        files: [(name: 'receipt-0925.pdf', size: '96 KB')],
      ),
      ChatAppTurn(
        id: 'j1',
        mine: true,
        time: '11:10',
        parts: [ChatAppText('Thank you! Paid on my side.')],
      ),
    ],
    reply: [
      ChatAppText(
        'Lovely. I put a sheet of the good stock in the box for you.',
      ),
    ],
    attachable: [(name: 'order-list.csv', size: '3 KB')],
  ),
  ChatAppConversation(
    id: 'mum',
    name: 'Mum',
    kind: ChatAppKind.person,
    subtitle: 'always has the kettle on',
    time: 'Sun',
    unread: 1,
    turns: [
      ChatAppTurn(
        id: 'm0',
        mine: false,
        time: '16:40',
        parts: [
          ChatAppText('Call me when you land? No rush, the kettle is on.'),
        ],
      ),
    ],
    reply: [ChatAppText('Lovely. The kettle is still on.')],
    attachable: [(name: 'boarding-pass.pdf', size: '120 KB')],
  ),
];
