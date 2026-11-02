import 'package:gallery/features/components/examples/input_group/input_group.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/input-group/`.
const inputGroupExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description:
        'One hand-drawn box around an icon, the field and some text. Click anywhere on an addon and the field takes focus; the focus ring goes around the whole group.',
    layout: ExampleLayout.stack,
    source: 'input_group/input_group_default_example.dart',
    builder: InputGroupDefaultExample.new,
  ),
  GalleryExample(
    title: 'Buttons and states',
    description:
        'Buttons go inside an addon (ghost, xs by default). The group\'s states paint the box: invalid draws the red box, disabled the dashed one, for the whole group at once.',
    layout: ExampleLayout.stack,
    source: 'input_group/input_group_buttons_and_states_example.dart',
    builder: InputGroupButtonsAndStatesExample.new,
  ),
  GalleryExample(
    title: 'Comment box',
    description:
        'Block addons stack above or below a textarea inside the same drawn box: a header line on top, a counter and a send button underneath. The box grows with the text and is redrawn to fit.',
    layout: ExampleLayout.stack,
    source: 'input_group/input_group_comment_box_example.dart',
    builder: InputGroupCommentBoxExample.new,
  ),
  GalleryExample(
    title: 'Subscribe form',
    description:
        'A real-world use: a labeled group in a form. The label points at the control, the marker button is part of the same box, and a bad address turns the whole group red.',
    layout: ExampleLayout.stack,
    source: 'input_group/input_group_newsletter_example.dart',
    builder: InputGroupNewsletterExample.new,
  ),
  GalleryExample(
    title: 'Four groups',
    description:
        'shadcn\'s `input-group-demo`: a search with a result count, a URL with a prefix and a tooltip button, a prompt box with a menu and a send button, and a field with a verified badge. The badge is a drawn `badge-check` where the original has a filled circle.',
    height: 480,
    source: 'input_group/input_group_demo_example.dart',
    builder: InputGroupDemoExample.new,
  ),
  GalleryExample(
    title: 'Labels',
    description:
        'shadcn\'s `input-group-label`: a Label can be an addon, so the @ in front of a handle is a real label for the field, or a title above it (`blockStart`) with a help button at the far end.',
    height: 300,
    source: 'input_group/input_group_label_example.dart',
    builder: InputGroupLabelExample.new,
  ),
  GalleryExample(
    title: 'Text addons',
    description:
        'shadcn\'s `input-group-text`: `InputGroupText` sets plain words beside the field (a currency sign, a scheme, a domain) or under a textarea as a counter. The text is part of the box, not the value.',
    source: 'input_group/input_group_text_example.dart',
    builder: InputGroupTextExample.new,
  ),
  GalleryExample(
    title: 'Tooltips',
    description:
        'shadcn\'s `input-group-tooltip`: help buttons that explain themselves. Two sit at the end as ghost icon buttons; in the third the note opens to the left (`OverlaySide.left`), on the leading addon. The button inside the addon is the trigger, so the tooltip is tied to the control that has focus.',
    height: 300,
    source: 'input_group/input_group_tooltip_example.dart',
    builder: InputGroupTooltipExample.new,
  ),
  GalleryExample(
    title: 'Buttons',
    description:
        'shadcn\'s `input-group-button`: a copy button that turns into a tick, a popover from the button in the leading addon (the button is the trigger, so it is the thing that says it is expanded), a star that toggles, and a text button that ends the box. The original\'s `useCopyToClipboard` hook is a few lines of state here.',
    height: 340,
    source: 'input_group/input_group_button_example.dart',
    builder: InputGroupButtonExample.new,
  ),
  GalleryExample(
    title: 'Inside a button group',
    description:
        'shadcn\'s `input-group-button-group`: an InputGroup as the middle of a ButtonGroup, with `https://` and `.com` as text cells on either side. The first cell holds a Label, so it focuses the field.',
    source: 'input_group/input_group_button_group_example.dart',
    builder: InputGroupButtonGroupExample.new,
  ),
  GalleryExample(
    title: 'Dropdowns',
    description:
        'shadcn\'s `input-group-dropdown`: a menu opened from a button inside the box, once as an ellipsis icon and once as a labeled `Search In...` with a chevron. The menu drops from the button; the box stays put.',
    height: 320,
    source: 'input_group/input_group_dropdown_example.dart',
    builder: InputGroupDropdownExample.new,
  ),
  GalleryExample(
    title: 'Spinners',
    description:
        'shadcn\'s `input-group-spinner`: `disabled` on the group dims the whole box while something is working, with a Spinner in either addon and a word or two of status.',
    source: 'input_group/input_group_spinner_example.dart',
    builder: InputGroupSpinnerExample.new,
  ),
  GalleryExample(
    title: 'Textarea with header and footer',
    description:
        'shadcn\'s `input-group-textarea`: a code box with a file name and two icon buttons above (`blockStart` with a bottom rule) and a cursor position and a Run button below. The corner-down-left glyph is not drawn yet, so Run wears a play icon.',
    source: 'input_group/input_group_textarea_example.dart',
    builder: InputGroupTextareaExample.new,
  ),
  GalleryExample(
    title: 'Icons',
    description:
        'shadcn\'s `input-group-icon`: icons as addons, at the start, at the end, or two together. They are drawn glyphs, not fonts, so each one is a slightly different line.',
    source: 'input_group/input_group_icon_example.dart',
    builder: InputGroupIconExample.new,
  ),
  GalleryExample(
    title: 'Custom control',
    description:
        'shadcn\'s `input-group-custom`: a textarea that grows with the text. The original uses react-textarea-autosize; InputGroupTextarea grows on its own.',
    source: 'input_group/input_group_custom_example.dart',
    builder: InputGroupCustomExample.new,
  ),
];
