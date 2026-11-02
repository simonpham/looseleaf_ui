import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A notebook on the shelf.
typedef NotesAppNotebook = ({String id, String name});

/// A page of notes. The body marks words with `==highlight==`,
/// `__underline__`, `((circle))` and `~~cross out~~`.
///
/// Mirrors `Note` in upstream `src/blocks/notes-app/components/notes-app-data.ts`.
class NotesAppNote {
  const NotesAppNote({
    required this.id,
    required this.notebook,
    required this.title,
    required this.body,
    required this.updated,
    required this.reads,
  });

  final String id;
  final String notebook;
  final String title;
  final String body;
  final String updated;
  final int reads;

  NotesAppNote copyWith({String? title, String? body, int? reads}) =>
      NotesAppNote(
        id: id,
        notebook: notebook,
        title: title ?? this.title,
        body: body ?? this.body,
        updated: 'just now',
        reads: reads ?? this.reads,
      );
}

/// A mark a word can carry: how it is written in the body and how it is
/// drawn.
enum NotesAppMark {
  highlight(
    '==',
    '==',
    'Highlight',
    AnnotateType.highlight,
    AnnotateColor.yellow,
  ),
  underline(
    '__',
    '__',
    'Underline',
    AnnotateType.underline,
    AnnotateColor.blue,
    UnderlineMarkKind.wavy,
  ),
  circle('((', '))', 'Circle', AnnotateType.circle, AnnotateColor.red),
  strike(
    '~~',
    '~~',
    'Cross out',
    AnnotateType.strikeThrough,
    AnnotateColor.red,
  );

  const NotesAppMark(
    this.open,
    this.close,
    this.label,
    this.type,
    this.color, [
    this.kind,
  ]);

  final String open;
  final String close;
  final String label;
  final AnnotateType type;
  final AnnotateColor color;
  final UnderlineMarkKind? kind;
}

/// A run of a line: plain, or carrying a [mark].
typedef NotesAppPiece = ({String text, NotesAppMark? mark});

const notesAppAll = 'all';

const notesAppFeatured = 'owning-books';

const notesAppNotebooks = <NotesAppNotebook>[
  (id: notesAppAll, name: 'Everything'),
  (id: 'recipes', name: 'Recipes'),
  (id: 'garden', name: 'Garden'),
  (id: 'reading', name: 'Reading'),
  (id: 'trips', name: 'Trips'),
  (id: 'scraps', name: 'Scraps'),
];

/// The name of the notebook [id].
String notesAppNotebookName(String id) =>
    notesAppNotebooks.where((each) => each.id == id).firstOrNull?.name ?? id;

/// The notes in notebook [id] (all of them for [notesAppAll]).
List<NotesAppNote> notesAppInNotebook(List<NotesAppNote> notes, String id) => [
  for (final note in notes)
    if (id == notesAppAll || note.notebook == id) note,
];

final _markPattern = RegExp(r'==(.+?)==|__(.+?)__|\(\((.+?)\)\)|~~(.+?)~~');

/// Splits a line into plain and marked runs.
List<NotesAppPiece> notesAppParseLine(String line) {
  final out = <NotesAppPiece>[];
  var at = 0;
  for (final match in _markPattern.allMatches(line)) {
    if (match.start > at) {
      out.add((text: line.substring(at, match.start), mark: null));
    }
    for (final mark in NotesAppMark.values) {
      if (match.group(mark.index + 1) case final text?) {
        out.add((text: text, mark: mark));
      }
    }
    at = match.end;
  }
  if (at < line.length) out.add((text: line.substring(at), mark: null));
  return out;
}

/// The body without its marks.
String notesAppStripMarks(String body) => [
  for (final line in body.split('\n'))
    notesAppParseLine(line).map((piece) => piece.text).join(),
].join('\n');

/// How many words the body has, marks aside.
int notesAppWordCount(String body) => notesAppStripMarks(
  body,
).split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;

/// Puts [mark] around the selection [start]..[end] of [text] (line by
/// line), or takes it off when it is already there. Null when there is
/// nothing to mark.
///
/// Mirrors `toggleMark` in upstream
/// `src/blocks/notes-app/components/notes-app-data.ts`.
({String text, int start, int end})? notesAppToggleMark(
  String text,
  int start,
  int end,
  NotesAppMark mark,
) {
  final open = mark.open;
  final close = mark.close;
  if (end <= start) return null;
  final selected = text.substring(start, end);
  final before = text.substring((start - open.length).clamp(0, start), start);
  final after = text.substring(
    end,
    (end + close.length).clamp(end, text.length),
  );
  if (before == open && after == close) {
    return (
      text:
          text.substring(0, start - open.length) +
          selected +
          text.substring(end + close.length),
      start: start - open.length,
      end: end - open.length,
    );
  }
  if (selected.length > open.length + close.length &&
      selected.startsWith(open) &&
      selected.endsWith(close)) {
    final inner = selected.substring(
      open.length,
      selected.length - close.length,
    );
    return (
      text: text.substring(0, start) + inner + text.substring(end),
      start: start,
      end: start + inner.length,
    );
  }
  final parts = <({int from, int to})>[];
  var cursor = start;
  for (final line in selected.split('\n')) {
    final lead = line.length - line.trimLeft().length;
    final words = line.trim();
    if (words.isNotEmpty) {
      parts.add((from: cursor + lead, to: cursor + lead + words.length));
    }
    cursor += line.length + 1;
  }
  if (parts.isEmpty) return null;
  var next = text;
  for (final part in parts.reversed) {
    next =
        next.substring(0, part.from) +
        open +
        next.substring(part.from, part.to) +
        close +
        next.substring(part.to);
  }
  final added = parts.length * (open.length + close.length);
  return (
    text: next,
    start: parts.first.from + open.length,
    end: parts.last.to + added - close.length,
  );
}

const notesAppNotes = <NotesAppNote>[
  NotesAppNote(
    id: 'owning-books',
    notebook: 'reading',
    title: 'On owning books',
    body: '''Most of what I remember from a book is in the ((margins)): an arrow, a question mark, a small argument with a dead author.

The good bits get ==a swipe of yellow== so I can find them on the next read, and the parts I do not believe get __a red pencil__.

By the third reading the book is more mine than the ~~writer's~~, which is the whole point of owning one.''',
    updated: '10 minutes ago',
    reads: 7,
  ),
  NotesAppNote(
    id: 'porridge',
    notebook: 'recipes',
    title: 'Porridge, the slow way',
    body: '''Oats, water, a pinch of salt. Nothing else until the end.

Bring the water to a ==small boil==, then turn it down until it just shivers. Stir with the wooden spoon, ((always the same direction)). My gran was firm about it.

Twelve minutes. Honey, a splash of cold milk, and __eat it standing at the window__.''',
    updated: '2 hours ago',
    reads: 7,
  ),
  NotesAppNote(
    id: 'soup',
    notebook: 'recipes',
    title: 'Soup that forgives',
    body: '''Any sad vegetables, one onion, plenty of butter.

Cook the onion until it gives up, ==then add everything else==. Water to cover. Salt, a bay leaf, patience.

~~Cream~~ Not needed. A spoon of yoghurt and black pepper on top.''',
    updated: 'Yesterday',
    reads: 3,
  ),
  NotesAppNote(
    id: 'toast',
    notebook: 'recipes',
    title: 'Toast, honestly',
    body: '''Good bread, ((thick)) slices, a toaster you trust.

Butter goes on while it is __still too hot to hold__. Jam only if you mean it.''',
    updated: 'Last week',
    reads: 12,
  ),
  NotesAppNote(
    id: 'beds',
    notebook: 'garden',
    title: 'What went in this week',
    body: '''Sunday: sweet peas along the fence, ==nine of them==, in the wet corner.
Monday: rain. Nothing.
Wednesday: the first radishes are up. ((Already.))

Still to do: move the rosemary before it sulks.''',
    updated: 'Tuesday',
    reads: 4,
  ),
  NotesAppNote(
    id: 'slugs',
    notebook: 'garden',
    title: 'Slugs: a truce',
    body:
        '''They get the outer lettuce. I get the inner ones. __Everyone eats.__

~~Beer traps~~ Did not work, and smelled.''',
    updated: 'Last month',
    reads: 2,
  ),
  NotesAppNote(
    id: 'lisbon',
    notebook: 'trips',
    title: 'Lisbon, three days',
    body: '''Day one: tram 28 before the crowds, then ==pastel de nata==. Two, not one.
Day two: walk uphill on purpose. ((Bring the good shoes.))
Day three: a bookshop with a cat, and __no plan at all__.

Ask Jo about the tiles.''',
    updated: '3 days ago',
    reads: 5,
  ),
  NotesAppNote(
    id: 'scrap-1',
    notebook: 'scraps',
    title: 'Things to ask the printer',
    body: '''Is the blue ==actually== that blue?
Deckle edge: extra, or included?
Proofs by Thursday, ((please)).''',
    updated: 'Monday',
    reads: 1,
  ),
];
