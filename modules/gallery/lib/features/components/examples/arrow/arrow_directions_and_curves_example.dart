import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ArrowDirectionsAndCurvesExample extends StatelessWidget {
  const ArrowDirectionsAndCurvesExample({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d8,
    children: [
      for (final curve in const [ArrowCurve.straight, ArrowCurve.curved])
        Row(
          spacing: Spacing.d16,
          children: [
            for (final direction in ArrowDirection.values)
              Expanded(
                child: SizedBox(
                  height: Spacing.d48,
                  child: Arrow(
                    direction: direction,
                    curve: curve,
                    tone: switch (curve) {
                      ArrowCurve.straight => MarkPen.ink,
                      _ => MarkPen.blue,
                    },
                  ),
                ),
              ),
          ],
        ),
      const SizedBox(height: Spacing.d16),
      Wrap(
        spacing: Spacing.d24,
        runSpacing: Spacing.d16,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          const _Figure(
            caption: 'curl',
            width: Spacing.d160,
            arrow: Arrow(curve: ArrowCurve.curl, tone: MarkPen.red),
          ),
          for (final head in ArrowHead.values)
            _Figure(
              caption: head.name,
              width: Spacing.d80,
              arrow: Arrow(
                direction: ArrowDirection.upRight,
                curve: ArrowCurve.curved,
                head: head,
              ),
            ),
        ],
      ),
    ],
  );
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.caption,
    required this.width,
    required this.arrow,
  });

  final String caption;
  final double width;
  final Arrow arrow;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d4,
      children: [
        SizedBox(width: width, height: Spacing.d48, child: arrow),
        Text(
          caption,
          style: theme.typography.stamp(
            cssSize: 11,
            color: theme.colors.pencilText,
          ),
        ),
      ],
    );
  }
}
