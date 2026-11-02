import 'package:gallery/features/components/examples/typewriter/typewriter.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/typewriter/`.
const typewriterExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description:
        'It types at an uneven pace, holding at the comma and the period.',
    layout: ExampleLayout.stack,
    height: 160,
    source: 'typewriter/typewriter_default_example.dart',
    builder: TypewriterDefaultExample.new,
  ),
  GalleryExample(
    title: 'A rotating word',
    description:
        'TypingMode.cycle types a word, holds it, backspaces it and moves on; loop keeps it going. A block caret, and the sentence still reads once to a screen reader.',
    height: 160,
    source: 'typewriter/typewriter_rotating_word_example.dart',
    builder: TypewriterRotatingWordExample.new,
  ),
  GalleryExample(
    title: 'Printing a receipt',
    description:
        'A real use: an order confirmation types itself onto a receipt, and onDone brings in the button. `reserve` holds the height of the finished receipt, so the paper does not grow (or move, in a centered stage) as it prints. Print another remounts it with a new key.',
    stage: ExampleStage.desk,
    height: 420,
    source: 'typewriter/typewriter_receipt_example.dart',
    builder: TypewriterReceiptExample.new,
  ),
];
