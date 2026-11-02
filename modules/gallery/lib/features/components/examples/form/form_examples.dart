import 'package:gallery/features/components/examples/form/form.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/form/`.
const formExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description: 'A FormController with plain Dart validators. Press Save with the fields empty: the labels and boxes turn red pencil and each message is written under its field with a wavy underline. Fix one and its message goes on the next change.',
    layout: ExampleLayout.stack,
    source: 'form/form_default_example.dart',
    builder: FormDefaultExample.new,
  ),
  GalleryExample(
    title: 'Every control',
    description: 'FormControl ties the label, the focus and the invalid state to whatever it wraps, so a Select, a Radio Group, a Checkbox, a Switch and a Slider go red the same way an Input does. A slider has no single control to label: give it a semanticLabel.',
    layout: ExampleLayout.stack,
    height: 460,
    source: 'form/form_every_control_example.dart',
    builder: FormEveryControlExample.new,
  ),
  GalleryExample(
    title: 'Server errors',
    description: 'An error does not have to come from a validator: after a pretend request `setError` puts "already taken" on the field, and the same label, box and underline appear. Change the text and it clears itself.',
    layout: ExampleLayout.stack,
    source: 'form/form_server_errors_example.dart',
    builder: FormServerErrorsExample.new,
  ),
  GalleryExample(
    title: 'React Hook Form: bug report',
    description: 'shadcn\'s `form-rhf-demo`, the Field way to wire a form: `InkFormField` hands the field\'s value and error to a builder, `invalid` on the Field and on the control turn it red, and `FieldError` prints the validator\'s message. Submit it empty, then fill it in.',
    source: 'form/form_rhf_demo_example.dart',
    builder: FormRhfDemoExample.new,
  ),
  GalleryExample(
    title: 'React Hook Form: input',
    description: 'shadcn\'s `form-rhf-input`: one text field with a length and pattern rule. The error is announced as it appears and written under the field in red pencil.',
    source: 'form/form_rhf_input_example.dart',
    builder: FormRhfInputExample.new,
  ),
  GalleryExample(
    title: 'React Hook Form: select',
    description: 'shadcn\'s `form-rhf-select`: a Select is not a text field, so `value` and `onChanged` are passed by hand and `invalid` goes on the trigger. "Auto" is a value the validator refuses.',
    height: 420,
    source: 'form/form_rhf_select_example.dart',
    builder: FormRhfSelectExample.new,
  ),
  GalleryExample(
    title: 'React Hook Form: checkbox',
    description: 'shadcn\'s `form-rhf-checkbox`: a single boolean box (here disabled and ticked) and a group that collects a list. Untick both notification types and submit to see the group\'s own error.',
    source: 'form/form_rhf_checkbox_example.dart',
    builder: FormRhfCheckboxExample.new,
  ),
  GalleryExample(
    title: 'React Hook Form: switch',
    description: 'shadcn\'s `form-rhf-switch`: a boolean switch that the validator insists on. Submit with it off and the switch turns red pencil with its message in the text column.',
    source: 'form/form_rhf_switch_example.dart',
    builder: FormRhfSwitchExample.new,
  ),
];
