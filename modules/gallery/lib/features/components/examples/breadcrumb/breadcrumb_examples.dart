import 'package:gallery/features/components/examples/breadcrumb/breadcrumb.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/breadcrumb/`.
const breadcrumbExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description: 'Home, Components, and the page you are on. Point at Components: links wear the highlighter. The current page is bold and underlined twice in blue felt.',
    source: 'breadcrumb/breadcrumb_default_example.dart',
    builder: BreadcrumbDefaultExample.new,
  ),
  GalleryExample(
    title: 'Folded path with a menu',
    description: 'The middle of a long path folded into an ellipsis that opens a dropdown of the hidden crumbs (the ellipsis is the trigger, so it is a real button with a name).',
    source: 'breadcrumb/breadcrumb_ellipsis_menu_example.dart',
    builder: BreadcrumbEllipsisMenuExample.new,
  ),
  GalleryExample(
    title: 'Separators',
    description: 'A pencil slash is the default. A child replaces it: a drawn chevron, an arrow, a dot. A link runs your own navigation in onPressed.',
    source: 'breadcrumb/breadcrumb_separators_example.dart',
    builder: BreadcrumbSeparatorsExample.new,
  ),
  GalleryExample(
    title: 'File path (composed)',
    description: 'A real use: the crumbs are the folders you have opened. Click one to go back up; when the path is longer than four names the middle folds into an ellipsis whose menu takes you there too.',
    stage: ExampleStage.desk,
    height: 260,
    source: 'breadcrumb/breadcrumb_file_path_example.dart',
    builder: BreadcrumbFilePathExample.new,
  ),
  GalleryExample(
    title: 'A crumb that opens a menu',
    description: 'Any crumb can be a DropdownMenuTrigger: here the middle name is a button with a little chevron, and its menu lists the sibling pages. It wears the highlighter while it is open, like a link does when you point at it.',
    source: 'breadcrumb/breadcrumb_dropdown_example.dart',
    builder: BreadcrumbDropdownExample.new,
  ),
  GalleryExample(
    title: 'Collapsed, with no menu',
    description: 'The shadcn demo of BreadcrumbEllipsis: three pencil dots stand in for the middle of a long path. On its own it is only decoration, hidden from screen readers; wrapped in a link it needs a semanticLabel, and then it can lead to the full list.',
    layout: ExampleLayout.stack,
    source: 'breadcrumb/breadcrumb_collapsed_example.dart',
    builder: BreadcrumbCollapsedExample.new,
  ),
  GalleryExample(
    title: "With your router's navigation",
    description: 'BreadcrumbLink keeps the highlighter, spacing and focus ring and hands the tap to you: here onPressed changes the path without loading a page (a stand-in for your router); the trail is built from the path.',
    layout: ExampleLayout.stack,
    source: 'breadcrumb/breadcrumb_router_link_example.dart',
    builder: BreadcrumbRouterLinkExample.new,
  ),
  GalleryExample(
    title: 'Responsive: menu or drawer',
    description: 'A deep path keeps its first and last two crumbs and folds the rest. The fold opens a dropdown on a wide screen and a drawer on a phone, from one widget that reads the window width.',
    source: 'breadcrumb/breadcrumb_responsive_example.dart',
    builder: BreadcrumbResponsiveExample.new,
  ),
];
