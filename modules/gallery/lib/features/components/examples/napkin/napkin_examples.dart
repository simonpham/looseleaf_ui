import 'package:gallery/features/components/examples/napkin/napkin.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/napkin/`.
const napkinExamples = <GalleryExample>[
  GalleryExample(
    title: 'A napkin',
    description:
        'Folded in four, so it has a crease each way. The edge is pinked and the border pressed into the tissue.',
    stage: ExampleStage.desk,
    source: 'napkin/napkin_default_example.dart',
    builder: NapkinDefaultExample.new,
  ),
  GalleryExample(
    title: 'Quarter, half, flat',
    description: 'Folded in four, in half with a coffee ring, and unfolded.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'napkin/napkin_folds_and_stains_example.dart',
    builder: NapkinFoldsAndStainsExample.new,
  ),
  GalleryExample(
    title: 'Ideas on a napkin',
    description:
        'Doodles and stickers go on a napkin as on any paper; here a star and a sticker beside the note.',
    stage: ExampleStage.desk,
    source: 'napkin/napkin_scribbles_example.dart',
    builder: NapkinScribblesExample.new,
  ),
  GalleryExample(
    title: 'A note for the table',
    description:
        'A real use: a guest writes a note on the napkin and pins it to the board. The napkin holds a form; its script font is only for what is written.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    height: 420,
    source: 'napkin/napkin_table_card_example.dart',
    builder: NapkinTableCardExample.new,
  ),
];
