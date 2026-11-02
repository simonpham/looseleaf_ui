import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class HandwrittenStrengthAndSkipsExample extends StatelessWidget {
  const HandwrittenStrengthAndSkipsExample({super.key});

  static const _maxWidth = 576.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final mono = theme.typography.mono(cssSize: 14);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: DefaultTextStyle.merge(
        style: theme.typography.face(
          KevinSansFace.hand,
          cssSize: 17,
          cssLineHeight: 1.7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d16,
          children: [
            Handwritten(
              'strength 0.5: barely there, a careful hand.',
              strength: 0.5,
            ),
            Handwritten(
              'strength 1: the default hand, every word a hair off.',
            ),
            Handwritten(
              'strength 2: a hurried hand, in a bus, in the rain.',
              strength: 2,
            ),
            Handwritten.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Press '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: Text('Ctrl', style: mono),
                  ),
                  const TextSpan(text: ' then run '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: Text('npm test', style: mono),
                  ),
                  const TextSpan(text: ' or read '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: Button(
                      variant: ButtonVariant.link,
                      onPressed: () {},
                      child: const Text('the docs'),
                    ),
                  ),
                  const TextSpan(text: ' '),
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: Text('(these words are typeset)'),
                  ),
                  const TextSpan(text: ' and carry on.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
