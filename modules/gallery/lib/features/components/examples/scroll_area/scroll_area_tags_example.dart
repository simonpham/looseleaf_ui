import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ScrollAreaTagsExample extends StatelessWidget {
  const ScrollAreaTagsExample({super.key});

  static final _tags = [
    for (var i = 0; i < 50; i++)
      'v1.${2 - i ~/ 10}.${9 - i % 10}-beta.${50 - i}',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return SizedBox(
      width: Spacing.d224,
      child: Paper(
        stock: StockName.slip,
        tilt: false,
        seed: 'tags',
        child: SizedBox(
          height: Spacing.d288,
          child: ScrollArea(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.d16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.d12),
                    child: Text(
                      'Tags',
                      style: theme.typography
                          .face(KevinSansFace.script, cssSize: 20)
                          .copyWith(fontWeight: FontWeight.w600, height: 1),
                    ),
                  ),
                  for (final tag in _tags) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Spacing.d8),
                      child: Text(
                        tag,
                        style: theme.typography.interface(cssSize: 14),
                      ),
                    ),
                    Separator(variant: SeparatorVariant.dashed, seed: tag),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
