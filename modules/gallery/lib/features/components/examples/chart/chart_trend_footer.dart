import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The shadcn chart card footer: a trend line with its arrow, and a muted
/// caption under it.
class ChartTrendFooter extends StatelessWidget {
  const ChartTrendFooter({super.key, required this.caption});

  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return CardFooter(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d8,
                children: [
                  Flexible(
                    child: Text(
                      'Trending up by 5.2% this month',
                      style: theme.typography
                          .interface(cssSize: 14, color: theme.colors.ink)
                          .copyWith(height: 1, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const InkIcon('trending-up', size: Spacing.d16),
                ],
              ),
              Text(
                caption,
                style: theme.typography
                    .interface(cssSize: 14, color: theme.colors.inkMuted)
                    .copyWith(height: 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
