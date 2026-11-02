import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ItemLinkExample extends StatelessWidget {
  const ItemLinkExample({super.key});

  static const _maxWidth = Spacing.d448;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d16,
      children: [
        InkItem(
          onPressed: () {},
          children: const [
            ItemContent(
              children: [
                ItemTitle(Text('Visit our documentation')),
                ItemDescription(
                  Text('Learn how to get started with our components.'),
                ),
              ],
            ),
            ItemActions(
              children: [InkIcon('chevron-right', size: Spacing.d16)],
            ),
          ],
        ),
        InkItem(
          variant: ItemVariant.outline,
          onPressed: () {},
          children: const [
            ItemContent(
              children: [
                ItemTitle(Text('External resource')),
                ItemDescription(
                  Text('Opens in a new tab with security attributes.'),
                ),
              ],
            ),
            ItemActions(
              children: [InkIcon('external-link', size: Spacing.d16)],
            ),
          ],
        ),
      ],
    ),
  );
}
