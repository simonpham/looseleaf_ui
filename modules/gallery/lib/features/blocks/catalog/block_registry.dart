import 'package:gallery/features/blocks/blocks/blocks.dart';
import 'package:gallery/features/blocks/models/models.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Every ported block, by upstream slug. A block gets a page once it has an
/// entry here.
const Map<String, GalleryBlock> portedBlocks = {
  'announcement-bar': GalleryBlock(
    source: 'blocks/announcement_bar/announcement_bar_block.dart',
    builder: AnnouncementBarBlock.new,
  ),
  'cta-01': GalleryBlock(
    source: 'blocks/cta_01/cta_01_block.dart',
    builder: Cta01Block.new,
    objects: [DeskObject.clips],
  ),
  'empty-inbox': GalleryBlock(
    source: 'blocks/empty_inbox/empty_inbox_block.dart',
    builder: EmptyInboxBlock.new,
  ),
  'faq-01': GalleryBlock(
    source: 'blocks/faq_01/faq_01_block.dart',
    builder: Faq01Block.new,
    objects: [DeskObject.pencil],
  ),
  'footer-01': GalleryBlock(
    source: 'blocks/footer_01/footer_01_block.dart',
    builder: Footer01Block.new,
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
  'login-04': GalleryBlock(
    source: 'blocks/login_04/login_04_block.dart',
    builder: Login04Block.new,
    objects: [DeskObject.ruler, DeskObject.clips],
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
  'settings-billing': GalleryBlock(
    source: 'blocks/settings_billing/settings_billing_block.dart',
    builder: SettingsBillingBlock.new,
  ),
  'sidebar-01': GalleryBlock(
    source: 'blocks/sidebar_01/sidebar_01_block.dart',
    builder: Sidebar01Block.new,
  ),
  'signup-01': GalleryBlock(
    source: 'blocks/signup_01/signup_01_block.dart',
    builder: Signup01Block.new,
  ),
  'signup-02': GalleryBlock(
    source: 'blocks/signup_02/signup_02_block.dart',
    builder: Signup02Block.new,
  ),
  'signup-03': GalleryBlock(
    source: 'blocks/signup_03/signup_03_block.dart',
    builder: Signup03Block.new,
    objects: [DeskObject.clips, DeskObject.pins],
  ),
  'testimonials-01': GalleryBlock(
    source: 'blocks/testimonials_01/testimonials_01_block.dart',
    builder: Testimonials01Block.new,
    objects: [DeskObject.pins],
  ),
};
