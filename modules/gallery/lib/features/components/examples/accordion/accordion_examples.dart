import 'package:gallery/features/components/examples/accordion/accordion.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/accordion/`.
const accordionExamples = <GalleryExample>[
  GalleryExample(
    title: 'Questions',
    description: 'Ruled rows on a page. Opening one turns the chevron over, draws a margin brace beside the text (written top to bottom in blue pencil) and lets the words soak in. A single, collapsible accordion opens one at a time and lets you close it again.',
    height: 320,
    source: 'accordion/accordion_faq_example.dart',
    builder: AccordionFaqExample.new,
  ),
  GalleryExample(
    title: 'Several open, square bracket',
    description: 'AccordionType.multiple keeps every row you open. BracketKind.square swaps the brace for a square bracket, and a null bracket leaves the margin empty. Buttons inside a panel keep their focus rings: an open panel is not clipped.',
    height: 420,
    source: 'accordion/accordion_multiple_example.dart',
    builder: AccordionMultipleExample.new,
  ),
  GalleryExample(
    title: 'Account settings',
    description: 'A controlled accordion in a card: the open row lives in state, a button opens the next one, and the fields inside keep their rings and hover lines.',
    height: 520,
    source: 'accordion/accordion_settings_example.dart',
    builder: AccordionSettingsExample.new,
  ),
  GalleryExample(
    title: 'Product details (long panels)',
    description: 'The shadcn demo: one row open at a time, the first open on arrival, and panels that hold more than one paragraph. Give AccordionContent a column with spacing and the paragraphs space themselves.',
    height: 460,
    source: 'accordion/accordion_product_details_example.dart',
    builder: AccordionProductDetailsExample.new,
  ),
];
