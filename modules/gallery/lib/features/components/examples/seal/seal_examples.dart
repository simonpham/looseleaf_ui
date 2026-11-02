import 'package:gallery/features/components/examples/seal/seal.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/seal/`.
const sealExamples = <GalleryExample>[
  GalleryExample(
    title: 'Seals',
    description: 'A scalloped seal, a starburst, a rosette with a ribbon hanging from it, a medal, a shield, a plate and a tag: one generator, eight shapes, any stationery color.',
    stage: ExampleStage.desk,
    source: 'seal/seal_default_example.dart',
    builder: SealDefaultExample.new,
  ),
  GalleryExample(
    title: 'Marks, rings and wax',
    description: 'A hand-drawn check or star takes the place of the words (it survives at 16 px where letters do not). A ringed seal carries lettering round its rim. Wax takes an initial, a check or a star.',
    stage: ExampleStage.desk,
    source: 'seal/seal_marks_rings_wax_example.dart',
    builder: SealMarksRingsWaxExample.new,
  ),
  GalleryExample(
    title: 'Verified, awarded, sealed',
    description: 'In ordinary UI: a verified mark beside a name at 20 px, a best-seller seal pinned to a card corner, and a certificate with a rosette, a ringed seal and a wax seal.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'seal/seal_verified_in_the_ui_example.dart',
    builder: SealVerifiedInTheUiExample.new,
  ),
];
