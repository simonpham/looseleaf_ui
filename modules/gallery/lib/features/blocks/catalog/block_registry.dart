import 'package:gallery/features/blocks/blocks/blocks.dart';
import 'package:gallery/features/blocks/models/models.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Every ported block, by upstream slug. A block gets a page once it has an
/// entry here.
const Map<String, GalleryBlock> portedBlocks = {
  'cta-01': GalleryBlock(
    source: 'blocks/cta_01/cta_01_block.dart',
    builder: Cta01Block.new,
    objects: [DeskObject.clips],
  ),
  'empty-inbox': GalleryBlock(
    source: 'blocks/empty_inbox/empty_inbox_block.dart',
    builder: EmptyInboxBlock.new,
  ),
  'login-01': GalleryBlock(
    source: 'blocks/login_01/login_01_block.dart',
    builder: Login01Block.new,
  ),
};
