import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DoodleMarginExample extends StatelessWidget {
  const DoodleMarginExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d384),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Paper(
            stock: StockName.slip,
            tiltDegrees: 0.45,
            padding: const EdgeInsets.all(Spacing.d24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekend list',
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 30,
                    color: theme.colors.ink,
                  ),
                ),
                const SizedBox(height: Spacing.d8),
                Text(
                  'Pick flowers, find the good mushrooms, call it a day.',
                  style: theme.typography.interface(
                    color: theme.colors.pencilText,
                  ),
                ),
                const SizedBox(height: Spacing.d12),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: Spacing.d12,
                  children: [
                    Doodle('flower', size: Spacing.d48, rotate: -6),
                    Doodle(
                      'mushroom',
                      size: Spacing.d48,
                      rotate: 5,
                      flip: true,
                    ),
                    Doodle('sun', size: Spacing.d48),
                  ],
                ),
              ],
            ),
          ),
          const PositionedDirectional(
            top: -Spacing.d12,
            end: -Spacing.d8,
            child: Doodle('star', size: Spacing.d48, rotate: 14),
          ),
        ],
      ),
    );
  }
}
