import 'package:gallery/features/components/examples/peel_corner/peel_corner.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/peel-corner/`.
const peelCornerExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description:
        'Hover the bottom-right corner, drag it, or click. The sheet underneath is out of reach until the corner is open.',
    stage: ExampleStage.desk,
    height: 300,
    source: 'peel_corner/peel_corner_default_example.dart',
    builder: PeelCornerDefaultExample.new,
  ),
  GalleryExample(
    title: 'Left corner, kraft page',
    description:
        'corner: PeelCornerSide.bottomLeft mirrors everything (use it for right-to-left pages); back: PaintKey.kraft makes the flap the same stock as the page.',
    stage: ExampleStage.desk,
    height: 300,
    source: 'peel_corner/peel_corner_left_corner_example.dart',
    builder: PeelCornerLeftCornerExample.new,
  ),
  GalleryExample(
    title: 'Voucher with a copy button',
    description:
        'A real use: the code lives on the sheet underneath, with a working button. It is inert until the corner is open, then a normal control. Controlled, so the page can open it too.',
    stage: ExampleStage.desk,
    height: 340,
    source: 'peel_corner/peel_corner_voucher_example.dart',
    builder: PeelCornerVoucherExample.new,
  ),
];
