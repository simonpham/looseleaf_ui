import 'package:gallery/features/components/examples/sticker_board/sticker_board.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/sticker-board/`.
const stickerBoardExamples = <GalleryExample>[
  GalleryExample(
    title: 'Stick things down',
    description:
        'Drag a sticker anywhere. Pick one and a dashed frame appears with a ring to turn it by and a square to size it; the toolbar and the keyboard do the same.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    height: 560,
    source: 'sticker_board/sticker_board_default_example.dart',
    builder: StickerBoardDefaultExample.new,
  ),
  GalleryExample(
    title: 'The value is JSON',
    description:
        'The board keeps no secrets: every sticker is { id, name, x, y, rot, scale, z }. Store it, send it, restore it. StickerBoardOps.add puts a new one on top of the pile.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    height: 520,
    source: 'sticker_board/sticker_board_controlled_example.dart',
    builder: StickerBoardControlledExample.new,
  ),
  GalleryExample(
    title: 'A reward chart',
    description:
        'A read-only board is a display: the stickers a student has earned, lying where the teacher stuck them. No handles, no tab stops, no toolbar.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    height: 420,
    source: 'sticker_board/sticker_board_reward_chart_example.dart',
    builder: StickerBoardRewardChartExample.new,
  ),
  GalleryExample(
    title: 'Board and picker',
    description:
        'The picker chooses, StickerBoardOps.add sticks: the new sticker lands in the middle of the page, already picked, so it can be turned and sized straight away. Export hands you the whole page as one SVG.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    height: 640,
    source: 'sticker_board/sticker_board_with_a_picker_example.dart',
    builder: StickerBoardWithAPickerExample.new,
  ),
];
