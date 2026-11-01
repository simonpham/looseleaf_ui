import 'package:gallery/features/components/examples/sidebar/sidebar.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/sidebar/`.
const sidebarExamples = <GalleryExample>[
  GalleryExample(
    title: 'App sidebar',
    description: 'The real thing: a team switcher in the header, a group with a collapsible sub-menu, projects with per-row actions and a count, and the account menu in the footer. The current page has the highlighter and the bracket in the margin. Try Ctrl/Cmd+B.',
    layout: ExampleLayout.full,
    stage: ExampleStage.desk,
    height: 600,
    source: 'sidebar/sidebar_app_sidebar_example.dart',
    builder: SidebarAppSidebarExample.new,
  ),
  GalleryExample(
    title: 'Collapse to icons',
    description: 'collapsible: SidebarCollapsible.icon shrinks the pad to a 3rem strip: labels fade, the margin bracket steps aside, the binder clip comes off, and each button names itself in a tooltip. The state is controlled here so the page can read it.',
    layout: ExampleLayout.full,
    stage: ExampleStage.desk,
    height: 460,
    source: 'sidebar/sidebar_icons_example.dart',
    builder: SidebarIconsExample.new,
  ),
  GalleryExample(
    title: 'Variants and sides',
    description: 'sidebar docks to the edge and casts its shadow toward the page; floating is set down on the desk and turned a little; inset leaves a margin and makes the page itself a sheet of paper. Either side of the screen works, and the clip and torn edge follow.',
    layout: ExampleLayout.full,
    stage: ExampleStage.desk,
    height: 400,
    source: 'sidebar/sidebar_variants_example.dart',
    builder: SidebarVariantsExample.new,
  ),
  GalleryExample(
    title: 'Search and loading',
    description: 'A long menu stays cheap: 40 notebooks are 40 list items with no drawing each, only the current one draws its mark. The search field filters them, the plus on the label adds one, and Reload shows loading rows (their widths come from a seed, so they are the same on every build).',
    layout: ExampleLayout.full,
    stage: ExampleStage.desk,
    height: 560,
    source: 'sidebar/sidebar_search_and_loading_example.dart',
    builder: SidebarSearchAndLoadingExample.new,
  ),
];
