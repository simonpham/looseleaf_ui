import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ItemDemoExample extends StatelessWidget {
  const ItemDemoExample({super.key});

  static const _maxWidth = Spacing.d448;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d24,
      children: [
        InkItem(
          variant: ItemVariant.outline,
          children: [
            const ItemContent(
              children: [
                ItemTitle(Text('Basic Item')),
                ItemDescription(
                  Text('A simple item with title and description.'),
                ),
              ],
            ),
            ItemActions(
              children: [
                Button(
                  variant: ButtonVariant.outline,
                  size: ButtonSize.sm,
                  onPressed: () {},
                  child: const Text('Action'),
                ),
              ],
            ),
          ],
        ),
        InkItem(
          variant: ItemVariant.outline,
          size: ItemSize.sm,
          onPressed: () {},
          children: const [
            ItemMedia(child: InkIcon('badge-check', size: Spacing.d20)),
            ItemContent(
              children: [ItemTitle(Text('Your profile has been verified.'))],
            ),
            ItemActions(
              children: [InkIcon('chevron-right', size: Spacing.d16)],
            ),
          ],
        ),
      ],
    ),
  );
}
