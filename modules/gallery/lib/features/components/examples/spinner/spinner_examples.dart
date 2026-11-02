import 'package:gallery/features/components/examples/spinner/spinner.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/spinner/`.
const spinnerExamples = <GalleryExample>[
  GalleryExample(
    title: 'Sizes and colors',
    description: 'Size it with size; the scribble is redrawn for the size (fewer, wider turns when it is small). It draws in whatever text color it sits in. With reduced motion on, every one of these stands still, whole.',
    layout: ExampleLayout.stack,
    source: 'spinner/spinner_sizes_and_colors_example.dart',
    builder: SpinnerSizesAndColorsExample.new,
  ),
  GalleryExample(
    title: 'In buttons and badges',
    description: 'A spinner in front of a label is shadcn\'s pattern. The button is disabled while the request runs and says what is happening; press it to see a save go through.',
    layout: ExampleLayout.stack,
    source: 'spinner/spinner_in_buttons_example.dart',
    builder: SpinnerInButtonsExample.new,
  ),
  GalleryExample(
    title: 'Stubby is writing',
    description: 'For a page or a panel that is loading rather than a button: Stubby writes in three frames, flipped like a flip book, and the words say what they are waiting for. The status carries the name. With reduced motion he holds still with the scribble finished.',
    layout: ExampleLayout.stack,
    source: 'spinner/spinner_stubby_writes_example.dart',
    builder: SpinnerStubbyWritesExample.new,
  ),
  GalleryExample(
    title: 'Demo',
    description: 'Official `spinner-demo`: a muted row that reads "Processing payment..." with a spinner as its media and the amount at the end. The scribble is a hand-wound spiral whose line is drawn and undrawn round and round; with reduced motion it stands still, whole.',
    source: 'spinner/spinner_demo_example.dart',
    builder: SpinnerDemoExample.new,
  ),
  GalleryExample(
    title: 'Basic',
    description: 'Official `spinner-basic`: the bare `Spinner()`, 16 px by default. It is a status with the name "Loading", and it draws in the current text color.',
    source: 'spinner/spinner_basic_example.dart',
    builder: SpinnerBasicExample.new,
  ),
  GalleryExample(
    title: 'Button',
    description: 'Official `spinner-button`: a spinner as the first child of a disabled small button, in the default, outline and secondary variants. The button dashes itself when disabled, so the wait shows in the outline as well as in the scribble.',
    source: 'spinner/spinner_button_example.dart',
    builder: SpinnerButtonExample.new,
  ),
  GalleryExample(
    title: 'Badge',
    description: 'Official `spinner-badge`: Syncing, Updating and Processing badges in the default, secondary and outline variants, each with a spinner in front of the word.',
    source: 'spinner/spinner_badge_example.dart',
    builder: SpinnerBadgeExample.new,
  ),
  GalleryExample(
    title: 'Input group',
    description: 'Official `spinner-input-group`: a disabled field with a spinner at its end, and a disabled textarea whose footer says "Validating..." beside a send button. The group draws itself dashed because its control is disabled. Only change: the controls get a `semanticLabel`.',
    source: 'spinner/spinner_input_group_example.dart',
    builder: SpinnerInputGroupExample.new,
  ),
  GalleryExample(
    title: 'Empty',
    description: 'Official `spinner-empty`: an Empty state whose icon slip holds a spinner, with a title, a sentence and a Cancel button. For a whole page or panel that is waiting, `SpinnerVariant.write` has Stubby writing instead.',
    source: 'spinner/spinner_empty_example.dart',
    builder: SpinnerEmptyExample.new,
  ),
  GalleryExample(
    title: 'Color',
    description: 'Official `spinner-color`: five 24 px spinners, each in its own text color. shadcn uses the palette\'s red, green, blue, yellow and purple; here they are red felt-tip, green pencil, blue biro, orange marker and grape marker (yellow highlighter is too pale to read as a line on paper).',
    source: 'spinner/spinner_color_example.dart',
    builder: SpinnerColorExample.new,
  ),
  GalleryExample(
    title: 'Custom',
    description: 'Official `spinner-custom`: a spinner is nothing more than a status around an icon that turns, so you can build one from any glyph. Here the hand-drawn `loader-circle` spins (and stops for reduced motion). A drawn icon stays decorative, so the name sits on a Semantics around it.',
    source: 'spinner/spinner_custom_example.dart',
    builder: SpinnerCustomExample.new,
  ),
  GalleryExample(
    title: 'Size',
    description: 'Official `spinner-size`: 12, 16, 24 and 32 px. The scribble is redrawn for each size (fewer, wider turns when it is small) rather than scaled, so the pencil line keeps its weight.',
    source: 'spinner/spinner_size_example.dart',
    builder: SpinnerSizeExample.new,
  ),
  GalleryExample(
    title: 'Item',
    description: 'Official `spinner-item`: an outlined row for a download, with the spinner as icon media, a title and sizes, a Cancel button that appears when there is room, and a progress bar in the footer. The bar carries a `semanticLabel`, which the original lacks.',
    source: 'spinner/spinner_item_example.dart',
    builder: SpinnerItemExample.new,
  ),
];
