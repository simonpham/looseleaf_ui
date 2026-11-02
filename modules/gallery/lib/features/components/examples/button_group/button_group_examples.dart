import 'package:gallery/features/components/examples/button_group/button_group.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/button-group/`.
const buttonGroupExamples = <GalleryExample>[
  GalleryExample(
    title: 'A row of buttons',
    description:
        'Outline buttons side by side share their seams: the edge between two of them is drawn once. Icon buttons, and a column, work the same way.',
    layout: ExampleLayout.stack,
    source: 'button_group/button_group_basic_example.dart',
    builder: ButtonGroupBasicExample.new,
  ),
  GalleryExample(
    title: 'Cells, fields and separators',
    description:
        'A printed cell, an input and a button in one row; two highlighter buttons split by a pencil line; a split button. Filled buttons want a separator, since two markers touching would just be one big blot.',
    layout: ExampleLayout.stack,
    source: 'button_group/button_group_cells_fields_separators_example.dart',
    builder: ButtonGroupCellsFieldsSeparatorsExample.new,
  ),
  GalleryExample(
    title: 'A sourdough order',
    description:
        'The group doing a job: a quantity stepper whose number is a printed cell, a size chooser that is a row of buttons, and a primary action to finish. The status line says what the stepper did.',
    layout: ExampleLayout.stack,
    source: 'button_group/button_group_order_card_example.dart',
    builder: ButtonGroupOrderCardExample.new,
  ),
  GalleryExample(
    title: 'A mail toolbar (groups in a group)',
    description:
        'The shadcn demo: a ButtonGroup of ButtonGroups. A back button, two text buttons, and a Snooze button joined to a menu trigger whose slip has groups, a destructive row and a sub-menu with a radio choice. Groups put a gap between them; each keeps its own seams.',
    layout: ExampleLayout.stack,
    height: 500,
    source: 'button_group/button_group_mail_toolbar_example.dart',
    builder: ButtonGroupMailToolbarExample.new,
  ),
  GalleryExample(
    title: 'Nested: pages and arrows',
    description:
        'Two groups inside one: five numbered buttons and a previous/next pair. The page you are on is a highlighter button, the arrows stop at the ends, and the status line says where you are.',
    layout: ExampleLayout.stack,
    source: 'button_group/button_group_nested_pagination_example.dart',
    builder: ButtonGroupNestedPaginationExample.new,
  ),
  GalleryExample(
    title: 'Sizes',
    description:
        'A group takes the size of its buttons: give every child the same size and the same height, and use the matching square size (iconSm, icon, iconLg) for the icon button at the end. Extra small is ours.',
    layout: ExampleLayout.stack,
    source: 'button_group/button_group_sizes_example.dart',
    builder: ButtonGroupSizesExample.new,
  ),
  GalleryExample(
    title: 'A button with a menu (Follow)',
    description:
        'A split button the way social apps use it: the main action toggles (Follow / Following) and the chevron opens every other thing you can do with the conversation. The menu\'s last row is the destructive one.',
    layout: ExampleLayout.stack,
    height: 420,
    source: 'button_group/button_group_follow_menu_example.dart',
    builder: ButtonGroupFollowMenuExample.new,
  ),
  GalleryExample(
    title: 'A select, a field and a send button',
    description:
        'A Select trigger, an Input and a Button share seams like any other children, in two groups side by side. Try changing the currency and sending.',
    layout: ExampleLayout.stack,
    height: 340,
    source: 'button_group/button_group_currency_select_example.dart',
    builder: ButtonGroupCurrencySelectExample.new,
  ),
  GalleryExample(
    title: 'A button that opens a popover',
    description:
        'The chevron half of a split button can open anything, not only a menu: here a slip with a text area and a few lines of explanation. The popover is named with semanticLabel, and focus goes back to the chevron when it closes.',
    layout: ExampleLayout.stack,
    height: 440,
    source: 'button_group/button_group_agent_popover_example.dart',
    builder: ButtonGroupAgentPopoverExample.new,
  ),
  GalleryExample(
    title: 'A message composer (with an input group)',
    description:
        "A plain add button, then an InputGroup with a toggle inside it: the group's own box holds the field and the voice button. Turning voice mode on disables the field and changes its prompt; the toggle lights up as a highlighter.",
    layout: ExampleLayout.stack,
    height: 200,
    source: 'button_group/button_group_message_composer_example.dart',
    builder: ButtonGroupMessageComposerExample.new,
  ),
];
