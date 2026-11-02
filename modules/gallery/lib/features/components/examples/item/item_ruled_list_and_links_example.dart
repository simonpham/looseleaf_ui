import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ItemRuledListAndLinksExample extends StatelessWidget {
  const ItemRuledListAndLinksExample({super.key});

  static const _maxWidth = Spacing.d448;
  static const _pages = [
    (
      icon: 'file',
      title: 'Quarterly pages',
      desc: 'Last opened on Tuesday, tidy.',
    ),
    (
      icon: 'folder',
      title: 'Receipts',
      desc: 'Forty-one of them, all crumpled.',
    ),
    (
      icon: 'calendar',
      title: 'Calendar',
      desc: 'Three things this week, one of them cake.',
    ),
  ];

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d32,
      children: [
        ItemGroup(
          ruled: true,
          children: [
            for (final page in _pages)
              InkItem(
                onPressed: () {},
                children: [
                  ItemMedia(
                    variant: ItemMediaVariant.icon,
                    child: InkIcon(page.icon),
                  ),
                  ItemContent(
                    children: [
                      ItemTitle(Text(page.title)),
                      ItemDescription(Text(page.desc)),
                    ],
                  ),
                  const InkIcon('chevron-right'),
                ],
              ),
          ],
        ),
        const ItemGroup(
          children: [
            InkItem(
              size: ItemSize.sm,
              children: [
                ItemContent(
                  children: [ItemTitle(Text('Before the separator'))],
                ),
              ],
            ),
            ItemSeparator(variant: SeparatorVariant.dashed),
            InkItem(
              size: ItemSize.sm,
              children: [
                ItemContent(children: [ItemTitle(Text('After it'))]),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
