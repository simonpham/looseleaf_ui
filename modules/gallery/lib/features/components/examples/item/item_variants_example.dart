import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ItemVariantsExample extends StatelessWidget {
  const ItemVariantsExample({super.key});

  static const _maxWidth = Spacing.d448;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d24,
      children: [
        InkItem(
          children: [
            const ItemMedia(
              variant: ItemMediaVariant.icon,
              child: InkIcon('bell'),
            ),
            const ItemContent(
              children: [
                ItemTitle(Text('Notifications')),
                ItemDescription(Text('Choose what lands in your inbox.')),
              ],
            ),
            ItemActions(
              children: [
                Button(
                  variant: ButtonVariant.outline,
                  size: ButtonSize.sm,
                  onPressed: () {},
                  child: const Text('Edit'),
                ),
              ],
            ),
          ],
        ),
        InkItem(
          variant: ItemVariant.outline,
          children: [
            const ItemMedia(
              variant: ItemMediaVariant.icon,
              child: InkIcon('user'),
            ),
            const ItemContent(
              children: [
                ItemTitle(Text('Profile')),
                ItemDescription(
                  Text('Your name, your face, your pencil case.'),
                ),
              ],
            ),
            ItemActions(
              children: [
                Button(
                  variant: ButtonVariant.outline,
                  size: ButtonSize.sm,
                  onPressed: () {},
                  child: const Text('Open'),
                ),
              ],
            ),
          ],
        ),
        InkItem(
          variant: ItemVariant.muted,
          children: [
            const ItemMedia(
              variant: ItemMediaVariant.icon,
              child: InkIcon('settings'),
            ),
            const ItemContent(
              children: [
                ItemTitle(Text('Preferences')),
                ItemDescription(
                  Text('Density, motion and the color of the desk.'),
                ),
              ],
            ),
            ItemActions(
              children: [
                Button(
                  variant: ButtonVariant.outline,
                  size: ButtonSize.sm,
                  onPressed: () {},
                  child: const Text('Change'),
                ),
              ],
            ),
          ],
        ),
        InkItem(
          variant: ItemVariant.outline,
          size: ItemSize.sm,
          children: [
            const ItemContent(children: [ItemTitle(Text('Small'))]),
            ItemActions(
              children: [
                Button(
                  variant: ButtonVariant.ghost,
                  size: ButtonSize.sm,
                  onPressed: () {},
                  child: const Text('Undo'),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
