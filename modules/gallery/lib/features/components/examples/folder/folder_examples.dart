import 'package:gallery/features/components/examples/folder/folder.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/folder/`.
const folderExamples = <GalleryExample>[
  GalleryExample(
    title: 'A folder with tabs',
    description:
        "The front tab is the folder's color and runs into the body; the others stand behind it. Arrow keys move between tabs; Home and End jump.",
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'folder/folder_default_example.dart',
    builder: FolderDefaultExample.new,
  ),
  GalleryExample(
    title: 'Manila, yellow, white',
    description:
        'The folder is whatever its stock is: manila, a legal-pad yellow or white card. A folder with one tab is just a labeled folder.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'folder/folder_stocks_example.dart',
    builder: FolderStocksExample.new,
  ),
  GalleryExample(
    title: 'Controlled',
    description:
        'The open tab is your state: `value` and `onValueChange`, as on Tabs. Here a button jumps to the next one.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'folder/folder_controlled_example.dart',
    builder: FolderControlledExample.new,
  ),
  GalleryExample(
    title: 'Project files',
    description:
        'A real page: a project\'s tasks, notes and files as tabs on one folder, with a form inside the open panel. Each panel is an ordinary widget; only the open one is built.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    height: 420,
    source: 'folder/folder_project_files_example.dart',
    builder: FolderProjectFilesExample.new,
  ),
];
