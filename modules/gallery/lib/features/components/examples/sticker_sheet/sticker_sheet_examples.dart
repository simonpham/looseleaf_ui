import 'package:gallery/features/components/examples/sticker_sheet/sticker_sheet.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/sticker-sheet/`.
const stickerSheetExamples = <GalleryExample>[
  GalleryExample(
    title: 'A sheet to peel',
    description:
        'Press a sticker (or Enter) and it lifts off, leaving its kiss-cut outline behind. Press the outline to stick it back. Hover one and its corner curls.',
    stage: ExampleStage.desk,
    source: 'sticker_sheet/sticker_sheet_peel_example.dart',
    builder: StickerSheetPeelExample.new,
  ),
  GalleryExample(
    title: 'Backing paper and size',
    description:
        'The backing is release paper with a sheen (glassine, the default), kraft or plain paper. Columns and size set the grid; shorthand `stickers` skips the items when you do not need labels or ids.',
    stage: ExampleStage.desk,
    source: 'sticker_sheet/sticker_sheet_backings_example.dart',
    builder: StickerSheetBackingsExample.new,
  ),
  GalleryExample(
    title: 'Sheet to board',
    description:
        'Peel a sticker off the sheet (click it, or drag it with a mouse and let go over the board) and it lands on the board. Let go anywhere else and it springs back. Delete it on the board and it returns to its outline on the sheet.',
    layout: ExampleLayout.full,
    stage: ExampleStage.desk,
    height: 640,
    source: 'sticker_sheet/sticker_sheet_to_board_example.dart',
    builder: StickerSheetToBoardExample.new,
  ),
];
