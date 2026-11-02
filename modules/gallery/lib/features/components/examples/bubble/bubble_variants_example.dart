import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class BubbleVariantsExample extends StatelessWidget {
  const BubbleVariantsExample({super.key});

  static const _says = [
    (BubbleVariant.primary, 'Can you add tags to my notes?'),
    (BubbleVariant.secondary, 'Tags, then a filter row above the list.'),
    (
      BubbleVariant.muted,
      'Sure. Give me a minute, I will look at the list first.',
    ),
    (BubbleVariant.tinted, 'Two tags per note is plenty, I think.'),
    (BubbleVariant.outline, 'And a way to remove them again?'),
    (
      BubbleVariant.destructive,
      'That would delete every tag. Are you sure?',
    ),
  ];
  static const _maxWidth = 512.0;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.d12,
          0,
          Spacing.d12,
          Spacing.d16,
        ),
        child: BubbleGroup(
          gap: Spacing.d16,
          children: [
            for (final (index, (variant, says)) in _says.indexed)
              Bubble(
                variant: variant,
                align: switch (index.isOdd) {
                  true => ChatAlign.end,
                  false => ChatAlign.start,
                },
                children: [
                  BubbleContent(
                    seed: 'variant-${variant.id}',
                    child: Text(says),
                  ),
                ],
              ),
            const Bubble(
              variant: BubbleVariant.ghost,
              children: [
                BubbleContent(
                  child: Text(
                    'Ghost bubbles are just the words, set in the same hand.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
