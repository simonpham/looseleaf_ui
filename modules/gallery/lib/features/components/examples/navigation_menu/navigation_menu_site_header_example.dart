import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-3xl`.
const _maxWidth = 768.0;

/// `w-60`.
const _panelWidth = Spacing.d240;

const _products = [
  ('Notebooks', 'Write things down.'),
  ('Stickers', 'Mark them up.'),
  ('Templates', 'Start from a page.'),
];

class NavigationMenuSiteHeaderExample extends StatelessWidget {
  const NavigationMenuSiteHeaderExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Paper(
          seed: 'header',
          padding: const EdgeInsets.fromLTRB(
            Spacing.d20,
            Spacing.d12,
            Spacing.d20,
            Spacing.d16,
          ),
          child: Wrap(
            spacing: Spacing.d16,
            runSpacing: Spacing.d8,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d8,
                children: [
                  const InkIcon('book-open', size: Spacing.d22),
                  Text(
                    'Looseleaf',
                    style: theme.typography.face(
                      KevinSansFace.script,
                      cssSize: 24,
                      cssLineHeight: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              NavigationMenu(
                semanticLabel: 'Main',
                child: NavigationMenuList(
                  children: [
                    NavigationMenuItem(
                      content: NavigationMenuContent(
                        width: _panelWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: Spacing.d4,
                          children: [
                            for (final (title, text) in _products)
                              NavigationMenuLink(
                                onPressed: () {},
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      text,
                                      style: theme.typography.interface(
                                        cssSize: 14,
                                        color: theme.colors.inkMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      child: const NavigationMenuTrigger(
                        seed: 'h1',
                        child: Text('Product'),
                      ),
                    ),
                    NavigationMenuItem(
                      child: NavigationMenuLink(
                        seed: 'h2',
                        onPressed: () {},
                        child: const Text('Pricing'),
                      ),
                    ),
                    NavigationMenuItem(
                      child: NavigationMenuLink(
                        seed: 'h3',
                        active: true,
                        onPressed: () {},
                        child: const Text('Blog'),
                      ),
                    ),
                    const NavigationMenuIndicator(),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d8,
                children: [
                  Button(
                    variant: ButtonVariant.ghost,
                    size: ButtonSize.sm,
                    onPressed: () {},
                    child: const Text('Sign in'),
                  ),
                  Button(
                    size: ButtonSize.sm,
                    onPressed: () {},
                    child: const Text('Get started'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
