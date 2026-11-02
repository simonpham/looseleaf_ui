import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class EmptyFourIconsExample extends StatelessWidget {
  const EmptyFourIconsExample({super.key});

  static const _states = [
    (
      icon: 'inbox',
      title: 'No messages',
      text: 'Your inbox is empty. New messages will appear here.',
    ),
    (
      icon: 'star',
      title: 'No favorites',
      text: 'Items you mark as favorites will appear here.',
    ),
    (
      icon: 'heart',
      title: 'No likes yet',
      text: 'Content you like will be saved here for easy access.',
    ),
    (
      icon: 'bookmark',
      title: 'No bookmarks',
      text: 'Save interesting content by bookmarking it.',
    ),
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final empties = [
        for (final state in _states)
          Empty(
            children: [
              EmptyHeader(
                children: [
                  EmptyMedia(
                    variant: EmptyMediaVariant.icon,
                    child: InkIcon(state.icon),
                  ),
                  EmptyTitle(child: Text(state.title)),
                  EmptyDescription(child: Text(state.text)),
                ],
              ),
            ],
          ),
      ];
      if (constraints.maxWidth < 768) {
        return Column(spacing: Spacing.d32, children: empties);
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.d32,
        children: [
          for (var row = 0; row < empties.length; row += 2)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d32,
              children: [
                for (final empty in empties.skip(row).take(2))
                  Expanded(child: empty),
              ],
            ),
        ],
      );
    },
  );
}
