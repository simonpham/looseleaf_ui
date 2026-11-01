import 'package:gallery/features/components/examples/button/button.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/button/`.
const buttonExamples = <GalleryExample>[
  GalleryExample(
    title: 'Variants',
    description: 'Six ways to hold a pen: marker, red pencil, ink, highlighter, pencil whisper and blue felt.',
    layout: ExampleLayout.stack,
    source: 'button/button_variants_example.dart',
    builder: ButtonVariantsExample.new,
  ),
  GalleryExample(
    title: 'Sizes',
    description: 'The shadcn heights (24, 32, 36, 40) and the square icon buttons. Icon buttons need a semanticLabel.',
    layout: ExampleLayout.stack,
    source: 'button/button_sizes_example.dart',
    builder: ButtonSizesExample.new,
  ),
  GalleryExample(
    title: 'States',
    description: 'Rest, hover, pressed, keyboard focus and disabled, forced with forcedStates so they can be compared side by side. Hover any button yourself: the drawing tilts and lifts a shadow line.',
    source: 'button/button_states_example.dart',
    builder: ButtonStatesExample.new,
  ),
  GalleryExample(
    title: 'As a link',
    description: 'Buttons that open a page. A disabled one is announced as disabled and cannot be followed.',
    layout: ExampleLayout.stack,
    source: 'button/button_link_example.dart',
    builder: ButtonLinkExample.new,
  ),
  GalleryExample(
    title: 'Saving, in three states',
    description: 'A real save button: pressing it disables it while the request runs, says what is happening, and confirms. The label is text; nothing here needs an icon.',
    layout: ExampleLayout.stack,
    source: 'button/button_saving_example.dart',
    builder: ButtonSavingExample.new,
  ),
  GalleryExample(
    title: 'With an icon',
    description: 'Icons sit before or after the label. Button tightens its padding when it sees one, sizes the pencilled icon to 16 px (12 px in xs) and keeps the drawing behind both.',
    layout: ExampleLayout.stack,
    source: 'button/button_with_icon_example.dart',
    builder: ButtonWithIconExample.new,
  ),
  GalleryExample(
    title: 'Icon buttons',
    description: 'Square buttons for one glyph, in the four icon sizes. Give each a semanticLabel; the drawing is decorative. The last one is a real toggle that swaps its icon.',
    layout: ExampleLayout.stack,
    source: 'button/button_icon_buttons_example.dart',
    builder: ButtonIconButtonsExample.new,
  ),
  GalleryExample(
    title: 'Loading, with a spinner',
    description: 'The shadcn pattern: a Spinner in front of the label. The first and last are the static state (disabled buttons are dashed). Press the second to watch a request go through: it stays enabled and busy while it works, so keyboard focus stays on it.',
    layout: ExampleLayout.stack,
    source: 'button/button_loading_spinner_example.dart',
    builder: ButtonLoadingSpinnerExample.new,
  ),
  GalleryExample(
    title: 'Text and icon buttons, size by size',
    description: 'Each height comes with its square twin: sm and iconSm (32 px), default and icon (36 px), lg and iconLg (40 px), and our extra xs pair at 24 px. Put them side by side and the labels and glyphs line up on one baseline.',
    layout: ExampleLayout.stack,
    source: 'button/button_size_pairs_example.dart',
    builder: ButtonSizePairsExample.new,
  ),
];
