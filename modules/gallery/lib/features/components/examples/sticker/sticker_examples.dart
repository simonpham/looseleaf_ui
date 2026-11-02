import 'package:gallery/features/components/examples/sticker/sticker.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/sticker/`.
const stickerExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description:
        'Die-cut vinyl: a white border, a cut line, a soft shadow and a small seeded tilt. Badges like Done and Sale are generated; the rest are drawn.',
    source: 'sticker/sticker_default_example.dart',
    builder: StickerDefaultExample.new,
  ),
  GalleryExample(
    title: 'Peeled corner',
    description:
        '`peel` folds the lower-right corner over along a line perpendicular to the diagonal, whatever the silhouette. Peel(n) folds n px.',
    source: 'sticker/sticker_peel_example.dart',
    builder: StickerPeelExample.new,
  ),
  GalleryExample(
    title: 'Slapped on a card',
    description:
        'A sticker on an index card. Size it small and it switches to its 64 px redraw.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'sticker/sticker_on_a_card_example.dart',
    builder: StickerOnACardExample.new,
  ),
  GalleryExample(
    title: 'Every sticker drawn so far',
    description:
        'One shelf per batch, and it grows by itself as new batches land. Only the open shelf is on the page, so a gallery of nearly ninety stickers stays light.',
    layout: ExampleLayout.stack,
    source: 'sticker/sticker_gallery_example.dart',
    builder: StickerGalleryExample.new,
  ),
];
