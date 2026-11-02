import 'package:gallery/features/components/examples/card/card.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/card/`.
const cardExamples = <GalleryExample>[
  GalleryExample(
    title: 'Settings card',
    description:
        'The whole family: a title and description, an action tucked into the header, content, and a footer with a pencil rule above it.',
    layout: ExampleLayout.stack,
    source: 'card/card_settings_example.dart',
    builder: CardSettingsExample.new,
  ),
  GalleryExample(
    title: 'Stat cards',
    description:
        'Index cards for one number each. The figures are set in the script font with tabular numerals; the trend says up or down in words, not only in color.',
    layout: ExampleLayout.stack,
    source: 'card/card_stat_example.dart',
    builder: CardStatExample.new,
  ),
  GalleryExample(
    title: 'Guest book',
    description:
        'A form on a guest check: green ledger paper, a perforated top, a dashed footer. The fields are ordinary labeled inputs; the sheet only changes the paper they are written on.',
    layout: ExampleLayout.stack,
    source: 'card/card_form_example.dart',
    builder: CardFormExample.new,
  ),
  GalleryExample(
    title: 'Article card',
    description:
        'A card taped at the corners with a torn bottom edge, for something you would pin above your desk.',
    layout: ExampleLayout.stack,
    source: 'card/card_article_example.dart',
    builder: CardArticleExample.new,
  ),
  GalleryExample(
    title: 'On every stock',
    description:
        'A card is a sheet of paper, so it takes any stock, edge and printed rules: graph paper, a dot grid, kraft, an index card with a torn top.',
    layout: ExampleLayout.stack,
    source: 'card/card_stocks_example.dart',
    builder: CardStocksExample.new,
  ),
  GalleryExample(
    title: 'Pinned, clipped, stapled',
    description:
        'The `fastener` slot holds a card down. Calm density hides every prop, so a dense dashboard keeps its plain sheets.',
    layout: ExampleLayout.stack,
    source: 'card/card_fasteners_example.dart',
    builder: CardFastenersExample.new,
  ),
  GalleryExample(
    title: 'Login',
    description:
        'The shadcn demo: a title, a description, a link tucked into CardAction, a form of two labeled fields with a "forgot" link beside the second label, and a footer of two full-width buttons. Nothing is drawn but the paper, the fields and the buttons.',
    layout: ExampleLayout.stack,
    source: 'card/card_login_example.dart',
    builder: CardLoginExample.new,
  ),
  GalleryExample(
    title: 'Create a project',
    description:
        'The shadcn demo: a card around a small form. A text field, a Select (its list opens in `SelectPosition.popper` so it lines up with the trigger) and a footer with the two answers pushed apart. Deploy reports what it would do.',
    layout: ExampleLayout.stack,
    height: 460,
    source: 'card/card_create_project_example.dart',
    builder: CardCreateProjectExample.new,
  ),
];
