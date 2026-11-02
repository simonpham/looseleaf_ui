import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class BreadcrumbRouterLinkExample extends StatefulWidget {
  const BreadcrumbRouterLinkExample({super.key});

  @override
  State<BreadcrumbRouterLinkExample> createState() =>
      _BreadcrumbRouterLinkExampleState();
}

class _BreadcrumbRouterLinkExampleState
    extends State<BreadcrumbRouterLinkExample> {
  static const _titles = {
    'docs': 'Docs',
    'components': 'Components',
    'breadcrumb': 'Breadcrumb',
    'button': 'Button',
    'card': 'Card',
    'calendar': 'Calendar',
  };
  static const _pages = ['Button', 'Card', 'Calendar'];

  String _path = '/docs/components/breadcrumb';

  void _navigate(String to) => setState(() => _path = to);

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final parts = _path.split('/').where((part) => part.isNotEmpty).toList();
    final trail = [
      (href: '/', title: 'Home'),
      for (final (i, part) in parts.indexed)
        (
          href: '/${parts.sublist(0, i + 1).join('/')}',
          title: _titles[part] ?? part,
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d20,
      children: [
        Breadcrumb(
          child: BreadcrumbList(
            children: [
              for (final (i, crumb) in trail.indexed) ...[
                BreadcrumbItem(
                  children: [
                    switch (i == trail.length - 1) {
                      true => BreadcrumbPage(
                        seed: crumb.href,
                        child: Text(crumb.title),
                      ),
                      false => BreadcrumbLink(
                        onPressed: () => _navigate(crumb.href),
                        child: Text(crumb.title),
                      ),
                    },
                  ],
                ),
                if (i < trail.length - 1) const BreadcrumbSeparator(),
              ],
            ],
          ),
        ),
        Wrap(
          spacing: Spacing.d16,
          runSpacing: Spacing.d16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final page in _pages)
              Button(
                size: ButtonSize.sm,
                variant: ButtonVariant.outline,
                onPressed: () =>
                    _navigate('/docs/components/${page.toLowerCase()}'),
                child: Text('Open $page'),
              ),
          ],
        ),
        Semantics(
          liveRegion: true,
          child: Text(
            'path: $_path',
            style: theme.typography.mono(
              cssSize: 14,
              color: theme.colors.inkMuted,
            ),
          ),
        ),
      ],
    );
  }
}
