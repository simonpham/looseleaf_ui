import 'package:gallery/features/components/examples/field/field.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/field/`.
const fieldExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description: 'A set of labeled controls: a legend in the script font, fields that stack label, control and help, and the gaps between them. Nothing is drawn but the controls; Field is layout and words.',
    layout: ExampleLayout.stack,
    source: 'field/field_default_example.dart',
    builder: FieldDefaultExample.new,
  ),
  GalleryExample(
    title: 'Orientations',
    description: '`vertical` (label above), `horizontal` (label beside a switch or checkbox, with FieldContent holding the words) and `responsive` (vertical until its FieldGroup is md wide, so it follows the box, not the screen).',
    layout: ExampleLayout.stack,
    source: 'field/field_orientations_example.dart',
    builder: FieldOrientationsExample.new,
  ),
  GalleryExample(
    title: 'Choice cards',
    description: 'A FieldLabel around a whole Field becomes a hand-drawn card; when the radio or checkbox inside it is checked the card gets a highlighter wash and a felt box. Click anywhere on a card.',
    layout: ExampleLayout.stack,
    source: 'field/field_choice_cards_example.dart',
    builder: FieldChoiceCardsExample.new,
  ),
  GalleryExample(
    title: 'Errors and validation',
    description: '`FieldError` takes a child or an `errors` list: one message is text, several are a list, duplicates collapse. It is announced as it appears and wears a wavy red pencil underline; `invalid` on the Field turns the label red, `invalid` on the control draws its box red.',
    layout: ExampleLayout.stack,
    source: 'field/field_errors_example.dart',
    builder: FieldErrorsExample.new,
  ),
];
