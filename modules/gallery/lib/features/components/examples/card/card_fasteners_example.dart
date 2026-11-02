import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-2xl`.
const _maxWidth = 672.0;

/// Below this width the cards stack (`sm:grid-cols-2`).
const _twoColumns = 400.0;

const _fasteners = [
  FastenerKind.pin,
  FastenerKind.clip,
  FastenerKind.staple,
  FastenerKind.binderClip,
];

class CardFastenersExample extends StatelessWidget {
  const CardFastenersExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.d24,
            Spacing.d48,
            Spacing.d24,
            Spacing.d24,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = switch (constraints.maxWidth < _twoColumns) {
                true => 1,
                false => 2,
              };
              final cellWidth =
                  (constraints.maxWidth - Spacing.d36 * (columns - 1)) /
                  columns;
              return Wrap(
                spacing: Spacing.d36,
                runSpacing: Spacing.d56,
                children: [
                  for (final fastener in _fasteners)
                    SizedBox(
                      width: cellWidth,
                      child: Card(
                        fastener: fastener,
                        seed: fastener.id,
                        gap: Spacing.d8,
                        padding: const EdgeInsets.only(
                          top: Spacing.d48,
                          bottom: Spacing.d24,
                        ),
                        children: [
                          CardHeader(children: [CardTitle(Text(fastener.id))]),
                          CardContent(
                            child: Text(
                              'held with a ${fastener.id.replaceFirst('-', ' ')}',
                              style: theme.typography.interface(cssSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
