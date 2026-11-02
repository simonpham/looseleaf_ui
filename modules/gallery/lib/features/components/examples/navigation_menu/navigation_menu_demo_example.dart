import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `useIsMobile()`.
const _mobileBelow = 768.0;

/// The room all six tabs need; with less the last three hide (`hidden md:block`).
const _allItemsWidth = 820.0;

/// `lg:w-[500px]`.
const _homeWidth = 500.0;

/// `md:w-[500px]`.
const _componentsWidth = 500.0;

/// `w-[300px]`.
const _listWidth = 300.0;

/// `w-[200px]`.
const _simpleWidth = Spacing.d200;

const _components = [
  (
    title: 'Alert Dialog',
    description:
        'A modal dialog that interrupts the user with important content and '
        'expects a response.',
  ),
  (
    title: 'Hover Card',
    description:
        'For sighted users to preview content available behind a link.',
  ),
  (
    title: 'Progress',
    description:
        'Displays an indicator showing the completion progress of a task, '
        'typically displayed as a progress bar.',
  ),
  (
    title: 'Scroll-area',
    description: 'Visually or semantically separates content.',
  ),
  (
    title: 'Tabs',
    description:
        'A set of layered sections of content—known as tab panels—that are '
        'displayed one at a time.',
  ),
  (
    title: 'Tooltip',
    description:
        'A popup that displays information related to an element when the '
        'element receives keyboard focus or the mouse hovers over it.',
  ),
];

class NavigationMenuDemoExample extends StatelessWidget {
  const NavigationMenuDemoExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final muted = TextStyle(color: theme.colors.inkMuted);
    const medium = TextStyle(fontWeight: FontWeight.w500);
    final isMobile = MediaQuery.sizeOf(context).width < _mobileBelow;
    return LayoutBuilder(
      builder: (context, constraints) => NavigationMenu(
        viewport: isMobile,
        semanticLabel: 'Main',
        child: NavigationMenuList(
          children: [
            NavigationMenuItem(
              content: NavigationMenuContent(
                width: _homeWidth,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: Spacing.d8,
                    children: [
                      Expanded(
                        flex: 3,
                        child: NavigationMenuLink(
                          onPressed: () {},
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  theme.colors.paperShade.withValues(
                                    alpha: 0.5,
                                  ),
                                  theme.colors.paperShade,
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(Spacing.d16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: Spacing.d8,
                                    ),
                                    child: Text(
                                      'Looseleaf',
                                      style: theme.typography.face(
                                        KevinSansFace.hand,
                                        cssSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Beautifully designed components built with '
                                    'Tailwind CSS.',
                                    style: theme.typography.face(
                                      KevinSansFace.hand,
                                      cssSize: 14,
                                      cssLineHeight: 1.25,
                                      color: theme.colors.inkMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Expanded(
                        flex: 4,
                        child: Column(
                          spacing: Spacing.d8,
                          children: [
                            _ListItem(
                              title: 'Introduction',
                              text:
                                  'Re-usable components built using Radix UI and '
                                  'Tailwind CSS.',
                            ),
                            _ListItem(
                              title: 'Installation',
                              text:
                                  'How to install dependencies and structure '
                                  'your app.',
                            ),
                            _ListItem(
                              title: 'Typography',
                              text: 'Styles for headings, paragraphs, lists...etc',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              child: const NavigationMenuTrigger(child: Text('Home')),
            ),
            NavigationMenuItem(
              content: NavigationMenuContent(
                width: _componentsWidth,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cellWidth = (constraints.maxWidth - Spacing.d8) / 2;
                    return Wrap(
                      spacing: Spacing.d8,
                      runSpacing: Spacing.d8,
                      children: [
                        for (final component in _components)
                          SizedBox(
                            width: cellWidth,
                            child: _ListItem(
                              title: component.title,
                              text: component.description,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              child: const NavigationMenuTrigger(child: Text('Components')),
            ),
            NavigationMenuItem(
              child: NavigationMenuLink(
                onPressed: () {},
                child: const Text('Docs'),
              ),
            ),
            if (constraints.maxWidth >= _allItemsWidth) ...[
              NavigationMenuItem(
                content: NavigationMenuContent(
                  width: _listWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (title, text) in const [
                        ('Components', 'Browse all components in the library.'),
                        ('Documentation', 'Learn how to use the library.'),
                        ('Blog', 'Read our latest blog posts.'),
                      ])
                        NavigationMenuLink(
                          onPressed: () {},
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: medium),
                              Text(text, style: muted),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                child: const NavigationMenuTrigger(child: Text('List')),
              ),
              NavigationMenuItem(
                content: NavigationMenuContent(
                  width: _simpleWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final label in const [
                        'Components',
                        'Documentation',
                        'Blocks',
                      ])
                        NavigationMenuLink(
                          onPressed: () {},
                          child: Text(label),
                        ),
                    ],
                  ),
                ),
                child: const NavigationMenuTrigger(child: Text('Simple')),
              ),
              NavigationMenuItem(
                content: NavigationMenuContent(
                  width: _simpleWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (icon, label) in const [
                        ('circle-question-mark', 'Backlog'),
                        ('circle', 'To Do'),
                        ('circle-check', 'Done'),
                      ])
                        NavigationMenuLink(
                          onPressed: () {},
                          child: Row(
                            spacing: Spacing.d8,
                            children: [InkIcon(icon), Text(label)],
                          ),
                        ),
                    ],
                  ),
                ),
                child: const NavigationMenuTrigger(child: Text('With Icon')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  const _ListItem({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return NavigationMenuLink(
      onPressed: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.typography.face(
              KevinSansFace.hand,
              cssSize: 14,
              cssLineHeight: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.face(
              KevinSansFace.hand,
              cssSize: 14,
              cssLineHeight: 1.375,
              color: theme.colors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
