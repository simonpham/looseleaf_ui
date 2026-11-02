import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `lg:w-[500px]`.
const _gettingStartedWidth = 500.0;

/// `md:w-[500px]`.
const _componentsWidth = 500.0;

const _components = [
  (
    'Alert Dialog',
    'A modal dialog that interrupts the user with important content.',
  ),
  (
    'Hover Card',
    'For sighted users to preview content available behind a link.',
  ),
  (
    'Progress',
    'Displays an indicator showing the completion progress of a task.',
  ),
  ('Scroll Area', 'Visually or semantically separates content.'),
  ('Tabs', 'A set of layered sections of content, one displayed at a time.'),
  ('Tooltip', 'A popup that displays information related to an element.'),
];

class NavigationMenuGettingStartedExample extends StatelessWidget {
  const NavigationMenuGettingStartedExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Align(
      alignment: Alignment.topCenter,
      child: NavigationMenu(
        semanticLabel: 'Main',
        child: NavigationMenuList(
          children: [
            NavigationMenuItem(
              content: NavigationMenuContent(
                width: _gettingStartedWidth,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: Spacing.d8,
                    children: [
                      Expanded(
                        flex: 3,
                        child: NavigationMenuLink(
                          onPressed: () {},
                          child: Paper(
                            stock: StockName.card,
                            tilt: false,
                            shadow: PaperShadow.loose,
                            padding: const EdgeInsets.all(Spacing.d16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: Spacing.d4,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(bottom: Spacing.d8),
                                  child: Mascot(
                                    pose: 'wave',
                                    size: Spacing.d64,
                                  ),
                                ),
                                Text(
                                  'Looseleaf',
                                  style: theme.typography.face(
                                    KevinSansFace.script,
                                    cssSize: 24,
                                    cssLineHeight: 1,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Beautifully designed components, drawn by '
                                  'hand.',
                                  style: theme.typography.interface(
                                    cssSize: 14,
                                    color: theme.colors.inkMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Expanded(
                        flex: 4,
                        child: Column(
                          spacing: Spacing.d8,
                          children: [
                            _Row(
                              title: 'Introduction',
                              text:
                                  'Re-usable components built with Radix UI '
                                  'and Tailwind CSS.',
                            ),
                            _Row(
                              title: 'Installation',
                              text:
                                  'How to install dependencies and structure '
                                  'your app.',
                            ),
                            _Row(
                              title: 'Typography',
                              text:
                                  'Styles for headings, paragraphs, lists and '
                                  'more.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              child: const NavigationMenuTrigger(
                seed: 'gs',
                child: Text('Getting started'),
              ),
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
                        for (final (title, text) in _components)
                          SizedBox(
                            width: cellWidth,
                            child: _Row(title: title, text: text),
                          ),
                      ],
                    );
                  },
                ),
              ),
              child: const NavigationMenuTrigger(
                seed: 'cm',
                child: Text('Components'),
              ),
            ),
            NavigationMenuItem(
              child: NavigationMenuLink(
                seed: 'docs',
                onPressed: () {},
                child: const Text('Docs'),
              ),
            ),
            const NavigationMenuIndicator(),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.title, required this.text});

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
            style: const TextStyle(fontWeight: FontWeight.w700),
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
