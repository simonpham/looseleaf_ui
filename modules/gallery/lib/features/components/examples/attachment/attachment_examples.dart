import 'package:gallery/features/components/examples/attachment/attachment.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/attachment/`.
const attachmentExamples = <GalleryExample>[
  GalleryExample(
    title: 'The five states',
    description: 'Done (a clipped slip), uploading (a pencil bar), processing (the same bar, pulsing), error (red pencil and a retry) and idle (a dashed slot waiting for a file).',
    layout: ExampleLayout.stack,
    source: 'attachment/attachment_states_example.dart',
    builder: AttachmentStatesExample.new,
  ),
  GalleryExample(
    title: 'A live upload',
    description: 'The hatched fill is drawn once and clipped to the value, so a fast upload never redraws anything. The finished slip gets its clip and becomes pressable.',
    layout: ExampleLayout.stack,
    source: 'attachment/attachment_uploading_example.dart',
    builder: AttachmentUploadingExample.new,
  ),
  GalleryExample(
    title: 'Prints on the wall',
    description: 'AttachmentOrientation.vertical is a photo with a white border, taped up. Put an image in the media; here a doodle stands in. A group scrolls sideways when its prints are wider than the box.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'attachment/attachment_prints_example.dart',
    builder: AttachmentPrintsExample.new,
  ),
];
