import 'package:gallery/features/components/examples/native_select/native_select.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/native-select/`.
const nativeSelectExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description:
        "The platform's own kind of select in a hand-drawn frame: a plain list, typeahead, the keyboard. The chevron is drawn; with no value the placeholder shows.",
    layout: ExampleLayout.stack,
    source: 'native_select/native_select_default_example.dart',
    builder: NativeSelectDefaultExample.new,
  ),
  GalleryExample(
    title: 'Groups, sizes and states',
    description:
        'Option groups, a small size, an invalid select (red pencil box and a bang before the chevron) and a disabled one (dashed, pale).',
    layout: ExampleLayout.stack,
    source: 'native_select/native_select_groups_and_states_example.dart',
    builder: NativeSelectGroupsAndStatesExample.new,
  ),
  GalleryExample(
    title: 'Shipping form',
    description:
        'A real-world use: a native select next to inputs in a form. The country is required, so an empty submit is stopped, and the second select follows the first.',
    layout: ExampleLayout.stack,
    source: 'native_select/native_select_shipping_form_example.dart',
    builder: NativeSelectShippingFormExample.new,
  ),
  GalleryExample(
    title: 'Status',
    description:
        "shadcn's `native-select-demo`: a placeholder and four statuses. Its list, keyboard and typeahead are the select's own.",
    source: 'native_select/native_select_demo_example.dart',
    builder: NativeSelectDemoExample.new,
  ),
  GalleryExample(
    title: 'Option groups',
    description:
        "shadcn's `native-select-groups`: a `NativeSelectOptGroup` draws a group heading and indents the options under it.",
    source: 'native_select/native_select_groups_example.dart',
    builder: NativeSelectGroupsExample.new,
  ),
  GalleryExample(
    title: 'Disabled',
    description:
        "shadcn's `native-select-disabled`: `disabled` on the select. The frame is drawn dashed and pale and the chevron fades with it.",
    source: 'native_select/native_select_disabled_example.dart',
    builder: NativeSelectDisabledExample.new,
  ),
  GalleryExample(
    title: 'Invalid',
    description:
        "shadcn's `native-select-invalid`: `invalid` redraws the frame in red pencil with a bang before the chevron.",
    source: 'native_select/native_select_invalid_example.dart',
    builder: NativeSelectInvalidExample.new,
  ),
];
