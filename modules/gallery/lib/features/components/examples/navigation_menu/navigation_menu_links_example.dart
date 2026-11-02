import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _pages = ['Overview', 'Notebooks', 'Stickers', 'Settings'];

class NavigationMenuLinksExample extends StatefulWidget {
  const NavigationMenuLinksExample({super.key});

  @override
  State<NavigationMenuLinksExample> createState() =>
      _NavigationMenuLinksExampleState();
}

class _NavigationMenuLinksExampleState
    extends State<NavigationMenuLinksExample> {
  String _page = 'Notebooks';

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d16,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: NavigationMenu(
            semanticLabel: 'Sections',
            child: NavigationMenuList(
              children: [
                for (final page in _pages)
                  NavigationMenuItem(
                    child: NavigationMenuLink(
                      active: _page == page,
                      seed: page,
                      onPressed: () => setState(() => _page = page),
                      child: Text(page),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Semantics(
          liveRegion: true,
          child: Text(
            'You are on $_page.',
            style: theme.typography.interface(
              cssSize: 14,
              color: theme.colors.inkMuted,
            ),
          ),
        ),
      ],
    );
  }
}
