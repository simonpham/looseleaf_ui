import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _notes = [
  (color: StickyColor.yellow, title: 'todo', body: 'buy more ink'),
  (color: StickyColor.green, title: 'done', body: 'book the venue'),
  (color: StickyColor.orange, title: 'careful', body: 'the glue is wet'),
  (color: StickyColor.pink, title: 'urgent', body: 'call mum'),
  (color: StickyColor.blue, title: 'tip', body: 'tape it down first'),
];

class StickyNotePadsExample extends StatelessWidget {
  const StickyNotePadsExample({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Spacing.d16),
    child: Wrap(
      alignment: WrapAlignment.center,
      spacing: Spacing.d32,
      runSpacing: Spacing.d32,
      children: [
        for (final note in _notes)
          StickyNote(
            color: note.color,
            seed: note.title,
            children: [
              StickyNoteTitle(Text(note.title)),
              StickyNoteContent(Text(note.body)),
            ],
          ),
      ],
    ),
  );
}
