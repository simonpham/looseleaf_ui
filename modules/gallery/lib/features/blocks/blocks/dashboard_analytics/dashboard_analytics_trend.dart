import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// An arrow and a signed change, green when it is good news and red when
/// it is not.
class DashboardAnalyticsTrend extends StatelessWidget {
  const DashboardAnalyticsTrend({
    super.key,
    required this.text,
    required this.up,
    required this.good,
    required this.spoken,
  });

  final String text;

  /// Which way the arrow points.
  final bool up;

  /// Green when true, red when false.
  final bool good;

  /// What a screen reader hears after [text], like ", better".
  final String spoken;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final color = switch (good) {
      true => theme.colors.green,
      false => theme.colors.red,
    };
    return Semantics(
      label: '$text$spoken',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.d4,
        children: [
          InkIcon(
            switch (up) {
              true => 'arrow-up',
              false => 'arrow-down',
            },
            size: Spacing.d14,
            color: color,
          ),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
