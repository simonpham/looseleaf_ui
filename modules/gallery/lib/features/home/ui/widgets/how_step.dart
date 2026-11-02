import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A numbered step of "How it works": a big script numeral, a title and a
/// line of text.
///
/// Mirrors a step of `How` in upstream `src/docs/content/home/how.tsx`.
class HowStep extends StatelessWidget {
  const HowStep({
    super.key,
    required this.number,
    required this.title,
    required this.text,
  });

  final int number;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d16,
      children: [
        ExcludeSemantics(
          child: SizedBox.square(
            dimension: Spacing.d44,
            child: Center(
              child: Text(
                '$number',
                style: theme.typography.face(
                  KevinSansFace.script,
                  cssSize: 36,
                  cssLineHeight: 1,
                  fontWeight: FontWeight.w700,
                  color: theme.colors.ink,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d4,
            children: [
              Text(
                title,
                style: theme.typography.face(
                  KevinSansFace.script,
                  cssSize: 30,
                  cssLineHeight: 1,
                  fontWeight: FontWeight.w700,
                  color: theme.colors.ink,
                ),
              ),
              Text(
                text,
                style: theme.typography.interface(color: theme.colors.inkSoft),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
