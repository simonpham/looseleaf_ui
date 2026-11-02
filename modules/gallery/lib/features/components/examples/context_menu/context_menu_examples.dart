import 'package:gallery/features/components/examples/context_menu/context_menu.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/context-menu/`.
const contextMenuExamples = <GalleryExample>[
  GalleryExample(
    title: 'Right-click anywhere',
    description:
        'The shadcn demo: back, forward and reload with keycaps, a sub-menu, ticked rows and a radio group. The slip opens where you clicked (or press the menu key on the focused note).',
    stage: ExampleStage.desk,
    height: 480,
    source: 'context_menu/context_menu_page_example.dart',
    builder: ContextMenuPageExample.new,
  ),
  GalleryExample(
    title: 'On a list row',
    description:
        'Each row is its own ContextMenu, so the menu knows which row you clicked. The chosen row is remembered below the list; rows are focusable, so the menu key works from the keyboard.',
    stage: ExampleStage.desk,
    height: 420,
    source: 'context_menu/context_menu_file_list_example.dart',
    builder: ContextMenuFileListExample.new,
  ),
  GalleryExample(
    title: 'Pen picker on a sticky note',
    description:
        'A composed use: right-click a sticky note to choose the pen it is written with. The menu is a second sticky, in another color so it reads as its own note, taped down; the radio rows tick the choice.',
    stage: ExampleStage.desk,
    height: 400,
    source: 'context_menu/context_menu_canvas_tools_example.dart',
    builder: ContextMenuCanvasToolsExample.new,
  ),
];
