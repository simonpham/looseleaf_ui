import 'package:gallery/features/components/examples/tabs/tabs.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/tabs/`.
const tabsExamples = <GalleryExample>[
  GalleryExample(
    title: 'Account and password',
    description: 'Index-divider tabs: the active one is lifted and filled with highlighter, and the pencil baseline breaks under it. Arrow keys move between tabs, Home and End jump to the ends.',
    source: 'tabs/tabs_account_example.dart',
    builder: TabsAccountExample.new,
  ),
  GalleryExample(
    title: 'Line tabs with icons',
    description: 'TabsVariant.line is a hairline with the active tab underlined in blue felt, wiped in from the reading side. Icons sit at 16 px in the same weight as the label; a disabled tab is skipped by the arrow keys.',
    source: 'tabs/tabs_line_icons_example.dart',
    builder: TabsLineIconsExample.new,
  ),
  GalleryExample(
    title: 'Binder tabs',
    description: 'TabsOrientation.vertical: tabs down a spine like binder dividers, the active one filled and open towards its page. ArrowUp and ArrowDown move between them.',
    height: 240,
    source: 'tabs/tabs_vertical_example.dart',
    builder: TabsVerticalExample.new,
  ),
  GalleryExample(
    title: 'Controlled, manual activation',
    description: 'value and onValueChange drive the tabs from outside; TabsActivationMode.manual moves focus with the arrow keys and only opens a tab on Enter or Space, which suits panels that are slow to load.',
    source: 'tabs/tabs_controlled_example.dart',
    builder: TabsControlledExample.new,
  ),
  GalleryExample(
    title: 'Demo',
    description: 'Official tabs-demo: Account and Password tabs, each holding a Card with a small form. The tabs are index dividers standing on a pencil baseline; the active one is lifted and filled with highlighter. Arrow keys move between tabs, Home and End jump to the first and last.',
    height: 460,
    source: 'tabs/tabs_demo_example.dart',
    builder: TabsDemoExample.new,
  ),
];
