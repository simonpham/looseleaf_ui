import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-3xl`.
const _maxWidth = 768.0;

const _start = [
  (
    id: 'a',
    color: StickyColor.yellow,
    title: 'design',
    body: 'finish the hero art',
    who: 'Ada',
    done: true,
  ),
  (
    id: 'b',
    color: StickyColor.green,
    title: 'docs',
    body: 'write the install page',
    who: 'Lin',
    done: false,
  ),
  (
    id: 'c',
    color: StickyColor.pink,
    title: 'ship',
    body: 'tag the release',
    who: 'Sam',
    done: false,
  ),
  (
    id: 'd',
    color: StickyColor.blue,
    title: 'later',
    body: 'ask about dark mode',
    who: 'Ada',
    done: false,
  ),
];

class StickyNoteBoardExample extends StatefulWidget {
  const StickyNoteBoardExample({super.key});

  @override
  State<StickyNoteBoardExample> createState() => _StickyNoteBoardExampleState();
}

class _StickyNoteBoardExampleState extends State<StickyNoteBoardExample> {
  late final Map<String, bool> _done = {
    for (final note in _start) note.id: note.done,
  };

  Widget _note(int index) {
    final note = _start[index];
    return Center(
      child: Semantics(
        container: true,
        label: '${note.title}: ${note.body}',
        child: StickyNote(
          color: note.color,
          done: _done[note.id],
          onDoneChange: (done) => setState(() => _done[note.id] = done),
          doneLabel: '${note.title}: done',
          seed: note.id,
          width: Spacing.d160,
          children: [
            StickyNoteTitle(Text(note.title)),
            StickyNoteContent(Text(note.body)),
            StickyNoteFooter(Text(note.who)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Card(
        stock: StockName.kraft,
        seed: 'board',
        gap: Spacing.d16,
        children: [
          const CardHeader(children: [CardTitle(Text('This week'))]),
          CardContent(
            child: Column(
              spacing: Spacing.d24,
              children: [
                for (var row = 0; row < _start.length; row += 2)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Spacing.d24,
                    children: [
                      Expanded(child: _note(row)),
                      Expanded(child: _note(row + 1)),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
