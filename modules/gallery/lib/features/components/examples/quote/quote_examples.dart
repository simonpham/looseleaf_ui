import 'package:gallery/features/components/examples/quote/quote.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/quote/`.
const quoteExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description: 'A pull quote: marker marks in the gutters, the words in the script font, the source below.',
    source: 'quote/quote_default_example.dart',
    builder: QuoteDefaultExample.new,
  ),
  GalleryExample(
    title: 'Sizes, pens and the rule',
    description: 'Three sizes of marks (the padding grows with them), felt pens instead of marker, and a pencil rule down the edge that runs between the marks of a longer quotation.',
    layout: ExampleLayout.stack,
    source: 'quote/quote_sizes_and_pens_example.dart',
    builder: QuoteSizesAndPensExample.new,
  ),
  GalleryExample(
    title: 'A testimonial card',
    description: 'A quote on a taped index card with the customer\'s signature under it: three hand-made parts that share a pen. The words sit on the card\'s printed rules.',
    stage: ExampleStage.desk,
    source: 'quote/quote_testimonial_example.dart',
    builder: QuoteTestimonialExample.new,
  ),
];
