import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ItemAvatarExample extends StatelessWidget {
  const ItemAvatarExample({super.key});

  static const _maxWidth = Spacing.d512;

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
            const ItemMedia(
              child: Avatar(
                size: AvatarSize.lg,
                children: [AvatarFallback(child: Text('ER'))],
              ),
            ),
            const ItemContent(
              children: [
                ItemTitle(Text('Evil Rabbit')),
                ItemDescription(Text('Last seen 5 months ago')),
              ],
            ),
            ItemActions(
              children: [
                Button(
                  size: ButtonSize.iconSm,
                  variant: ButtonVariant.outline,
                  semanticLabel: 'Invite',
                  onPressed: () {},
                  child: const InkIcon('plus'),
                ),
              ],
            ),
          ],
        ),
        InkItem(
          variant: ItemVariant.outline,
          children: [
            const ItemMedia(
              child: AvatarGroup(
                children: [
                  Avatar(children: [AvatarFallback(child: Text('CN'))]),
                  Avatar(children: [AvatarFallback(child: Text('LR'))]),
                  Avatar(children: [AvatarFallback(child: Text('ER'))]),
                ],
              ),
            ),
            const ItemContent(
              children: [
                ItemTitle(Text('No Team Members')),
                ItemDescription(
                  Text('Invite your team to collaborate on this project.'),
                ),
              ],
            ),
            ItemActions(
              children: [
                Button(
                  size: ButtonSize.sm,
                  variant: ButtonVariant.outline,
                  onPressed: () {},
                  child: const Text('Invite'),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
