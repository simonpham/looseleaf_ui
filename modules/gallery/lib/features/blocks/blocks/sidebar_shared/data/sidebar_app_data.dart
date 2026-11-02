/// A row of an app's navigation, with optional pages folded under it.
class AppNavItem {
  const AppNavItem(
    this.title, {
    required this.icon,
    this.isActive = false,
    this.badge,
    this.items = const [],
  });

  final String title;
  final String icon;

  /// Marks the current section.
  final bool isActive;

  /// A count at the end of the row.
  final String? badge;

  /// The pages under it.
  final List<String> items;
}

/// A team in the team switcher.
class Team {
  const Team(this.name, {required this.icon, required this.plan});

  final String name;
  final String icon;
  final String plan;
}

/// A project in the projects list.
class Project {
  const Project(this.name, {required this.icon});

  final String name;
  final String icon;
}

/// The signed-in person.
class Person {
  const Person({required this.name, required this.email});

  final String name;
  final String email;

  /// Up to two capitals from the name.
  String get initials {
    final letters = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0])
        .join();
    return letters.substring(0, letters.length.clamp(0, 2)).toUpperCase();
  }
}

const appUser = Person(name: 'Jo Delacroix', email: 'jo@looseleaf.example');

const appTeams = [
  Team('Looseleaf Studio', icon: 'book-open', plan: 'Notebook'),
  Team('Pen Pals Co.', icon: 'pencil', plan: 'Team'),
  Team('Attic Press', icon: 'bookmark', plan: 'Free'),
];

/// The studio's sections.
///
/// Mirrors `appNav` in upstream `src/blocks/sidebar-shared/sidebar-data.ts`.
const appNav = [
  AppNavItem(
    'Sketchbook',
    icon: 'pencil',
    isActive: true,
    items: ['Recent', 'Starred', 'Drafts'],
  ),
  AppNavItem(
    'Paper stocks',
    icon: 'file-text',
    items: ['Cream', 'Kraft', 'Graph', 'Ledger'],
  ),
  AppNavItem(
    'Field guide',
    icon: 'book-open',
    items: ['Introduction', 'Get started', 'Tutorials', 'Changelog'],
  ),
  AppNavItem(
    'Studio settings',
    icon: 'settings-2',
    items: ['General', 'Team', 'Billing', 'Limits'],
  ),
];

const appProjects = [
  Project('Spring catalog', icon: 'frame'),
  Project('Postcard club', icon: 'mail'),
  Project('Field trip', icon: 'map'),
];

const appSecondary = [
  AppNavItem('Support', icon: 'life-buoy'),
  AppNavItem('Feedback', icon: 'send'),
];
