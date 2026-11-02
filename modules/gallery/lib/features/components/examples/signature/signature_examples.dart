import 'package:gallery/features/components/examples/signature/signature.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/signature/`.
const signatureExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description: 'A name and its pen tail.',
    source: 'signature/signature_default_example.dart',
    builder: SignatureDefaultExample.new,
  ),
  GalleryExample(
    title: 'Flourishes, sizes and pens',
    description:
        'A swoosh, an underline, none; three sizes; blue, ink and red pens. A signature keeps its own size in a row or a grid, so names of different sizes sit on one line.',
    layout: ExampleLayout.stack,
    source: 'signature/signature_flourishes_and_sizes_example.dart',
    builder: SignatureFlourishesAndSizesExample.new,
  ),
  GalleryExample(
    title: 'The end of a letter',
    description:
        'Sign it: the name is written left to right, then the flourish follows the pen.',
    stage: ExampleStage.desk,
    height: 360,
    source: 'signature/signature_letter_example.dart',
    builder: SignatureLetterExample.new,
  ),
];
