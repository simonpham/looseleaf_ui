import 'package:gallery/features/components/examples/stamp_button/stamp_button.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/stamp-button/`.
const stampButtonExamples = <GalleryExample>[
  GalleryExample(
    title: 'Stamp the page',
    description:
        'Press the stamp and an impression lands on the document with a thump; the page gives a little. Press it again and a fresh strike replaces the last (Approve twice is still one APPROVED).',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'stamp_button/stamp_button_default_example.dart',
    builder: StampButtonDefaultExample.new,
  ),
  GalleryExample(
    title: 'Inks and shapes',
    description:
        'The tool takes the color of the pad it will leave: green, red, blue felt, black. Any preset from the sticker sheet works, or give the words and the shape yourself.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    height: 540,
    source: 'stamp_button/stamp_button_inks_and_shapes_example.dart',
    builder: StampButtonInksAndShapesExample.new,
  ),
  GalleryExample(
    title: 'An approval',
    description:
        'A real review step: the stamps are the state. Approving or rejecting leaves its impression on the expense report (a second decision replaces the first), the status badge follows it, and Reset clears the page.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'stamp_button/stamp_button_review_example.dart',
    builder: StampButtonReviewExample.new,
  ),
];
