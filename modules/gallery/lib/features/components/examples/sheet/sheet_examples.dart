import 'package:gallery/features/components/examples/sheet/sheet.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/sheet/`.
const sheetExamples = <GalleryExample>[
  GalleryExample(
    title: 'Four sides',
    description:
        'The page is bound along whichever edge faces the middle of the screen: the coils hang on the left of a right-hand page, along the bottom of a page that comes from the top.',
    height: 220,
    source: 'sheet/sheet_sides_example.dart',
    builder: SheetSidesExample.new,
  ),
  GalleryExample(
    title: 'Bindings',
    description:
        'Five ways to finish the inner edge: spiral coils, three binder holes, a perforated tear line, a torn pad edge, or nothing. Perf and torn are drawn when the page opens; the others are cheap strips.',
    height: 220,
    source: 'sheet/sheet_bindings_example.dart',
    builder: SheetBindingsExample.new,
  ),
  GalleryExample(
    title: 'Edit profile',
    description:
        'The shadcn demo: a form in a side sheet with the footer pushed to the bottom.',
    height: 220,
    source: 'sheet/sheet_edit_profile_example.dart',
    builder: SheetEditProfileExample.new,
  ),
  GalleryExample(
    title: 'Mobile navigation',
    description:
        'A menu page from the left with holes for a binder. The list scrolls inside the page (an Expanded scroll view in the page, never the sheet itself) and every link closes it.',
    height: 220,
    source: 'sheet/sheet_navigation_example.dart',
    builder: SheetNavigationExample.new,
  ),
  GalleryExample(
    title: 'Demo',
    description:
        'Official `sheet-demo`, same parts and layout: header, two fields, a footer with Save and Close. The page slides in from the right, bound with a wire coil along its left edge. Escape, the x and a click outside all put it away.',
    height: 200,
    source: 'sheet/sheet_demo_example.dart',
    builder: SheetDemoExample.new,
  ),
  GalleryExample(
    title: 'Side',
    description:
        'Official `sheet-side`: four triggers in a two-column grid, one page per edge, each with two inline fields.',
    height: 200,
    source: 'sheet/sheet_side_example.dart',
    builder: SheetSideExample.new,
  ),
];
