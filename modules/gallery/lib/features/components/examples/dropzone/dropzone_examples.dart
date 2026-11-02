import 'package:gallery/features/components/examples/dropzone/dropzone.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/dropzone/`.
const dropzoneExamples = <GalleryExample>[
  GalleryExample(
    title: 'Drop or browse',
    description: 'Tap it, or Tab and press Enter, to browse (Stubby comes out with a sheet of paper while files are dragged over). Here a stand-in picker hands over a sample file each time: one is not an image, one is bigger than 2 MB, and a fifth file is one too many, so the reason appears in red.',
    height: 480,
    source: 'dropzone/dropzone_drop_or_browse_example.dart',
    builder: DropzoneDropOrBrowseExample.new,
  ),
  GalleryExample(
    title: 'Attach files, with progress',
    description: 'No upload is built in: you drive each row from your own request. Here a timer stands in for the network: rows fill their highlighter line, finish with a green tick, and one file is made to fail so you can see the red rule and its wavy line.',
    stage: ExampleStage.desk,
    height: 640,
    source: 'dropzone/dropzone_attach_with_progress_example.dart',
    builder: DropzoneAttachWithProgressExample.new,
  ),
  GalleryExample(
    title: 'One file: a profile picture',
    description: 'multiple: false keeps one file, and a new one replaces the old. A narrow zone whose own content follows the state through Dropzone.of (here: the chosen picture as a photo print).',
    stage: ExampleStage.desk,
    height: 380,
    source: 'dropzone/dropzone_avatar_example.dart',
    builder: DropzoneAvatarExample.new,
  ),
  GalleryExample(
    title: 'Required, in a form',
    description: 'The zone is a plain form field: the form checks it on submit, and invalid draws the red stitches. Submit empty, then with a file.',
    stage: ExampleStage.desk,
    height: 600,
    source: 'dropzone/dropzone_required_in_a_form_example.dart',
    builder: DropzoneRequiredInAFormExample.new,
  ),
];
