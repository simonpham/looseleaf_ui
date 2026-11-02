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
  'inbox': GalleryBlock(
    source: 'blocks/inbox/inbox_block.dart',
    builder: InboxBlock.new,
  ),
  'kanban-board': GalleryBlock(
    source: 'blocks/kanban_board/kanban_board_block.dart',
    builder: KanbanBoardBlock.new,
  ),
  'login-01': GalleryBlock(
    source: 'blocks/login_01/login_01_block.dart',
    builder: Login01Block.new,
  ),
  'login-02': GalleryBlock(
    source: 'blocks/login_02/login_02_block.dart',
    builder: Login02Block.new,
  ),
  'login-03': GalleryBlock(
    source: 'blocks/login_03/login_03_block.dart',
    builder: Login03Block.new,
    objects: [DeskObject.pencil],
  ),
  'logos-01': GalleryBlock(
    source: 'blocks/logos_01/logos_01_block.dart',
    builder: Logos01Block.new,
  ),
  'profile-page': GalleryBlock(
    source: 'blocks/profile_page/profile_page_block.dart',
    builder: ProfilePageBlock.new,
    objects: [DeskObject.clips, DeskObject.pencil],
  ),
  'settings-appearance': GalleryBlock(
    source: 'blocks/settings_appearance/settings_appearance_block.dart',
    builder: SettingsAppearanceBlock.new,
  ),
  'signup-01': GalleryBlock(
    source: 'blocks/signup_01/signup_01_block.dart',
    builder: Signup01Block.new,
  ),
};
