import 'package:gallery/features/components/examples/sticky_note/sticky_note.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/sticky-note/`.
const stickyNoteExamples = <GalleryExample>[
  GalleryExample(
    title: 'Five pads',
    description: 'Yellow, green, orange, pink and blue, each turned by its own seeded angle. The first word says what the note is.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'sticky_note/sticky_note_pads_example.dart',
    builder: StickyNotePadsExample.new,
  ),
  GalleryExample(
    title: 'Curled, pinned, taped',
    description: '`curl` lifts the bottom-right corner; `fastener` and `tape` hold a note up. Any size works: the text wraps and the sheet follows.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'sticky_note/sticky_note_held_up_example.dart',
    builder: StickyNoteHeldUpExample.new,
  ),
  GalleryExample(
    title: 'Done',
    description: 'Pass `done` and the note gets a pencil tick box. Add `onDoneChange` and the box can be pressed: the tick is written with a felt pen and the text struck through. A note that loads done just shows it.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'sticky_note/sticky_note_done_example.dart',
    builder: StickyNoteDoneExample.new,
  ),
  GalleryExample(
    title: 'A team board',
    description: 'A real board: notes you tick off as the week goes, laid on a card. Each note is a labeled group with its own checkbox; the tick is written when you press it.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'sticky_note/sticky_note_board_example.dart',
    builder: StickyNoteBoardExample.new,
  ),
];
