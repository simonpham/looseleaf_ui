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
  'chat-app': GalleryBlock(
    source: 'blocks/chat_app/chat_app_block.dart',
    builder: ChatAppBlock.new,
    objects: [DeskObject.pencil],
  ),
  'checkout-01': GalleryBlock(
    source: 'blocks/checkout_01/checkout_01_block.dart',
    builder: Checkout01Block.new,
    objects: [DeskObject.pins],
  ),
  'cta-01': GalleryBlock(
    source: 'blocks/cta_01/cta_01_block.dart',
    builder: Cta01Block.new,
    objects: [DeskObject.clips],
  ),
  'dashboard-analytics': GalleryBlock(
    source: 'blocks/dashboard_analytics/dashboard_analytics_block.dart',
    builder: DashboardAnalyticsBlock.new,
  ),
  'empty-inbox': GalleryBlock(
    source: 'blocks/empty_inbox/empty_inbox_block.dart',
    builder: EmptyInboxBlock.new,
  ),
  'error-404': GalleryBlock(
    source: 'blocks/error_404/error_404_block.dart',
    builder: Error404Block.new,
  ),
  'faq-01': GalleryBlock(
    source: 'blocks/faq_01/faq_01_block.dart',
    builder: Faq01Block.new,
    objects: [DeskObject.pencil],
  ),
  'file-explorer': GalleryBlock(
    source: 'blocks/file_explorer/file_explorer_block.dart',
    builder: FileExplorerBlock.new,
  ),
  'footer-01': GalleryBlock(
    source: 'blocks/footer_01/footer_01_block.dart',
    builder: Footer01Block.new,
  ),
  'forgot-password-01': GalleryBlock(
    source: 'blocks/forgot_password_01/forgot_password_01_block.dart',
    builder: ForgotPassword01Block.new,
  ),
  'inbox': GalleryBlock(
    source: 'blocks/inbox/inbox_block.dart',
    builder: InboxBlock.new,
  ),
  'kanban-board': GalleryBlock(
    source: 'blocks/kanban_board/kanban_board_block.dart',
    builder: KanbanBoardBlock.new,
  ),
  'landing-hero-01': GalleryBlock(
    source: 'blocks/landing_hero_01/landing_hero_01_block.dart',
    builder: LandingHero01Block.new,
    objects: [DeskObject.pencil],
  ),
  'landing-hero-02': GalleryBlock(
    source: 'blocks/landing_hero_02/landing_hero_02_block.dart',
    builder: LandingHero02Block.new,
    objects: [DeskObject.pencil, DeskObject.clips],
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
  'login-05': GalleryBlock(
    source: 'blocks/login_05/login_05_block.dart',
    builder: Login05Block.new,
  ),
  'logos-01': GalleryBlock(
    source: 'blocks/logos_01/logos_01_block.dart',
    builder: Logos01Block.new,
  ),
  'newsletter-01': GalleryBlock(
    source: 'blocks/newsletter_01/newsletter_01_block.dart',
    builder: Newsletter01Block.new,
  ),
  'notes-app': GalleryBlock(
    source: 'blocks/notes_app/notes_app_block.dart',
    builder: NotesAppBlock.new,
    objects: [DeskObject.pencil],
  ),
  'onboarding-01': GalleryBlock(
    source: 'blocks/onboarding_01/onboarding_01_block.dart',
    builder: Onboarding01Block.new,
    objects: [DeskObject.pencil],
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
  'settings-notifications': GalleryBlock(
    source: 'blocks/settings_notifications/settings_notifications_block.dart',
    builder: SettingsNotificationsBlock.new,
  ),
  'settings-profile': GalleryBlock(
    source: 'blocks/settings_profile/settings_profile_block.dart',
    builder: SettingsProfileBlock.new,
  ),
  'sidebar-01': GalleryBlock(
    source: 'blocks/sidebar_01/sidebar_01_block.dart',
    builder: Sidebar01Block.new,
  ),
  'sidebar-02': GalleryBlock(
    source: 'blocks/sidebar_02/sidebar_02_block.dart',
    builder: Sidebar02Block.new,
  ),
  'sidebar-03': GalleryBlock(
    source: 'blocks/sidebar_03/sidebar_03_block.dart',
    builder: Sidebar03Block.new,
  ),
  'sidebar-04': GalleryBlock(
    source: 'blocks/sidebar_04/sidebar_04_block.dart',
    builder: Sidebar04Block.new,
  ),
  'sidebar-05': GalleryBlock(
    source: 'blocks/sidebar_05/sidebar_05_block.dart',
    builder: Sidebar05Block.new,
  ),
  'sidebar-06': GalleryBlock(
    source: 'blocks/sidebar_06/sidebar_06_block.dart',
    builder: Sidebar06Block.new,
  ),
  'sidebar-07': GalleryBlock(
    source: 'blocks/sidebar_07/sidebar_07_block.dart',
    builder: Sidebar07Block.new,
  ),
  'sidebar-08': GalleryBlock(
    source: 'blocks/sidebar_08/sidebar_08_block.dart',
    builder: Sidebar08Block.new,
  ),
  'sidebar-09': GalleryBlock(
    source: 'blocks/sidebar_09/sidebar_09_block.dart',
    builder: Sidebar09Block.new,
  ),
  'sidebar-10': GalleryBlock(
    source: 'blocks/sidebar_10/sidebar_10_block.dart',
    builder: Sidebar10Block.new,
  ),
  'sidebar-11': GalleryBlock(
    source: 'blocks/sidebar_11/sidebar_11_block.dart',
    builder: Sidebar11Block.new,
  ),
  'sidebar-12': GalleryBlock(
    source: 'blocks/sidebar_12/sidebar_12_block.dart',
    builder: Sidebar12Block.new,
  ),
  'sidebar-13': GalleryBlock(
    source: 'blocks/sidebar_13/sidebar_13_block.dart',
    builder: Sidebar13Block.new,
  ),
  'sidebar-14': GalleryBlock(
    source: 'blocks/sidebar_14/sidebar_14_block.dart',
    builder: Sidebar14Block.new,
  ),
  'sidebar-15': GalleryBlock(
    source: 'blocks/sidebar_15/sidebar_15_block.dart',
    builder: Sidebar15Block.new,
  ),
  'sidebar-16': GalleryBlock(
    source: 'blocks/sidebar_16/sidebar_16_block.dart',
    builder: Sidebar16Block.new,
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
  'signup-04': GalleryBlock(
    source: 'blocks/signup_04/signup_04_block.dart',
    builder: Signup04Block.new,
    objects: [DeskObject.pencil],
  ),
  'signup-05': GalleryBlock(
    source: 'blocks/signup_05/signup_05_block.dart',
    builder: Signup05Block.new,
  ),
  'testimonials-01': GalleryBlock(
    source: 'blocks/testimonials_01/testimonials_01_block.dart',
    builder: Testimonials01Block.new,
    objects: [DeskObject.pins],
  ),
};
