/// The table of contents in the `sidebar-menu-sub` and
/// `sidebar-menu-collapsible` examples.
const sidebarDocsToc = [
  (
    title: 'Getting Started',
    items: ['Installation', 'Project Structure'],
  ),
  (
    title: 'Build Your Application',
    items: [
      'Routing',
      'Data Fetching',
      'Rendering',
      'Caching',
      'Styling',
      'Optimizing',
      'Configuring',
      'Testing',
      'Authentication',
      'Deploying',
      'Upgrading',
      'Examples',
    ],
  ),
  (
    title: 'API Reference',
    items: [
      'Components',
      'File Conventions',
      'Functions',
      'next.config.js Options',
      'CLI',
      'Edge Runtime',
    ],
  ),
  (
    title: 'Architecture',
    items: [
      'Accessibility',
      'Fast Refresh',
      'Next.js Compiler',
      'Supported Browsers',
      'Turbopack',
    ],
  ),
];

/// The page the table of contents marks as current.
const sidebarDocsActive = 'Data Fetching';
