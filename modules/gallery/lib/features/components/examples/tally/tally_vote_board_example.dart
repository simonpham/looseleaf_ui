import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TallyVoteBoardExample extends StatelessWidget {
  const TallyVoteBoardExample({super.key});

  static const _maxWidth = 384.0;
  static const _nameWidth = 128.0;
  static const _votes = [
    ('Tea', 12),
    ('Coffee', 7),
    ('Hot chocolate', 4),
    ('Water, thanks', 1),
  ];

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
                  'What shall we drink?',
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 24,
                  ),
                ),
              ),
            ],
          ),
          CardContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d10,
              children: [
                for (final (name, count) in _votes)
                  Row(
                    spacing: Spacing.d12,
                    children: [
                      SizedBox(
                        width: _nameWidth,
                        child: Text(
                          name,
                          style: theme.typography.interface(cssSize: 17),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Tally(
                            count: count,
                            label: '$count votes for $name',
                            animate: true,
                          ),
                        ),
                      ),
                      ExcludeSemantics(
                        child: Text(
                          '$count',
                          style: theme.typography
                              .interface(
                                cssSize: 14,
                                color: theme.colors.inkMuted,
                              )
                              .copyWith(
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
