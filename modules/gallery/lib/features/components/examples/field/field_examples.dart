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
  GalleryExample(
    title: 'Checkout form',
    description: 'shadcn\'s `field-demo`, the big one: two FieldSets with legends, a three-column row of Month, Year and CVV, a checkbox row, a comment box and a pair of buttons, all separated by a FieldSeparator.',
    source: 'field/field_payment_form_example.dart',
    builder: FieldPaymentFormExample.new,
  ),
  GalleryExample(
    title: 'Input',
    description: 'shadcn\'s `field-input`: a description can sit under the control (Username) or between the label and the control (Password); the order in the children is the order on the page.',
    source: 'field/field_input_example.dart',
    builder: FieldInputExample.new,
  ),
  GalleryExample(
    title: 'Textarea',
    description: 'shadcn\'s `field-textarea`: a labeled ruled box with a hint underneath.',
    source: 'field/field_textarea_example.dart',
    builder: FieldTextareaExample.new,
  ),
  GalleryExample(
    title: 'Fieldset',
    description: 'shadcn\'s `field-fieldset`: a FieldSet with a legend and a line of help, a full-width field and a two-column row of City and Postal Code.',
    source: 'field/field_fieldset_example.dart',
    builder: FieldFieldsetExample.new,
  ),
  GalleryExample(
    title: 'Radio',
    description: 'shadcn\'s `field-radio`: a InkRadioGroup inside a FieldSet, each option a horizontal Field with the button first and its label after it.',
    source: 'field/field_radio_example.dart',
    builder: FieldRadioExample.new,
  ),
  GalleryExample(
    title: 'Checkbox',
    description: 'shadcn\'s `field-checkbox`: a legend styled as a label over a tight group of boxes, then, below a separator, one box whose label and description share a FieldContent column.',
    source: 'field/field_checkbox_example.dart',
    builder: FieldCheckboxExample.new,
  ),
  GalleryExample(
    title: 'Switch',
    description: 'shadcn\'s `field-switch`: label and description in a FieldContent column, the switch at the far end of a horizontal Field. Click the words or the switch.',
    source: 'field/field_switch_example.dart',
    builder: FieldSwitchExample.new,
  ),
  GalleryExample(
    title: 'Slider',
    description: 'shadcn\'s `field-slider`: a range slider has no single control to label, so FieldTitle names it (and `semanticLabel` goes on the slider). The description reads the two values out.',
    source: 'field/field_slider_example.dart',
    builder: FieldSliderExample.new,
  ),
  GalleryExample(
    title: 'Select',
    description: 'shadcn\'s `field-select`: a Select under a label with a hint. The label opens the list, so a click on the word works like a click on the trigger.',
    height: 360,
    source: 'field/field_select_example.dart',
    builder: FieldSelectExample.new,
  ),
  GalleryExample(
    title: 'Choice card',
    description: 'shadcn\'s `field-choice-card`: a FieldLabel wrapped around a whole Field makes the row one big target. Here each card is a small hand-drawn slip, and the checked one gets the highlighter wash.',
    source: 'field/field_choice_card_example.dart',
    builder: FieldChoiceCardExample.new,
  ),
  GalleryExample(
    title: 'Field group',
    description: 'shadcn\'s `field-group`: FieldGroups stack fields and FieldSets. The first box is checked and disabled, the second set has a link in its help line.',
    source: 'field/field_group_example.dart',
    builder: FieldGroupExample.new,
  ),
  GalleryExample(
    title: 'Responsive layout',
    description: 'shadcn\'s `field-responsive`: `FieldOrientation.responsive` stacks label above control on a narrow container and puts them side by side once the FieldGroup is wide enough. It answers to the container, not the window, so resize the preview.',
    source: 'field/field_responsive_example.dart',
    builder: FieldResponsiveExample.new,
  ),
];
