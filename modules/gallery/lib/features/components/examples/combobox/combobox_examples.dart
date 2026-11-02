import 'package:gallery/features/components/examples/combobox/combobox.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/combobox/`.
const comboboxExamples = <GalleryExample>[
  GalleryExample(
    title: 'Framework picker',
    description: 'The shadcn recipe: press the field, type to narrow ("svelte" finds SvelteKit), arrow keys and Enter to choose. The chosen row ends in a blue tick. Try a word that matches nothing to meet Stubby.',
    height: 380,
    source: 'combobox/combobox_framework_example.dart',
    builder: ComboboxFrameworkExample.new,
  ),
  GalleryExample(
    title: 'Labels as hang-tags',
    description: 'A multi-select whose choices are tags on a string: each a little different, a punched hole at the point, the x wearing the highlighter when you reach for it. Click anywhere in the field to type; Backspace in the empty input takes the last tag back. autoTone gives each label its own color.',
    height: 440,
    source: 'combobox/combobox_labels_as_tags_example.dart',
    builder: ComboboxLabelsAsTagsExample.new,
  ),
  GalleryExample(
    title: 'Create what you typed',
    description: 'Type a name that is not in the list and the last row offers to add it. Choosing it calls onCreate (you add it to your list) and then chooses it. An exact match, in any case, hides the offer.',
    height: 380,
    source: 'combobox/combobox_creatable_example.dart',
    builder: ComboboxCreatableExample.new,
  ),
  GalleryExample(
    title: 'Results from a server',
    description: 'Filtering is off (filter: null) and the search text is watched: while a request is in flight the loops show and the empty message waits. Try "gra" (two people), then "zzz".',
    height: 380,
    source: 'combobox/combobox_async_search_example.dart',
    builder: ComboboxAsyncSearchExample.new,
  ),
  GalleryExample(
    title: 'An editable field in a form',
    description: 'ComboboxInput on its own is the field: it shows the chosen country until you type, opens as you type, and puts the country back if you close without choosing. Ship sends the code.',
    stage: ExampleStage.desk,
    height: 580,
    source: 'combobox/combobox_country_field_example.dart',
    builder: ComboboxCountryFieldExample.new,
  ),
  GalleryExample(
    title: 'A filter inside a menu',
    description: 'The shadcn recipe for "apply a label": a row\'s action menu has a sub-menu, and the sub-menu holds a Command, so a long list of labels can be searched with the keyboard. The palette puts its own slip away inside a menu, because the menu is already the paper.',
    height: 480,
    source: 'combobox/combobox_menu_with_labels_example.dart',
    builder: ComboboxMenuWithLabelsExample.new,
  ),
  GalleryExample(
    title: 'Popover and Command, by hand',
    description: 'The composable recipe behind the Combobox: a button, a Popover that opens to its side, and a Command inside it for the search and the rows. Reach for it when you want full control of the trigger; the Combobox component wraps the same parts.',
    height: 340,
    source: 'combobox/combobox_popover_status_example.dart',
    builder: ComboboxPopoverStatusExample.new,
  ),
  GalleryExample(
    title: 'Responsive: popover or drawer',
    description: 'One list, two shells: a popover next to the button on a wide screen, a drawer from the bottom on a phone, where a small floating box is hard to hit. The window width picks the shell.',
    height: 360,
    source: 'combobox/combobox_responsive_example.dart',
    builder: ComboboxResponsiveExample.new,
  ),
];
