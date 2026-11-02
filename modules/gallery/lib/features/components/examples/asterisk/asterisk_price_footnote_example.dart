import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class AsteriskPriceFootnoteExample extends StatelessWidget {
  const AsteriskPriceFootnoteExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final muted = theme.colors.inkMuted;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d320),
      child: Card(
        stock: StockName.indexCard,
        children: [
          CardHeader(
            children: [
              CardTitle(
                Text(
                  'Studio plan',
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 24,
                  ),
                ),
              ),
              const CardDescription(Text('Everything, for one desk')),
            ],
          ),
          CardContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d8,
              children: [
                DefaultTextStyle.merge(
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 48,
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: Asterisk(
                            label: 'Footnote 1',
                            onPressed: () {},
                            child: const Text(r'$16'),
                          ),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(
                              start: Spacing.d8,
                            ),
                            child: Text(
                              'per month',
                              style: theme.typography.interface(color: muted),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  '* Introductory price for the first twelve months.',
                  style: theme.typography.interface(cssSize: 14, color: muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
