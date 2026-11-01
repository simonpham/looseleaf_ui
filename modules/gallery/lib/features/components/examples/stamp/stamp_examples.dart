import 'package:gallery/features/components/examples/stamp/stamp.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/stamp/`.
const stampExamples = <GalleryExample>[
  GalleryExample(
    title: 'Presets',
    description: 'Ink pressed through a worn pad: about 86 percent of it survives, patches are missed, the border wobbles and the whole stamp tilts a few degrees.',
    source: 'stamp/stamp_presets_example.dart',
    builder: StampPresetsExample.new,
  ),
  GalleryExample(
    title: 'Shapes and inks',
    description: 'A box, a ring with rim text, a twelve-point seal, and big diagonal letters. Pad inks are red, blue felt, green or ink, never a stationery accent.',
    source: 'stamp/stamp_shapes_example.dart',
    builder: StampShapesExample.new,
  ),
  GalleryExample(
    title: 'On a document',
    description: 'Stamps go on top of real content and never block it: the drawing ignores the pointer and keeps its own name for screen readers.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'stamp/stamp_on_a_document_example.dart',
    builder: StampOnADocumentExample.new,
  ),
];
