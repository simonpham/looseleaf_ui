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
];
