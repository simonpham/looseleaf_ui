import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-md`.
const _maxWidth = Spacing.d448;

class UnderlineHeadlineExample extends StatelessWidget {
  const UnderlineHeadlineExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          children: [
            CardHeader(
              children: [
                CardTitle(
                  Underline(
                    kind: UnderlineMarkKind.double,
                    weight: MarkWeight.brush,
                    tone: MarkPen.blue,
                    child: Text(
                      'Spring reading list',
                      style: theme.typography.face(
                        KevinSansFace.script,
                        cssSize: 36,
                        cssLineHeight: 1.25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            CardContent(
              child: Text.rich(
                style: theme.typography.face(
                  KevinSansFace.hand,
                  cssSize: 17,
                  cssLineHeight: 1.55,
                ),
                const TextSpan(
                  children: [
                    TextSpan(text: 'Three books for the '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: Underline(
                        kind: UnderlineMarkKind.wavy,
                        tone: MarkPen.pencil,
                        child: Text('slow weeks'),
                      ),
                    ),
                    TextSpan(
                      text:
                          ': a novel, a field guide and something with '
                          'pictures.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
