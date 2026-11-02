import 'package:gallery/features/components/examples/popover/popover.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/popover/`.
const popoverExamples = <GalleryExample>[
  GalleryExample(
    title: 'Dimensions',
    description:
        'The shadcn demo on a slip with a push-pin through its top edge.',
    height: 340,
    source: 'popover/popover_dimensions_example.dart',
    builder: PopoverDimensionsExample.new,
  ),
  GalleryExample(
    title: 'Arrow and sides',
    description:
        'A felt-tip arrow points at the trigger, whichever side the popover opens on (it flips near the edge of the screen). The arrow\'s height is added to sideOffset for you.',
    height: 380,
    source: 'popover/popover_arrow_sides_example.dart',
    builder: PopoverArrowSidesExample.new,
  ),
  GalleryExample(
    title: 'Stocks and fasteners',
    description:
        'Any stock, held down by a pin of any color or by tape. A torn edge is drawn when the popover opens.',
    height: 380,
    source: 'popover/popover_stocks_and_fasteners_example.dart',
    builder: PopoverStocksAndFastenersExample.new,
  ),
  GalleryExample(
    title: 'Share link (composed)',
    description:
        'A real use: a share popover with a read-only link and a copy button that confirms. Focus goes to the field, the link is selected on focus, Escape returns you to the trigger.',
    height: 300,
    source: 'popover/popover_share_link_example.dart',
    builder: PopoverShareLinkExample.new,
  ),
  GalleryExample(
    title: 'Demo',
    description:
        'Official `popover-demo` with the same markup: a plain heading and paragraph, four label and input rows. The content is named for screen readers (a popover is a dialog).',
    height: 380,
    source: 'popover/popover_demo_example.dart',
    builder: PopoverDemoExample.new,
  ),
];
