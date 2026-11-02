import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class RevealEffectsExample extends StatelessWidget {
  const RevealEffectsExample({super.key});

  static const _cardWidth = 128.0;
  static const _step = Duration(milliseconds: 80);

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Wrap(
      spacing: Spacing.d16,
      runSpacing: Spacing.d16,
      children: [
        for (final (index, effect) in RevealEffect.values.indexed)
          Reveal(
            effect: effect,
            delay: _step * index,
            child: SizedBox(
              width: _cardWidth,
              child: Paper(
                stock: switch (index.isOdd) {
                  true => StockName.stickyYellow,
                  false => StockName.indexCard,
                },
                tiltDegrees: switch (index.isOdd) {
                  true => 2,
                  false => -2,
                },
                padding: const EdgeInsets.all(Spacing.d16),
                child: Text(
                  effect.name,
                  textAlign: TextAlign.center,
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 24,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
