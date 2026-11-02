import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ItemIconExample extends StatelessWidget {
  const ItemIconExample({super.key});

  static const _maxWidth = 512.0;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: InkItem(
      variant: ItemVariant.outline,
      children: [
        const ItemMedia(
          variant: ItemMediaVariant.icon,
          child: InkIcon('shield-alert'),
        ),
        const ItemContent(
          children: [
            ItemTitle(Text('Security Alert')),
            ItemDescription(Text('New login detected from unknown device.')),
          ],
        ),
        ItemActions(
          children: [
            Button(
              size: ButtonSize.sm,
              variant: ButtonVariant.outline,
              onPressed: () {},
              child: const Text('Review'),
            ),
          ],
        ),
      ],
    ),
  );
}
