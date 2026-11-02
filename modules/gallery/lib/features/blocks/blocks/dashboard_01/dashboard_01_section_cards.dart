import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Four numbers on cards, one, two or four across as the page widens.
///
/// Mirrors `SectionCards` in upstream
/// `src/blocks/dashboard-01/components/dashboard-01-section-cards.tsx`.
class Dashboard01SectionCards extends StatelessWidget {
  const Dashboard01SectionCards({super.key});

  static const double _twoFrom = 576;
  static const double _fourFrom = 1024;
  static const double _bigNumberFrom = 250;

  static const _cards = [
    (
      label: 'Total revenue',
      value: r'$48,230',
      delta: '+12.5%',
      up: true,
      line: 'A busy month, thank goodness',
      note: 'Sales for the last six months',
    ),
    (
      label: 'New customers',
      value: '1,234',
      delta: '-20%',
      up: false,
      line: 'A quiet stretch for sign-ups',
      note: 'Worth a nudge in the newsletter',
    ),
    (
      label: 'Active accounts',
      value: '45,678',
      delta: '+12.5%',
      up: true,
      line: 'People keep coming back',
      note: 'Ahead of what we pencilled in',
    ),
    (
      label: 'Growth rate',
      value: '4.5%',
      delta: '+4.5%',
      up: true,
      line: 'Slow and steady',
      note: 'Right on the plan',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Semantics(
      container: true,
      label: 'Key numbers',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final across = switch (width) {
            >= _fourFrom => 4,
            >= _twoFrom => 2,
            _ => 1,
          };
          final cardWidth = (width - Spacing.d16 * (across - 1)) / across;
          return Wrap(
            spacing: Spacing.d16,
            runSpacing: Spacing.d16,
            children: [
              for (final (index, card) in _cards.indexed)
                SizedBox(
                  width: cardWidth,
                  child: Card(
                    seed: 's01-card-$index',
                    children: [
                      CardHeader(
                        children: [
                          CardDescription(Text(card.label)),
                          CardTitle(
                            Text(
                              card.value,
                              style: theme.typography.face(
                                KevinSansFace.script,
                                cssSize: switch (cardWidth >= _bigNumberFrom) {
                                  true => 36,
                                  false => 30,
                                },
                                cssLineHeight: 1.2,
                                fontWeight: FontWeight.w700,
                                color: theme.colors.ink,
                              ),
                            ),
                          ),
                          CardAction(
                            child: Badge(
                              variant: BadgeVariant.outline,
                              leading: InkIcon(_trend(card.up)),
                              child: Text(card.delta),
                            ),
                          ),
                        ],
                      ),
                      CardFooter(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: Spacing.d4,
                              children: [
                                Row(
                                  spacing: Spacing.d8,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        card.line,
                                        style: theme.typography
                                            .interface(cssSize: 14)
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                    InkIcon(_trend(card.up), size: Spacing.d16),
                                  ],
                                ),
                                Text(
                                  card.note,
                                  style: theme.typography.interface(
                                    cssSize: 14,
                                    color: theme.colors.inkSoft,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  static String _trend(bool up) => switch (up) {
    true => 'trending-up',
    false => 'trending-down',
  };
}
