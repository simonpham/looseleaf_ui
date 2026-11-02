import 'package:gallery/features/components/examples/asterisk/asterisk.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/asterisk/`.
const asteriskExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description:
        'A red-pencil asterisk after a word, raised like a superscript.',
    source: 'asterisk/asterisk_default_example.dart',
    builder: AsteriskDefaultExample.new,
  ),
  GalleryExample(
    title: 'Marks and pens',
    description:
        'Asterisk, star, dagger and double dagger; red, ink, blue and pencil. Text inside comes first and the mark follows it.',
    layout: ExampleLayout.stack,
    source: 'asterisk/asterisk_marks_and_pens_example.dart',
    builder: AsteriskMarksAndPensExample.new,
  ),
  GalleryExample(
    title: 'A price with a footnote',
    description:
        'The mark is a link (with a name) to the footnote at the foot of the card, sized to the 36 px price it follows.',
    stage: ExampleStage.desk,
    source: 'asterisk/asterisk_price_footnote_example.dart',
    builder: AsteriskPriceFootnoteExample.new,
  ),
];
