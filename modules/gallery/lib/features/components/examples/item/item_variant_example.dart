import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ItemVariantExample extends StatelessWidget {
  const ItemVariantExample({super.key});

  static const _maxWidth = Spacing.d448;
  static const _variants = [
    (
      variant: ItemVariant.regular,
      title: 'Default Variant',
      description: 'Standard styling with subtle background and borders.',
    ),
    (
      variant: ItemVariant.outline,
      title: 'Outline Variant',
      description:
          'Outlined style with clear borders and transparent background.',
    ),
    (
      variant: ItemVariant.muted,
      title: 'Muted Variant',
      description:
          'Subdued appearance with muted colors for secondary content.',
    ),
  ];

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d24,
      children: [
        for (final item in _variants)
          InkItem(
            variant: item.variant,
            children: [
              ItemContent(
                children: [
                  ItemTitle(Text(item.title)),
                  ItemDescription(Text(item.description)),
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
      ],
    ),
  );
}
