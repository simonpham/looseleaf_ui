import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The motion durations, each with its token.
class MotionSamples extends StatelessWidget {
  const MotionSamples({super.key});

  static const List<(String, Duration)> durations = [
    ('press', InkMotion.press),
    ('hover', InkMotion.hover),
    ('fade', InkMotion.fade),
    ('pop', InkMotion.pop),
    ('sheet', InkMotion.sheet),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Wrap(
      spacing: Spacing.d32,
      runSpacing: Spacing.d16,
      children: [
        for (final (name, duration) in durations)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${duration.inMilliseconds} ms',
                style: theme.typography.face(
                  KevinSansFace.script,
                  cssSize: 30,
                  fontWeight: FontWeight.w700,
                  color: theme.colors.inkYou,
                ),
              ),
              Text(
                'InkMotion.$name',
                style: theme.typography.mono(
                  cssSize: 13,
                  color: theme.colors.inkMuted,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
