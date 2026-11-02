import 'package:gallery/features/components/examples/sidebar/sidebar.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/sidebar/`.
const sidebarExamples = <GalleryExample>[
  GalleryExample(
    title: 'App sidebar',
    description:
        'The real thing: a team switcher in the header, a group with a collapsible sub-menu, projects with per-row actions and a count, and the account menu in the footer. The current page has the highlighter and the bracket in the margin. Try Ctrl/Cmd+B.',
    layout: ExampleLayout.full,
    stage: ExampleStage.desk,
    height: 600,
    source: 'sidebar/sidebar_app_sidebar_example.dart',
    builder: SidebarAppSidebarExample.new,
  ),
  GalleryExample(
    title: 'Collapse to icons',
    description:
        'collapsible: SidebarCollapsible.icon shrinks the pad to a 3rem strip: labels fade, the margin bracket steps aside, the binder clip comes off, and each button names itself in a tooltip. The state is controlled here so the page can read it.',
    layout: ExampleLayout.full,
    stage: ExampleStage.desk,
    height: 460,
    source: 'sidebar/sidebar_icons_example.dart',
    builder: SidebarIconsExample.new,
  ),
  GalleryExample(
    title: 'Variants and sides',
    description:
        'sidebar docks to the edge and casts its shadow toward the page; floating is set down on the desk and turned a little; inset leaves a margin and makes the page itself a sheet of paper. Either side of the screen works, and the clip and torn edge follow.',
    layout: ExampleLayout.full,
    stage: ExampleStage.desk,
    height: 400,
    source: 'sidebar/sidebar_variants_example.dart',
    builder: SidebarVariantsExample.new,
  ),
  GalleryExample(
    title: 'Search and loading',
    description:
        'A long menu stays cheap: 40 notebooks are 40 list items with no drawing each, only the current one draws its mark. The search field filters them, the plus on the label adds one, and Reload shows loading rows (their widths come from a seed, so they are the same on every build).',
    layout: ExampleLayout.full,
    stage: ExampleStage.desk,
    height: 560,
    source: 'sidebar/sidebar_search_and_loading_example.dart',
    builder: SidebarSearchAndLoadingExample.new,
  ),
  GalleryExample(
    title: 'Demo',
    description:
        'Official `sidebar-demo`: one group of five links and an inset with the trigger. The pad hangs from a binder clip and every link wears the highlighter when pointed at. The outer frame is only there so the pad stays inside this preview (in an app the provider goes at the root); try Ctrl/Cmd+B.',
    layout: ExampleLayout.full,
    stage: ExampleStage.desk,
    height: 320,
    source: 'sidebar/sidebar_demo_example.dart',
    builder: SidebarDemoExample.new,
  ),
  GalleryExample(
    title: 'Header and footer',
    description:
        'Official `sidebar-header` and `sidebar-footer` in one pad: a workspace switcher on top whose menu opens downward at the width of its button, and an account menu at the bottom that opens upward (`side: OverlaySide.top`). While a menu is open its button keeps the highlighter, where shadcn tints it with the accent color.',
    layout: ExampleLayout.full,
    stage: ExampleStage.desk,
    height: 360,
    source: 'sidebar/sidebar_header_and_footer_example.dart',
    builder: SidebarHeaderAndFooterExample.new,
  ),
  GalleryExample(
    title: 'Group',
    description:
        'Official `sidebar-group`: a `SidebarGroup` is a label (a typewriter kicker) over a menu. Two buttons here; a pad can hold as many groups as it likes. Like the original, this one has no inset page beside it.',
    layout: ExampleLayout.full,
    stage: ExampleStage.desk,
    height: 230,
    source: 'sidebar/sidebar_group_example.dart',
    builder: SidebarGroupExample.new,
  ),
  GalleryExample(
    title: 'Collapsible group',
    description:
        'Official `sidebar-group-collapsible`: the group label becomes the trigger of a Collapsible (a `CollapsibleTrigger` around the `SidebarGroupLabel`), with a chevron that turns over as it opens. The label wears the highlighter on hover, where shadcn tints it with the accent color.',
    layout: ExampleLayout.full,
    stage: ExampleStage.desk,
    height: 230,
    source: 'sidebar/sidebar_group_collapsible_example.dart',
    builder: SidebarGroupCollapsibleExample.new,
  ),
  GalleryExample(
    title: 'Group action',
    description:
        'Official `sidebar-group-action`: a `SidebarGroupAction` is a small button in the corner of a group, next to its label. Here the plus posts a toast. The original parks the Toaster at the bottom left with a margin to clear the sidebar; inside this frame it sits at the bottom right instead.',
    layout: ExampleLayout.full,
    stage: ExampleStage.desk,
    height: 250,
    source: 'sidebar/sidebar_group_action_example.dart',
    builder: SidebarGroupActionExample.new,
  ),
  GalleryExample(
    title: 'Menu',
    description:
        'Official `sidebar-menu`: five projects as `SidebarMenuButton`s. Each row carries its own line of the pad\'s ruling, so this list costs no drawing per row; only a current page (`isActive`) draws a mark.',
    layout: ExampleLayout.full,
    stage: ExampleStage.desk,
    height: 260,
    source: 'sidebar/sidebar_menu_example.dart',
    builder: SidebarMenuExample.new,
  ),
  GalleryExample(
    title: 'Menu action and badge',
    description:
        'Official `sidebar-menu-action` and `sidebar-menu-badge` in one pad. Top group: each row has a `SidebarMenuAction` (a small button that opens a menu), and the row keeps the highlighter while its menu is open. Bottom group: a `SidebarMenuBadge` writes a count in the margin in blue felt tip. Action and badge share the same corner, so a row takes one or the other.',
    layout: ExampleLayout.full,
    stage: ExampleStage.desk,
    height: 380,
    source: 'sidebar/sidebar_menu_action_and_badge_example.dart',
    builder: SidebarMenuActionAndBadgeExample.new,
  ),
  GalleryExample(
    title: 'Menu sub',
    description:
        'Official `sidebar-menu-sub`: a table of contents, each section a button over an indented `SidebarMenuSub` that is always open. A pencil line runs down the start of each sub-list. The content scrolls inside the pad when it is taller than the pad. The data is the original\'s, written as strings.',
    layout: ExampleLayout.full,
    stage: ExampleStage.desk,
    height: 420,
    source: 'sidebar/sidebar_menu_sub_example.dart',
    builder: SidebarMenuSubExample.new,
  ),
  GalleryExample(
    title: 'Menu collapsible',
    description:
        'Official `sidebar-menu-collapsible`: the same table of contents with each section folding open and shut. The first section starts open. Each `SidebarMenuItem` holds a `Collapsible` around the button and its sub-list, and the chevron turns as it opens.',
    layout: ExampleLayout.full,
    stage: ExampleStage.desk,
    height: 420,
    source: 'sidebar/sidebar_menu_collapsible_example.dart',
    builder: SidebarMenuCollapsibleExample.new,
  ),
  GalleryExample(
    title: 'Controlled and loading',
    description:
        'Official `sidebar-controlled` and `sidebar-rsc` in one pad. Controlled: `open` and `onOpenChange` on the provider, with the state kept in the page so any button can open and close the pad. Loading: `SidebarMenuSkeleton` rows (with icons) stand in while the projects load, then are swapped for the list. The original\'s loading is a React Server Component behind Suspense; here a timer stands in for the fetch. Reload runs it again.',
    layout: ExampleLayout.full,
    stage: ExampleStage.desk,
    height: 360,
    source: 'sidebar/sidebar_controlled_and_loading_example.dart',
    builder: SidebarControlledAndLoadingExample.new,
  ),
];
