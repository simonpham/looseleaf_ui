import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SeparatorStylesExample extends StatelessWidget {
  const SeparatorStylesExample({super.key});

  static const _maxWidth = 448.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d28,
        children: [
          for (final variant in SeparatorVariant.values)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d8,
              children: [
                Text(
                  variant.name,
                  style: theme.typography.interface(
                    cssSize: 14,
                    color: theme.colors.inkMuted,
                  ),
                ),
                Separator(variant: variant, seed: variant.name),
              ],
            ),
        ],
      ),
    );
  }
}
