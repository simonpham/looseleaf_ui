import 'package:gallery/features/components/examples/select/select.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/select/`.
const selectExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description: 'Press it, slide down the list, and the row under the pointer gets the highlighter. Type a letter to jump; the chosen row is bold with a blue tick.',
    height: 330,
    source: 'select/select_default_example.dart',
    builder: SelectDefaultExample.new,
  ),
  GalleryExample(
    title: 'Groups and a long list',
    description: 'Kicker labels, pencil rules between groups, and scroll arrows when the slip runs out of room. The item-aligned placement (the default) lays the chosen row over the field.',
    height: 420,
    source: 'select/select_groups_example.dart',
    builder: SelectGroupsExample.new,
  ),
  GalleryExample(
    title: 'Sizes and states',
    description: 'Default and sm, invalid (red pencil box, a bang before the chevron), disabled (dashed, pale) and a disabled row inside the list.',
    layout: ExampleLayout.stack,
    height: 420,
    source: 'select/select_states_example.dart',
    builder: SelectStatesExample.new,
  ),
  GalleryExample(
    title: 'In a form',
    description: 'Two controlled selects in one form: the shift is required, so filing without one marks it invalid.',
    layout: ExampleLayout.stack,
    height: 340,
    source: 'select/select_profile_form_example.dart',
    builder: SelectProfileFormExample.new,
  ),
  GalleryExample(
    title: 'Demo',
    description: 'Official `select-demo`: a 180 px trigger with a placeholder and one labeled group of fruit. The trigger is a drawn field with a hand-drawn chevron; the list is a slip, the pointed-at row wears the highlighter and the chosen one a felt tick. Type a letter to jump to a fruit. Only addition: a semanticLabel on the trigger, because a placeholder is not a name.',
    height: 340,
    source: 'select/select_demo_example.dart',
    builder: SelectDemoExample.new,
  ),
  GalleryExample(
    title: 'Scrollable',
    description: 'Official `select-scrollable`: twenty-eight time zones in five groups, far taller than the screen allows. The list keeps to the space there is and scrolls, with a chevron at each end that scrolls it while you hold the pointer over it. Only addition: a semanticLabel on the trigger, because a placeholder is not a name.',
    height: 360,
    source: 'select/select_scrollable_example.dart',
    builder: SelectScrollableExample.new,
  ),
];
