import 'package:gallery/features/components/examples/receipt/receipt.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/receipt/`.
const receiptExamples = <GalleryExample>[
  GalleryExample(
    title: 'A receipt',
    description:
        'Pinked at both ends, typed, the lines a description list. The total is bigger; nothing else is.',
    stage: ExampleStage.desk,
    source: 'receipt/receipt_default_example.dart',
    builder: ReceiptDefaultExample.new,
  ),
  GalleryExample(
    title: 'Circled, barcoded, clipped',
    description:
        'The total circled in red felt tip, a barcode whose bars come from the number under it, and a paper clip to keep it with the invoice.',
    stage: ExampleStage.desk,
    source: 'receipt/receipt_circled_and_barcoded_example.dart',
    builder: ReceiptCircledAndBarcodedExample.new,
  ),
  GalleryExample(
    title: 'Four ways to cut it',
    description:
        '`ends` is the cut of both ends: the tear bar\'s sawtooth, a perforation, a hand tear, or a plain guillotine.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'receipt/receipt_ends_example.dart',
    builder: ReceiptEndsExample.new,
  ),
  GalleryExample(
    title: 'An order summary',
    description:
        'A real checkout: quantities you can change, a total that follows, and the barcode of the order number. The receipt is ordinary widgets; only the ink is drawn.',
    stage: ExampleStage.desk,
    source: 'receipt/receipt_order_summary_example.dart',
    builder: ReceiptOrderSummaryExample.new,
  ),
];
