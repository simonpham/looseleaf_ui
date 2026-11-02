import 'package:gallery/features/components/examples/sticker_picker/sticker_picker.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/sticker-picker/`.
const stickerPickerExamples = <GalleryExample>[
  GalleryExample(
    title: 'A sticker for the job',
    description: 'Type to search, click a category, or walk the grid with the arrow keys. The highlighted sticker peels its corner; Enter sticks it.',
    height: 520,
    source: 'sticker_picker/sticker_picker_default_example.dart',
    builder: StickerPickerDefaultExample.new,
  ),
  GalleryExample(
    title: 'Your own set',
    description: 'Offer only the stickers you want, under your own names and words. Here a reaction picker: four to a row, it stays open so you can react more than once (choose one again to take it back), and the latest choice is marked.',
    height: 340,
    source: 'sticker_picker/sticker_picker_a_small_set_example.dart',
    builder: StickerPickerASmallSetExample.new,
  ),
  GalleryExample(
    title: 'In a comment box',
    description: 'The picker as a composer tool: choose a sticker, it waits beside the text (click it to take it off), and posting sends both. Recent stickers come first next time.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    height: 640,
    source: 'sticker_picker/sticker_picker_comment_composer_example.dart',
    builder: StickerPickerCommentComposerExample.new,
  ),
];
