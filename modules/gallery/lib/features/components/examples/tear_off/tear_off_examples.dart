import 'package:gallery/features/components/examples/tear_off/tear_off.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/tear-off/`.
const tearOffExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description:
        'Pull the stub away, tap it, or focus it and press Enter. The scissors have already started.',
    stage: ExampleStage.desk,
    height: 250,
    source: 'tear_off/tear_off_default_example.dart',
    builder: TearOffDefaultExample.new,
  ),
  GalleryExample(
    title: 'Stub below',
    description:
        'orientation: Axis.vertical hangs the stub under the ticket, like the free coffee on a punch card. Kraft stock, and it is pulled down.',
    stage: ExampleStage.desk,
    height: 330,
    source: 'tear_off/tear_off_vertical_example.dart',
    builder: TearOffVerticalExample.new,
  ),
  GalleryExample(
    title: 'Coupon book',
    description:
        'A real use: onTear redeems the coupon, and a controlled torn state lets the book be reset. The confetti stays inside the ticket.',
    stage: ExampleStage.desk,
    height: 330,
    source: 'tear_off/tear_off_coupon_book_example.dart',
    builder: TearOffCouponBookExample.new,
  ),
];
