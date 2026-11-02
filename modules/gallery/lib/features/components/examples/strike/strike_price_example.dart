import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class StrikePriceExample extends StatelessWidget {
  const StrikePriceExample({super.key});

  static const _maxWidth = Spacing.d320;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Card(
        stock: StockName.indexCard,
        children: [
          CardHeader(
            children: [
              CardTitle(
                Text(
                  'Field notebook',
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 24,
                  ),
                ),
              ),
              const CardDescription(Text('Dot grid, stitched spine')),
            ],
          ),
          CardContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d4,
              children: [
                DefaultTextStyle.merge(
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 36,
                    cssLineHeight: 1.1,
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: Strike(
                            weight: MarkWeight.brush,
                            child: Text(
                              r'$24',
                              style: TextStyle(color: theme.colors.inkMuted),
                            ),
                          ),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: r'$16',
                          style: TextStyle(color: theme.colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  r'Was $24. Now $16 until Sunday.',
                  style: theme.typography.interface(
                    cssSize: 14,
                    color: theme.colors.inkMuted,
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
