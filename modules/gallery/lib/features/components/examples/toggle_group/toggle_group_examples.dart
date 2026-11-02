import 'package:gallery/features/components/examples/toggle_group/toggle_group.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/toggle-group/`.
const toggleGroupExamples = <GalleryExample>[
  GalleryExample(
    title: 'Pick one',
    description:
        'ToggleGroupType.single: one item is on, clicking it again clears it. Joined outline items share one box; the seam between two items is a short pencil stroke at the edge they share.',
    layout: ExampleLayout.stack,
    source: 'toggle_group/toggle_group_single_choice_example.dart',
    builder: ToggleGroupSingleChoiceExample.new,
  ),
  GalleryExample(
    title: 'Pick several',
    description:
        'ToggleGroupType.multiple: any of the items can be on at once, and each one knows its own state. Icon items need names; hand-lettered items are just text in the script font. The sample line follows the group.',
    layout: ExampleLayout.stack,
    source: 'toggle_group/toggle_group_multiple_example.dart',
    builder: ToggleGroupMultipleExample.new,
  ),
  GalleryExample(
    title: 'Joined, separate, vertical',
    description:
        'Outline items that touch share one box. Give them spacing and each keeps its own. Borderless items only whisper their seams. Vertical groups stack and use the up and down arrows.',
    layout: ExampleLayout.stack,
    source: 'toggle_group/toggle_group_variants_spacing_example.dart',
    builder: ToggleGroupVariantsSpacingExample.new,
  ),
  GalleryExample(
    title: 'A view switcher',
    description:
        'The group in a card header, driving what the card shows. Every item has a name; the current view is also written out in the description.',
    layout: ExampleLayout.stack,
    source: 'toggle_group/toggle_group_view_switcher_example.dart',
    builder: ToggleGroupViewSwitcherExample.new,
  ),
  GalleryExample(
    title: 'In a field',
    description:
        'A group of days inside a Field keeps the width of its buttons, and `invalid` draws the one shared box in red pencil, like any invalid field. Pick a day and it turns back to ink.',
    layout: ExampleLayout.stack,
    source: 'toggle_group/toggle_group_in_a_field_example.dart',
    builder: ToggleGroupInAFieldExample.new,
  ),
  GalleryExample(
    title: 'Demo',
    description:
        'Official `toggle-group-demo`: three outline toggles, any number of them on (ToggleGroupType.multiple). Joined outline items share one felt-tip box with a drawn seam between them. One label differs from the original, which calls the underline "strikethrough".',
    source: 'toggle_group/toggle_group_demo_example.dart',
    builder: ToggleGroupDemoExample.new,
  ),
  GalleryExample(
    title: 'Disabled',
    description:
        'Official `toggle-group-disabled`: `disabled` on the group disables every item. The items are drawn as dashed pencil gray, and none of them can be focused or toggled.',
    source: 'toggle_group/toggle_group_disabled_example.dart',
    builder: ToggleGroupDisabledExample.new,
  ),
  GalleryExample(
    title: 'Large',
    description:
        'Official `toggle-group-lg`: ToggleSize.lg on the group sizes every item. The default variant has no box, so the items are only seams and a highlighter body when on.',
    source: 'toggle_group/toggle_group_lg_example.dart',
    builder: ToggleGroupLgExample.new,
  ),
  GalleryExample(
    title: 'Outline',
    description:
        'Official `toggle-group-outline`: ToggleVariant.outline with ToggleGroupType.multiple. The group draws one box around all its items, so the three read as a single control.',
    source: 'toggle_group/toggle_group_outline_example.dart',
    builder: ToggleGroupOutlineExample.new,
  ),
  GalleryExample(
    title: 'Small',
    description:
        'Official `toggle-group-sm`: ToggleSize.sm with ToggleGroupType.single, so turning one on turns the others off. Arrow keys move between items and the group is one tab stop.',
    source: 'toggle_group/toggle_group_sm_example.dart',
    builder: ToggleGroupSmExample.new,
  ),
  GalleryExample(
    title: 'Single',
    description:
        'Official `toggle-group-single`: ToggleGroupType.single, at most one item on; pressing the one that is on turns it off again, so the group can also hold nothing.',
    source: 'toggle_group/toggle_group_single_example.dart',
    builder: ToggleGroupSingleExample.new,
  ),
  GalleryExample(
    title: 'Spacing',
    description:
        'Official `toggle-group-spacing`: a spacing of 8 pulls the items apart, so each keeps a box of its own. Each item keeps its highlighter body when on and writes its icon in its own color.',
    source: 'toggle_group/toggle_group_spacing_example.dart',
    builder: ToggleGroupSpacingExample.new,
  ),
];
