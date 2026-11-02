import 'package:gallery/features/components/examples/navigation_menu/navigation_menu.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/navigation-menu/`.
const navigationMenuExamples = <GalleryExample>[
  GalleryExample(
    title: 'Getting started',
    description:
        'The shadcn demo on an index strip: a featured card with the mascot beside three rows, a two-column panel of components, and a plain tab. Move from Getting started to Components: the slip resizes, the panels slide inside it and the felt-tip underline glides along.',
    height: 420,
    source: 'navigation_menu/navigation_menu_getting_started_example.dart',
    builder: NavigationMenuGettingStartedExample.new,
  ),
  GalleryExample(
    title: 'Links only',
    description:
        'No panels: a strip of links. In the strip a link is a tab like the triggers, and the current page (active) is filled with highlighter and announced as selected. Arrow keys walk the tabs; onPressed is where your router goes.',
    source: 'navigation_menu/navigation_menu_links_example.dart',
    builder: NavigationMenuLinksExample.new,
  ),
  GalleryExample(
    title: 'A slip under each tab',
    description:
        'viewport: false: there is no shared slip, so each panel is a slip of its own set down under its tab, at the size of its contents. Good for short menus of a few links.',
    height: 300,
    source: 'navigation_menu/navigation_menu_no_viewport_example.dart',
    builder: NavigationMenuNoViewportExample.new,
  ),
  GalleryExample(
    title: 'Site header (composed)',
    description:
        'A real use: the logo, the strip and the account buttons in one header on a sheet of paper. The panels open over the page below; the sign-in button is a normal Button.',
    stage: ExampleStage.desk,
    height: 340,
    source: 'navigation_menu/navigation_menu_site_header_example.dart',
    builder: NavigationMenuSiteHeaderExample.new,
  ),
  GalleryExample(
    title: 'Six items (as written)',
    description:
        'shadcn\'s `navigation-menu-demo` line for line: `viewport` on below the `md` width, a plain link in the strip, the last three panels hidden below `md`, and a ListItem helper.',
    height: 460,
    source: 'navigation_menu/navigation_menu_demo_example.dart',
    builder: NavigationMenuDemoExample.new,
  ),
];
