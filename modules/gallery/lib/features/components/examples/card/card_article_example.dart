import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-md`.
const _maxWidth = Spacing.d448;

class CardArticleExample extends StatelessWidget {
  const CardArticleExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: SizedBox(
          width: double.infinity,
          child: Card(
            tape: PaperTape.both,
            tapeKind: TapeKind.washiDots,
            edge: const EdgeSpec(bottom: EdgeKind.torn),
            seed: 'article',
            padding: const EdgeInsets.only(
              top: Spacing.d24,
              bottom: Spacing.d32,
            ),
            children: [
              CardHeader(
                children: [
                  const CardDescription(Text('Notebook - 4 min read')),
                  CardTitle(
                    Text(
                      'Why the margin is the best part',
                      style: theme.typography.title(cssSize: 30),
                    ),
                  ),
                ],
              ),
              CardContent(
                child: Text(
                  'Most of what I remember from a book is in the margins: an '
                  'arrow, a question mark, a small argument with a dead author.',
                  style: theme.typography.face(
                    KevinSansFace.hand,
                    cssSize: 15,
                    cssLineHeight: 1.625,
                  ),
                ),
              ),
              CardFooter(
                padding: const EdgeInsetsDirectional.only(
                  start: Spacing.d12,
                  end: Spacing.d24,
                ),
                children: [
                  Button(
                    variant: ButtonVariant.link,
                    size: ButtonSize.sm,
                    onPressed: () {},
                    child: const Text('Keep reading'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
