import 'package:gallery/features/components/examples/checkbox/checkbox.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/checkbox/`.
const checkboxExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description:
        'Tick it and watch the felt tick get written. Clicking the label works too.',
    layout: ExampleLayout.stack,
    source: 'checkbox/checkbox_default_example.dart',
    builder: CheckboxDefaultExample.new,
  ),
  GalleryExample(
    title: 'States and sizes',
    description:
        'Off, on, partly on, invalid and disabled in 16, 20 and 28 px. The label of a disabled box fades with it.',
    layout: ExampleLayout.stack,
    source: 'checkbox/checkbox_states_example.dart',
    builder: CheckboxStatesExample.new,
  ),
  GalleryExample(
    title: 'Select all',
    description:
        'A parent box that shows the dash when only some children are ticked, and a Field-like row whose hover lights the box.',
    layout: ExampleLayout.stack,
    source: 'checkbox/checkbox_select_all_example.dart',
    builder: CheckboxSelectAllExample.new,
  ),
  GalleryExample(
    title: 'In a form',
    description:
        'Save reads which boxes are ticked; the small print is required, so Save does nothing until that box is ticked.',
    layout: ExampleLayout.stack,
    source: 'checkbox/checkbox_settings_form_example.dart',
    builder: CheckboxSettingsFormExample.new,
  ),
  GalleryExample(
    title: 'With a description',
    description:
        'A label and a line of help beside the box. Field keeps the box level with the first line of text however long the help runs, and disabled on the Field dims the label and the help together with the disabled box.',
    layout: ExampleLayout.stack,
    source: 'checkbox/checkbox_with_description_example.dart',
    builder: CheckboxWithDescriptionExample.new,
  ),
  GalleryExample(
    title: 'The whole card is the checkbox',
    description:
        'The shadcn demo\'s bordered label. Wrap a Field in a FieldLabel and the pair becomes a hand-drawn card; when the box inside is ticked the card gets a highlighter wash and a felt outline. Click anywhere on it, or Tab to the box and press Space.',
    layout: ExampleLayout.stack,
    source: 'checkbox/checkbox_choice_cards_example.dart',
    builder: CheckboxChoiceCardsExample.new,
  ),
];
