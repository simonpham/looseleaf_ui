/// A page in a docs section.
class NavLink {
  const NavLink(this.title, {this.isActive = false});

  final String title;

  /// Marks the page being read.
  final bool isActive;
}

/// A docs section and its pages.
class NavSection {
  const NavSection(this.title, this.items);

  final String title;
  final List<NavLink> items;
}

/// The field guide's editions, oldest first.
const docsVersions = ['1.0.1', '1.1.0-alpha', '2.0.0-beta1'];

/// The field guide's sections.
///
/// Mirrors `docsNav` in upstream `src/blocks/sidebar-shared/sidebar-data.ts`.
const docsNav = [
  NavSection('Getting started', [
    NavLink('Welcome'),
    NavLink('Sharpen your first pencil'),
  ]),
  NavSection('Writing on paper', [
    NavLink('Pens & pencils'),
    NavLink('Paper stocks'),
    NavLink('Margins', isActive: true),
    NavLink('Sticky notes'),
    NavLink('Tape & pins'),
    NavLink('Stamps'),
    NavLink('Doodles'),
    NavLink('Highlighting'),
    NavLink('Erasing'),
    NavLink('Printing'),
    NavLink('Sharing'),
    NavLink('Archiving'),
  ]),
  NavSection('Pen reference', [
    NavLink('Felt tip'),
    NavLink('Fineliner'),
    NavLink('Graphite'),
    NavLink('Highlighter'),
    NavLink('Brush pen'),
    NavLink('Chalk'),
  ]),
  NavSection('Behind the scenes', [
    NavLink('How lines wobble'),
    NavLink('Reading order'),
    NavLink('Density'),
    NavLink('Keyboard'),
  ]),
  NavSection('Pen pals', [NavLink('How to contribute')]),
];

/// The trail to the page being read.
const docsTrail = ['Writing on paper', 'Margins'];

/// The headings of the page being read.
const pageOutline = [
  NavSection('Why margins', [
    NavLink('Room to think'),
    NavLink('Room to disagree'),
  ]),
  NavSection('Drawing a margin', [
    NavLink('The pencil rule', isActive: true),
    NavLink('Wide, narrow, none'),
    NavLink('Left-handers and right-to-left'),
  ]),
  NavSection('Notes in the margin', [
    NavLink('Stars and asterisks'),
    NavLink('Arrows that point somewhere'),
  ]),
  NavSection('Going further', [NavLink('Sticky notes')]),
];
