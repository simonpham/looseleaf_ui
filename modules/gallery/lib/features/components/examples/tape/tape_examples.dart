import 'package:gallery/features/components/examples/tape/tape.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/tape/`.
const tapeExamples = <GalleryExample>[
  GalleryExample(
    title: 'Kinds',
    description: 'Crepe masking tape, four printed washi patterns, gummed kraft and nearly invisible cellophane. Every strip has slit lines along its edges and crinkles where it was pressed down.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'tape/tape_kinds_example.dart',
    builder: TapeKindsExample.new,
  ),
  GalleryExample(
    title: 'Holding a card',
    description: 'Tape is placed like any widget: in a Stack, a little outside the sheet, turned. The strip\'s own angle is seeded and never more than a few degrees.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'tape/tape_on_a_card_example.dart',
    builder: TapeOnACardExample.new,
  ),
  GalleryExample(
    title: 'Ends and sizes',
    description: 'Tear it, pink it, cut it straight. Any length and width; the middle stretches, the ends keep their teeth.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'tape/tape_ends_and_sizes_example.dart',
    builder: TapeEndsAndSizesExample.new,
  ),
  GalleryExample(
    title: 'A label on tape',
    description: 'Write on it: put the tape behind a line of text. The strip is decoration, so the label is real text a screen reader reads.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'tape/tape_label_strip_example.dart',
    builder: TapeLabelStripExample.new,
  ),
];
