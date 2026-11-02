import 'package:gallery/features/components/examples/form/form.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/form/`.
const formExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description:
        'A FormController with plain Dart validators. Press Save with the fields empty: the labels and boxes turn red pencil and each message is written under its field with a wavy underline. Fix one and its message goes on the next change.',
    layout: ExampleLayout.stack,
    source: 'form/form_default_example.dart',
    builder: FormDefaultExample.new,
  ),
  GalleryExample(
    title: 'Every control',
    description:
        'FormControl ties the label, the focus and the invalid state to whatever it wraps, so a Select, a Radio Group, a Checkbox, a Switch and a Slider go red the same way an Input does. A slider has no single control to label: give it a semanticLabel.',
    layout: ExampleLayout.stack,
    height: 460,
    source: 'form/form_every_control_example.dart',
    builder: FormEveryControlExample.new,
  ),
  GalleryExample(
    title: 'Server errors',
    description:
        'An error does not have to come from a validator: after a pretend request `setError` puts "already taken" on the field, and the same label, box and underline appear. Change the text and it clears itself.',
    layout: ExampleLayout.stack,
    source: 'form/form_server_errors_example.dart',
    builder: FormServerErrorsExample.new,
  ),
  GalleryExample(
    title: 'React Hook Form: bug report',
    description:
        'shadcn\'s `form-rhf-demo`, the Field way to wire a form: `InkFormField` hands the field\'s value and error to a builder, `invalid` on the Field and on the control turn it red, and `FieldError` prints the validator\'s message. Submit it empty, then fill it in.',
    source: 'form/form_rhf_demo_example.dart',
    builder: FormRhfDemoExample.new,
  ),
  GalleryExample(
    title: 'React Hook Form: input',
    description:
        'shadcn\'s `form-rhf-input`: one text field with a length and pattern rule. The error is announced as it appears and written under the field in red pencil.',
    source: 'form/form_rhf_input_example.dart',
    builder: FormRhfInputExample.new,
  ),
  GalleryExample(
    title: 'React Hook Form: select',
    description:
        'shadcn\'s `form-rhf-select`: a Select is not a text field, so `value` and `onChanged` are passed by hand and `invalid` goes on the trigger. "Auto" is a value the validator refuses.',
    height: 420,
    source: 'form/form_rhf_select_example.dart',
    builder: FormRhfSelectExample.new,
  ),
  GalleryExample(
    title: 'React Hook Form: checkbox',
    description:
        'shadcn\'s `form-rhf-checkbox`: a single boolean box (here disabled and ticked) and a group that collects a list. Untick both notification types and submit to see the group\'s own error.',
    source: 'form/form_rhf_checkbox_example.dart',
    builder: FormRhfCheckboxExample.new,
  ),
  GalleryExample(
    title: 'React Hook Form: switch',
    description:
        'shadcn\'s `form-rhf-switch`: a boolean switch that the validator insists on. Submit with it off and the switch turns red pencil with its message in the text column.',
    source: 'form/form_rhf_switch_example.dart',
    builder: FormRhfSwitchExample.new,
  ),
  GalleryExample(
    title: 'React Hook Form: textarea',
    description:
        'shadcn\'s `form-rhf-textarea`: a ruled textarea with a length rule on both ends. Too short and too long each get their own sentence.',
    source: 'form/form_rhf_textarea_example.dart',
    builder: FormRhfTextareaExample.new,
  ),
  GalleryExample(
    title: 'React Hook Form: radio group',
    description:
        'shadcn\'s `form-rhf-radiogroup`: choice cards (a FieldLabel around each Field) in a controlled InkRadioGroup. `invalid` on the group and on each Field paints the whole set red when nothing is chosen.',
    source: 'form/form_rhf_radiogroup_example.dart',
    builder: FormRhfRadiogroupExample.new,
  ),
  GalleryExample(
    title: 'React Hook Form: array',
    description:
        'shadcn\'s `form-rhf-array`: a growing list of emails, each an InputGroup with a remove button inside its box and a field of its own. Add up to five.',
    source: 'form/form_rhf_array_example.dart',
    builder: FormRhfArrayExample.new,
  ),
  GalleryExample(
    title: 'React Hook Form: every control',
    description:
        'shadcn\'s `form-rhf-complex`: a radio card set, a select, a checkbox group and a switch in one form, four kinds of state and four `InkFormField`s. The validators want a billing period and at least one add-on.',
    source: 'form/form_rhf_complex_example.dart',
    builder: FormRhfComplexExample.new,
  ),
  GalleryExample(
    title: 'React Hook Form: password',
    description:
        'shadcn\'s `form-rhf-password`: the field\'s value feeds a strength meter and a live checklist while the validator guards the submit. The bar is a marker pass that changes ink as the password improves; a met rule is a pencilled tick, an open one a cross, and each says so in words for a screen reader.',
    source: 'form/form_rhf_password_example.dart',
    builder: FormRhfPasswordExample.new,
  ),
];
