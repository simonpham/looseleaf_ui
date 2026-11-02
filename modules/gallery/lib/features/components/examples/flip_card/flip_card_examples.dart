import 'package:gallery/features/components/examples/flip_card/flip_card.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/flip-card/`.
const flipCardExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description: 'Click it, or Tab to it and press Space. The card lifts off the desk as it turns.',
    stage: ExampleStage.desk,
    height: 260,
    source: 'flip_card/flip_card_default_example.dart',
    builder: FlipCardDefaultExample.new,
  ),
  GalleryExample(
    title: 'Notepad flip',
    description: 'axis: FlipCardAxis.x turns it like a page of a top-bound pad. Any paper works for either face.',
    stage: ExampleStage.desk,
    height: 280,
    source: 'flip_card/flip_card_notepad_example.dart',
    builder: FlipCardNotepadExample.new,
  ),
  GalleryExample(
    title: 'Vocabulary deck',
    description: 'A real use: a controlled flip card as a study deck. Turning is the answer; Next shows the front of the following card.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    height: 340,
    source: 'flip_card/flip_card_vocabulary_deck_example.dart',
    builder: FlipCardVocabularyDeckExample.new,
  ),
  GalleryExample(
    title: 'Buttons on the faces',
    description: 'trigger: false leaves the card free of the overlay, so a face can hold real buttons. The flip button is your own.',
    stage: ExampleStage.desk,
    height: 300,
    source: 'flip_card/flip_card_custom_trigger_example.dart',
    builder: FlipCardCustomTriggerExample.new,
  ),
];
