import 'package:gallery/features/components/examples/corkboard/corkboard.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/corkboard/`.
const corkboardExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description:
        'Pick a note up and move it. Or focus one, then use the arrow keys, R to turn it, Enter to bring it to the front.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    height: 380,
    source: 'corkboard/corkboard_default_example.dart',
    builder: CorkboardDefaultExample.new,
  ),
  GalleryExample(
    title: 'Any paper',
    description:
        'A note is a Paper: sticky notes, an index card with a list, a kraft tag, a photo. With bare, any paper object of the library can be the note. Same drag, same keys.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    height: 420,
    source: 'corkboard/corkboard_stocks_example.dart',
    builder: CorkboardStocksExample.new,
  ),
  GalleryExample(
    title: 'Saved layout',
    description:
        'Controlled positions: the board is a plain value, so a layout can be saved, shared and restored. Move things, then reset.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    height: 470,
    source: 'corkboard/corkboard_saved_layout_example.dart',
    builder: CorkboardSavedLayoutExample.new,
  ),
];
