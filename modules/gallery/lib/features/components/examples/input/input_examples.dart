import 'package:gallery/features/components/examples/input/input.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/input/`.
const inputExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description: 'A label and a field. What you type is blue felt; the placeholder is graphite.',
    layout: ExampleLayout.stack,
    source: 'input/input_default_example.dart',
    builder: InputDefaultExample.new,
  ),
  GalleryExample(
    title: 'States',
    description: 'Filled, invalid (red pencil, a wavy underline and a !), disabled (dashed pencil) and read-only (printed). Hover and Tab into them to see the rest.',
    layout: ExampleLayout.stack,
    source: 'input/input_states_example.dart',
    builder: InputStatesExample.new,
  ),
  GalleryExample(
    title: 'Types',
    description: 'Password, number and date. obscureText hides the password, keyboardType and inputFormatters keep the quantity to digits.',
    layout: ExampleLayout.stack,
    source: 'input/input_types_example.dart',
    builder: InputTypesExample.new,
  ),
  GalleryExample(
    title: 'With an icon',
    description: 'The pencilled magnifier sits in an InputGroup addon, so the text starts after it.',
    layout: ExampleLayout.stack,
    source: 'input/input_search_with_icon_example.dart',
    builder: InputSearchWithIconExample.new,
  ),
  GalleryExample(
    title: 'A sign-up form',
    description: 'Real validation: the email field turns red with its message the moment it is wrong, and the form only submits when it is right.',
    layout: ExampleLayout.stack,
    source: 'input/input_signup_form_example.dart',
    builder: InputSignupFormExample.new,
  ),
  GalleryExample(
    title: 'Email field',
    description: 'shadcn\'s input-demo: the bare Input, nothing around it. An email keyboard and a placeholder are all it takes; what you type comes out in blue felt.',
    source: 'input/input_demo_example.dart',
    builder: InputDemoExample.new,
  ),
  GalleryExample(
    title: 'Disabled',
    description: 'shadcn\'s input-disabled: disabled draws the box in dashed pencil and takes the field out of the tab order.',
    source: 'input/input_disabled_example.dart',
    builder: InputDisabledExample.new,
  ),
  GalleryExample(
    title: 'With button',
    description: 'shadcn\'s input-with-button: an Input and an outline Button side by side in a flex row. Two separate drawings that line up, not one shared box (InputGroup does that).',
    source: 'input/input_with_button_example.dart',
    builder: InputWithButtonExample.new,
  ),
  GalleryExample(
    title: 'With label',
    description: 'shadcn\'s input-with-label: a Label above the field, tied to it by a shared focusNode, so a click on the word puts the cursor in the box.',
    source: 'input/input_with_label_example.dart',
    builder: InputWithLabelExample.new,
  ),
  GalleryExample(
    title: 'With help text',
    description: 'shadcn\'s input-with-text: a line of muted help under the field.',
    source: 'input/input_with_text_example.dart',
    builder: InputWithTextExample.new,
  ),
];
