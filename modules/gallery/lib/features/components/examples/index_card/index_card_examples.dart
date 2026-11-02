import 'package:gallery/features/components/examples/index_card/index_card.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/index-card/`.
const indexCardExamples = <GalleryExample>[
  GalleryExample(
    title: 'An index card',
    description: 'A red header rule, blue lines every 30 px, and text that sits on them. The title goes above the red line; the footer at the foot.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'index_card/index_card_default_example.dart',
    builder: IndexCardDefaultExample.new,
  ),
  GalleryExample(
    title: 'Rod hole, flag, pile',
    description: 'The details of a card that lived in a card box: a hole punched for the rod, a flag stuck over the edge, more cards behind it.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'index_card/index_card_hole_flag_stack_example.dart',
    builder: IndexCardHoleFlagStackExample.new,
  ),
  GalleryExample(
    title: 'Taped, clipped, stacked',
    description: "Paper's tape and fasteners work on a card as on any sheet. Cards turn under a quarter of a degree, so the printed lines stay level under the text.",
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'index_card/index_card_taped_and_clipped_example.dart',
    builder: IndexCardTapedAndClippedExample.new,
  ),
  GalleryExample(
    title: 'Flashcards',
    description: 'A real use: a pile of flashcards. Press a button to flip the top card between the question and the answer; the pile behind it shows how many are left.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'index_card/index_card_flashcards_example.dart',
    builder: IndexCardFlashcardsExample.new,
  ),
];
