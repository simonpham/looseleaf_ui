import 'package:gallery/features/components/examples/circled/circled.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/circled/`.
const circledExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description:
        'A loop around a word. It overshoots where it started, like a hand that did not quite stop.',
    layout: ExampleLayout.stack,
    source: 'circled/circled_default_example.dart',
    builder: CircledDefaultExample.new,
  ),
  GalleryExample(
    title: 'Shapes and pens',
    description:
        'A circle, a box and a pair of brackets; ink, blue, red and a brush pen.',
    layout: ExampleLayout.stack,
    source: 'circled/circled_shapes_example.dart',
    builder: CircledShapesExample.new,
  ),
  GalleryExample(
    title: 'The answer key',
    description:
        'Mark the right answer, written on with the pen. The circle is decoration: the answer is also given in words.',
    layout: ExampleLayout.stack,
    height: 240,
    source: 'circled/circled_answer_key_example.dart',
    builder: CircledAnswerKeyExample.new,
  ),
  GalleryExample(
    title: 'A word in a title, and bleed',
    description:
        'The loop hugs one line of writing: a short word in a display title keeps clear of the lines above and below. bleed sets how far it stands off.',
    layout: ExampleLayout.stack,
    source: 'circled/circled_title_and_bleed_example.dart',
    builder: CircledTitleAndBleedExample.new,
  ),
];
