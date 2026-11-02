import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/pricing_01/pricing_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// One plan on a taped card: name (highlighted, with a badge and a
/// first-place sticker when popular), price for the [period], what it
/// includes and a button to pick it.
///
/// Mirrors upstream `src/blocks/pricing-01/components/pricing-01-card.tsx`.
class Pricing01Card extends StatelessWidget {
  const Pricing01Card({
    super.key,
    required this.tier,
    required this.period,
    required this.chosen,
    required this.onChoose,
    this.raised = false,
  });

  /// The plan.
  final Pricing01Tier tier;

  /// How often it is billed.
  final Pricing01Period period;

  /// Whether this plan is the one picked.
  final bool chosen;

  /// Called by the card's button.
  final VoidCallback onChoose;

  /// Whether the popular card stands taller than the row (three across).
  final bool raised;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final free = tier.monthly == 0;
    final muted = theme.colors.inkMuted;
    final card = Card(
      stock: switch (tier.popular) {
        true => StockName.card,
        false => StockName.paper,
      },
      tape: PaperTape.top,
      tapeKind: tier.tape,
      seed: 'price-${tier.id}',
      padding: EdgeInsets.symmetric(
        vertical: switch (tier.popular && raised) {
          true => Spacing.d40,
          false => Spacing.d24,
        },
      ),
      children: [
        CardHeader(
          children: [
            CardTitle(
              Semantics(
                header: true,
                child: DefaultTextStyle.merge(
                  style: theme.typography.title(cssSize: 30),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: Spacing.d12,
                    runSpacing: Spacing.d4,
                    children: [
                      switch (tier.popular) {
                        true => Highlight(child: Text(tier.name)),
                        false => Text(tier.name),
                      },
                      if (tier.popular)
                        const Badge(
                          size: BadgeSize.sm,
                          child: Text('Most popular'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            CardDescription(Text(tier.tagline)),
          ],
        ),
        CardContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d24,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d4,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    spacing: Spacing.d10,
                    children: [
                      Text(
                        pricing01Dollars(pricing01PerMonth(tier, period)),
                        style: theme.typography
                            .face(
                              KevinSansFace.script,
                              cssSize: 60,
                              cssLineHeight: 1,
                              fontWeight: FontWeight.w700,
                              color: theme.colors.ink,
                            )
                            .copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                      ),
                      Text(
                        switch (free) {
                          true => 'forever',
                          false => 'a month',
                        },
                        style: TextStyle(color: muted),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: Spacing.d20,
                    child: Text(
                      switch ((free, period)) {
                        (true, _) => 'No card needed',
                        (false, Pricing01Period.yearly) =>
                          'billed ${pricing01Dollars(tier.yearly)} once a year',
                        (false, Pricing01Period.monthly) => 'billed monthly',
                      },
                      style: theme.typography.face(
                        KevinSansFace.hand,
                        cssSize: 14,
                        cssLineHeight: 20 / 14,
                        color: muted,
                      ),
                    ),
                  ),
                ],
              ),
              Semantics(
                container: true,
                label: '${tier.name} includes',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d10,
                  children: [
                    for (final feature in tier.features)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Spacing.d10,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: Spacing.d4),
                            child: InkIcon(
                              'check',
                              weight: 1.3,
                              color: theme.colors.green,
                            ),
                          ),
                          Expanded(child: Text(feature)),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        CardFooter(
          children: [
            Expanded(
              child: Semantics(
                toggled: chosen,
                child: Button(
                  size: ButtonSize.lg,
                  variant: switch (tier.popular) {
                    true => ButtonVariant.primary,
                    false => ButtonVariant.outline,
                  },
                  onPressed: onChoose,
                  trailing: switch (chosen) {
                    true => const InkIcon('check'),
                    false => null,
                  },
                  child: Text(switch (chosen) {
                    true => 'Picked',
                    false => tier.cta,
                  }),
                ),
              ),
            ),
          ],
        ),
      ],
    );
    if (!tier.popular) return card;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        card,
        PositionedDirectional(
          top: -Spacing.d36,
          end: switch (raised) {
            true => -Spacing.d20,
            false => -Spacing.d8,
          },
          child: const IgnorePointer(
            child: Sticker(
              'first-place',
              size: 76,
              rotate: 10,
              seed: 'popular',
            ),
          ),
        ),
      ],
    );
  }
}
