import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ItemHeaderExample extends StatelessWidget {
  const ItemHeaderExample({super.key});

  static const _maxWidth = 576.0;
  static const _models = [
    (
      name: 'v0-1.5-sm',
      description: 'Everyday tasks and UI generation.',
      doodle: 'feather',
    ),
    (
      name: 'v0-1.5-lg',
      description: 'Advanced thinking or reasoning.',
      doodle: 'light-bulb',
    ),
    (
      name: 'v0-2.0-mini',
      description: 'Open Source model for everyone.',
      doodle: 'sprout',
    ),
  ];

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d24,
      children: [
        for (final model in _models)
          Expanded(
            child: InkItem(
              variant: ItemVariant.outline,
              children: [
                ItemHeader(
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Center(
                          child: Doodle(model.doodle, size: Spacing.d64),
                        ),
                      ),
                    ),
                  ],
                ),
                ItemContent(
                  children: [
                    ItemTitle(Text(model.name)),
                    ItemDescription(Text(model.description)),
                  ],
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
