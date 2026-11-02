import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `w-48`.
const _panelWidth = 192.0;

const _items = [
  ('Product', ['Notebooks', 'Stickers', 'Templates']),
  ('Company', ['About', 'Blog', 'Careers']),
];

class NavigationMenuNoViewportExample extends StatelessWidget {
  const NavigationMenuNoViewportExample({super.key});

  @override
  Widget build(BuildContext context) => NavigationMenu(
    viewport: false,
    semanticLabel: 'Company',
    child: NavigationMenuList(
      children: [
        for (final (label, links) in _items)
          NavigationMenuItem(
            content: NavigationMenuContent(
              width: _panelWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d4,
                children: [
                  for (final link in links)
                    NavigationMenuLink(
                      onPressed: () {},
                      child: Row(
                        spacing: Spacing.d8,
                        children: [
                          const InkIcon('chevron-right'),
                          Text(link),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            child: NavigationMenuTrigger(seed: label, child: Text(label)),
          ),
      ],
    ),
  );
}
