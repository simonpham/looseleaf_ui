import 'package:gallery/features/blocks/blocks/sidebar_shared/data/data.dart';

/// A page of the notes app.
class NotesPage {
  const NotesPage(this.name, {required this.icon});

  final String name;
  final String icon;
}

/// A workspace and its pages.
class NotesWorkspace {
  const NotesWorkspace(this.name, {required this.icon, required this.pages});

  final String name;
  final String icon;
  final List<NotesPage> pages;
}

/// An action in the page's menu.
class PageAction {
  const PageAction(this.label, {required this.icon});

  final String label;
  final String icon;
}

const notesNav = [
  AppNavItem('Search', icon: 'search'),
  AppNavItem('Ask Stubby', icon: 'sparkles'),
  AppNavItem('Home', icon: 'house', isActive: true),
  AppNavItem('Inbox', icon: 'inbox', badge: '10'),
];

const notesSecondary = [
  AppNavItem('Calendar', icon: 'calendar'),
  AppNavItem('Settings', icon: 'settings-2'),
  AppNavItem('Templates', icon: 'layout-grid'),
  AppNavItem('Trash', icon: 'trash'),
  AppNavItem('Help', icon: 'life-buoy'),
];

const notesFavorites = [
  NotesPage('Project plan & to-dos', icon: 'chart-column'),
  NotesPage('Family recipe box', icon: 'heart'),
  NotesPage('Reading list', icon: 'book-open'),
  NotesPage('Garden diary', icon: 'sun'),
  NotesPage('Trip to Lisbon', icon: 'map'),
];

const notesWorkspaces = [
  NotesWorkspace(
    'Home life',
    icon: 'house',
    pages: [
      NotesPage('Daily journal', icon: 'pencil'),
      NotesPage('Health & wellness', icon: 'heart'),
      NotesPage('Things to learn', icon: 'lightbulb'),
    ],
  ),
  NotesWorkspace(
    'Work',
    icon: 'folder',
    pages: [
      NotesPage('Career milestones', icon: 'flag'),
      NotesPage('Training log', icon: 'timer'),
      NotesPage('People I met', icon: 'users'),
    ],
  ),
  NotesWorkspace(
    'Making things',
    icon: 'sparkles',
    pages: [
      NotesPage('Story outlines', icon: 'file-text'),
      NotesPage('Portfolio', icon: 'image'),
      NotesPage('Practice log', icon: 'music'),
    ],
  ),
];

/// The page menu's groups.
const pageActions = [
  [
    PageAction('Customize page', icon: 'settings-2'),
    PageAction('Turn into wiki', icon: 'file-text'),
  ],
  [
    PageAction('Copy link', icon: 'link'),
    PageAction('Duplicate', icon: 'copy'),
    PageAction('Move to', icon: 'arrow-right'),
    PageAction('Move to trash', icon: 'trash'),
  ],
  [
    PageAction('Undo', icon: 'undo-2'),
    PageAction('View analytics', icon: 'chart-line'),
    PageAction('Version history', icon: 'rotate-ccw-clock'),
    PageAction('Show delete pages', icon: 'eye'),
    PageAction('Notifications', icon: 'bell'),
  ],
  [
    PageAction('Import', icon: 'upload'),
    PageAction('Export', icon: 'download'),
  ],
];
