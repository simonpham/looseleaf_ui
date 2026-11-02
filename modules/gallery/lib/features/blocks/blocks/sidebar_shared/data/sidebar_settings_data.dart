/// A setting that is on or off.
class SettingsToggle {
  const SettingsToggle(this.id, this.label, this.hint, {required this.on});

  final String id;
  final String label;
  final String hint;

  /// Its starting value.
  final bool on;
}

/// A page of settings.
class SettingsSection {
  const SettingsSection(
    this.name, {
    required this.icon,
    required this.intro,
    required this.toggles,
  });

  final String name;
  final String icon;
  final String intro;
  final List<SettingsToggle> toggles;
}

/// Mirrors `settingsSections` in upstream
/// `src/blocks/sidebar-shared/sidebar-data.ts`.
const settingsSections = [
  SettingsSection(
    'Notifications',
    icon: 'bell',
    intro: 'Decide what is worth a tap on the shoulder.',
    toggles: [
      SettingsToggle(
        'n-mentions',
        'Mentions',
        'When somebody writes your name in the margin.',
        on: true,
      ),
      SettingsToggle(
        'n-replies',
        'Replies',
        'When a thread you started gets an answer.',
        on: true,
      ),
      SettingsToggle(
        'n-digest',
        'Friday digest',
        'One postcard with the week in it.',
        on: false,
      ),
    ],
  ),
  SettingsSection(
    'Appearance',
    icon: 'sun',
    intro: 'How the notebook looks on your desk.',
    toggles: [
      SettingsToggle(
        'a-tilt',
        'Tilt the paper',
        'Sheets sit at a slight angle. Text never does.',
        on: true,
      ),
      SettingsToggle(
        'a-grain',
        'Paper grain',
        'Turn off for a flatter, calmer page.',
        on: true,
      ),
      SettingsToggle(
        'a-motion',
        'Reduce motion',
        'No swishing pages or drawn-on lines.',
        on: false,
      ),
    ],
  ),
  SettingsSection(
    'Messages & media',
    icon: 'message-circle',
    intro: 'What arrives with a message, and what does not.',
    toggles: [
      SettingsToggle(
        'm-previews',
        'Link previews',
        'Show a small card under links.',
        on: true,
      ),
      SettingsToggle(
        'm-autoplay',
        'Play stickers',
        'Let animated stickers move.',
        on: false,
      ),
      SettingsToggle(
        'm-images',
        'Show images inline',
        'Otherwise they arrive as a paperclip.',
        on: true,
      ),
    ],
  ),
  SettingsSection(
    'Language & region',
    icon: 'globe',
    intro: 'Words, dates and which way the page reads.',
    toggles: [
      SettingsToggle(
        'l-24h',
        '24-hour clock',
        'Show 17:30 instead of 5:30 pm.',
        on: false,
      ),
      SettingsToggle(
        'l-week',
        'Weeks start on Monday',
        'Your calendars follow along.',
        on: true,
      ),
      SettingsToggle(
        'l-rtl',
        'Write right to left',
        'Mirror the notebook for Arabic and Hebrew.',
        on: false,
      ),
    ],
  ),
  SettingsSection(
    'Accessibility',
    icon: 'command',
    intro: 'Make it easy on your eyes and your hands.',
    toggles: [
      SettingsToggle(
        'x-contrast',
        'Heavier pens',
        'Thicker lines and darker ink.',
        on: false,
      ),
      SettingsToggle(
        'x-focus',
        'Always show focus',
        'Draw a ring on whatever the keyboard is on.',
        on: true,
      ),
      SettingsToggle(
        'x-keys',
        'Single-key shortcuts',
        'Press ? anywhere to see them.',
        on: true,
      ),
    ],
  ),
  SettingsSection(
    'Privacy & visibility',
    icon: 'lock',
    intro: 'Who can read over your shoulder.',
    toggles: [
      SettingsToggle(
        'p-online',
        'Show when I am online',
        'A small dot next to your name.',
        on: true,
      ),
      SettingsToggle(
        'p-read',
        'Read receipts',
        'Let people know you saw their note.',
        on: false,
      ),
      SettingsToggle(
        'p-index',
        'Appear in search',
        'Let teammates find you by name.',
        on: true,
      ),
    ],
  ),
];
