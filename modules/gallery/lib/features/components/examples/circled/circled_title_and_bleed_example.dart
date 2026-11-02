import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CircledTitleAndBleedExample extends StatelessWidget {
  const CircledTitleAndBleedExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d128 * 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.d8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d20,
          children: [
            Text.rich(
              style: theme.typography
                  .face(KevinSansFace.script, cssSize: 36)
                  .copyWith(fontWeight: FontWeight.bold),
              const TextSpan(
                children: [
                  TextSpan(text: 'Good to see '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: Circled(tone: MarkPen.blue, child: Text('you')),
                  ),
                  TextSpan(text: ' again'),
                ],
              ),
            ),
            Text(
              'Sign in with your email and the password you keep in your head.',
              style: theme.typography.interface(color: theme.colors.inkMuted),
            ),
            DefaultTextStyle.merge(
              style: theme.typography.interface(cssSize: 17),
              child: const Wrap(
                spacing: Spacing.d32,
                runSpacing: Spacing.d12,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  Circled(bleed: 0, child: Text('bleed 0')),
                  Circled(child: Text('bleed 2, the default')),
                  Circled(bleed: 7, tone: MarkPen.red, child: Text('bleed 7')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
