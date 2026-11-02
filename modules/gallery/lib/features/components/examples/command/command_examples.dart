import 'package:gallery/features/components/examples/command/command.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/command/`.
const commandExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description:
        'The shadcn demo on a slip. Type to cut the list down ("cal"), use the arrow keys, Enter to choose. The row you are on wears the highlighter; Calculator is disabled; the last three end in a keycap.',
    stage: ExampleStage.desk,
    height: 440,
    source: 'command/command_default_example.dart',
    builder: CommandDefaultExample.new,
  ),
  GalleryExample(
    title: 'In a dialog, on a napkin',
    description:
        'Press Ctrl + K (or Cmd + K) anywhere, or the button. The palette is set on a napkin with a pinked edge, over the dim; Escape puts it away and focus goes back to the button.',
    source: 'command/command_dialog_example.dart',
    builder: CommandDialogExample.new,
  ),
  GalleryExample(
    title: 'Empty and loading',
    description:
        'Results that come from a server: filtering is off (shouldFilter: false), the loops show while a search is on its way, and Stubby comes out with his magnifier when the answer is nothing. Try "inv", then "zzz".',
    stage: ExampleStage.desk,
    height: 330,
    source: 'command/command_empty_and_loading_example.dart',
    builder: CommandEmptyAndLoadingExample.new,
  ),
  GalleryExample(
    title: 'A status picker in a popover',
    description:
        'The classic use: a Command inside a Popover. The popover is the paper (the palette\'s own slip switches itself off), the chosen status gets a tick, and picking one closes the slip.',
    height: 380,
    source: 'command/command_status_picker_example.dart',
    builder: CommandStatusPickerExample.new,
  ),
];
