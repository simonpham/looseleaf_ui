import 'package:gallery/features/components/examples/menubar/menubar.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/menubar/`.
const menubarExamples = <GalleryExample>[
  GalleryExample(
    title: 'Application menu',
    description: 'The shadcn demo on a strip of paper: File with a sub-menu and keycaps, Edit, View with ticked rows, Profiles with a radio group. Hover another title while one is open and the menu follows.',
    height: 360,
    source: 'menubar/menubar_app_menu_example.dart',
    builder: MenubarAppMenuExample.new,
  ),
  GalleryExample(
    title: 'Format menu that acts',
    description: 'Controlled rows change the page under the bar: bold and italic are ticked rows, the paper is a radio group. Every state lives in your component; the menus just report it.',
    stage: ExampleStage.desk,
    height: 420,
    source: 'menubar/menubar_editor_example.dart',
    builder: MenubarEditorExample.new,
  ),
  GalleryExample(
    title: 'App header (composed)',
    description: 'A real use: the bar sits in an app header beside the title and an account button. Choosing a row reports what happened, and the bar stays one tab stop for keyboard users.',
    stage: ExampleStage.desk,
    height: 340,
    source: 'menubar/menubar_header_example.dart',
    builder: MenubarHeaderExample.new,
  ),
  GalleryExample(
    title: 'Browser menu (as written)',
    description: 'shadcn\'s menubar-demo, line for line: File, Edit, View and Profiles, with shortcuts, sub-menus, two ticked rows, an inset column and a radio group. Its checkboxes and radio are fixed (value: true, value: \'benoit\' with no handler), so they show the states without changing; the first example lets them change.',
    height: 420,
    source: 'menubar/menubar_demo_example.dart',
    builder: MenubarDemoExample.new,
  ),
];
