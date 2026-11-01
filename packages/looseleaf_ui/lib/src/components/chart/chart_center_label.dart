import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The words in the hole of a donut or radial chart: a big number in the
/// script hand and a small caption.
///
/// Mirrors `ChartCenterLabel` in upstream `src/components/ui/chart.tsx`.
class ChartCenterLabel extends StatelessWidget {
  const ChartCenterLabel({super.key, required this.value, this.label});

  /// The big text.
  final String value;

  /// The caption.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final calm = theme.density == LooseleafDensity.calm;
    final caption = label;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: theme.typography
              .face(
                switch (calm) {
                  true => KevinSansFace.hand,
                  false => KevinSansFace.script,
                },
                cssSize: switch (calm) {
                  true => 24,
                  false => 32,
                },
                cssLineHeight: 1,
                fontWeight: FontWeight.w700,
                color: theme.colors.ink,
              )
              .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
        ),
        if (caption != null)
          Padding(
            padding: const EdgeInsets.only(top: Spacing.d4),
            child: Text(
              caption,
              textAlign: TextAlign.center,
              style: theme.typography.face(
                KevinSansFace.hand,
                cssSize: 13,
                cssLineHeight: 1,
                color: theme.colors.inkMuted,
              ),
            ),
          ),
      ],
    );
  }
}
