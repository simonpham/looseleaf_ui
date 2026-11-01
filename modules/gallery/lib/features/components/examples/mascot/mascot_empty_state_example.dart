import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class MascotEmptyStateExample extends StatelessWidget {
  const MascotEmptyStateExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: Row(
        spacing: Spacing.d20,
        children: [
          const Mascot(pose: 'think', size: Spacing.d96),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d4,
              children: [
                Text(
                  'No results for “pencil case”',
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 24,
                    color: theme.colors.ink,
                  ),
                ),
                Text(
                  'Try a shorter word, or check the spelling. Stubby is thinking about it.',
                  style: theme.typography.interface(
                    color: theme.colors.pencilText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
