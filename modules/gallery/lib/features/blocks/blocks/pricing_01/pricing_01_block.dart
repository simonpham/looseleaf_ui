import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/pricing_01/pricing_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A pricing section: a monthly / yearly switch, three plans on taped
/// cards (stacked, or three across from 896 px with the popular one
/// standing taller) and the common questions on a slip.
///
/// Mirrors upstream `src/blocks/pricing-01/page.tsx`.
class Pricing01Block extends StatefulWidget {
  const Pricing01Block({
    super.key,
    this.defaultPeriod = Pricing01Period.monthly,
    this.onChoose,
  });

  /// The billing period shown first.
  final Pricing01Period defaultPeriod;

  /// Called when a plan is picked, with the period it was shown for.
  final void Function(Pricing01Tier tier, Pricing01Period period)? onChoose;

  @override
  State<Pricing01Block> createState() => _Pricing01BlockState();
}

class _Pricing01BlockState extends State<Pricing01Block> {
  late Pricing01Period _period = widget.defaultPeriod;
  String? _chosen;

  static const double _maxWidth = 1152;
  static const double _headerWidth = 672;
  static const double _stackWidth = 448;
  static const double _faqWidth = 672;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final popular = pricing01Tiers.firstWhere((tier) => tier.popular);
    final saved = popular.monthly * 12 - popular.yearly;
    final wideScreen = MediaQuery.sizeOf(context).width >= 640;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: switch (wideScreen) {
              true => Spacing.d32,
              false => Spacing.d16,
            },
            vertical: Spacing.d48,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final across = width >= 896;
              final cards = [
                for (final tier in pricing01Tiers)
                  Pricing01Card(
                    tier: tier,
                    period: _period,
                    chosen: _chosen == tier.id,
                    raised: across,
                    onChoose: () {
                      setState(() => _chosen = tier.id);
                      widget.onChoose?.call(tier, _period);
                    },
                  ),
              ];
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d48,
                children: [
                  _header(theme, width),
                  Semantics(
                    liveRegion: true,
                    label: switch (_period) {
                      Pricing01Period.yearly =>
                        'Showing yearly prices. Studio saves you ${pricing01Dollars(saved)} a year.',
                      Pricing01Period.monthly => 'Showing monthly prices.',
                    },
                    child: const SizedBox.shrink(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: Spacing.d24),
                    child: switch (across) {
                      true => Row(
                        spacing: Spacing.d32,
                        children: [
                          for (final card in cards) Expanded(child: card),
                        ],
                      ),
                      false => Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: _stackWidth,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: Spacing.d48,
                            children: cards,
                          ),
                        ),
                      ),
                    },
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: _faqWidth),
                      child: Paper(
                        stock: StockName.slip,
                        tiltDegrees: -0.3,
                        seed: 'pricing-faq',
                        padding: const EdgeInsets.all(Spacing.d24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: Spacing.d16,
                          children: [
                            Semantics(
                              header: true,
                              child: Text(
                                'Questions people ask',
                                style: theme.typography.face(
                                  KevinSansFace.script,
                                  cssSize: 30,
                                  cssLineHeight: 1,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colors.ink,
                                ),
                              ),
                            ),
                            Accordion(
                              collapsible: true,
                              children: [
                                for (final (index, item)
                                    in pricing01Faq.indexed)
                                  AccordionItem(
                                    value: 'q$index',
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        AccordionTrigger(
                                          child: Text(item.question),
                                        ),
                                        AccordionContent(
                                          child: Text(item.answer),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
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

  Widget _header(LooseleafThemeData theme, double width) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _headerWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.d16,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Pick a desk that fits',
              textAlign: TextAlign.center,
              style: theme.typography.face(
                KevinSansFace.script,
                cssSize: switch (width >= 512) {
                  true => 60,
                  false => 48,
                },
                cssLineHeight: 1,
                fontWeight: FontWeight.w700,
                color: theme.colors.ink,
              ),
            ),
          ),
          Text(
            'Start free with one notebook. Pay when you need more paper, more people or the good highlighters. Cancel with one press.',
            textAlign: TextAlign.center,
            style: theme.typography.face(
              KevinSansFace.hand,
              cssSize: 18,
              cssLineHeight: 28 / 18,
              color: theme.colors.inkMuted,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: Spacing.d8),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: Spacing.d12,
              runSpacing: Spacing.d4,
              children: [
                ToggleGroup<Pricing01Period>(
                  value: {_period},
                  variant: ToggleVariant.outline,
                  size: ToggleSize.lg,
                  semanticLabel: 'Billing period',
                  onChanged: (value) {
                    if (value.firstOrNull case final period?) {
                      setState(() => _period = period);
                    }
                  },
                  children: const [
                    ToggleGroupItem(
                      value: Pricing01Period.monthly,
                      child: Text('Monthly'),
                    ),
                    ToggleGroupItem(
                      value: Pricing01Period.yearly,
                      child: Text('Yearly'),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: Spacing.d4,
                  children: [
                    Doodle(
                      'arrow-swoop',
                      size: 48,
                      flip: Directionality.of(context) == TextDirection.ltr,
                    ),
                    Text(
                      'two months free',
                      style: theme.typography.face(
                        KevinSansFace.script,
                        cssSize: 24,
                        cssLineHeight: 1,
                        color: theme.colors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
