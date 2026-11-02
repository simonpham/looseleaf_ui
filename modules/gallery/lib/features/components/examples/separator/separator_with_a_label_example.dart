import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SeparatorWithALabelExample extends StatelessWidget {
  const SeparatorWithALabelExample({super.key});

  static const _maxWidth = Spacing.d384;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Card(
          seed: 'signin',
          children: [
            const CardHeader(
              children: [
                CardTitle(Text('Sign in')),
                CardDescription(Text('Pick up where you left off.')),
              ],
            ),
            CardContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d16,
                children: [
                  const Input(
                    placeholder: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    semanticLabel: 'Email',
                  ),
                  Button(onPressed: () {}, child: const Text('Send me a link')),
                  const Separator(
                    variant: SeparatorVariant.dashed,
                    child: Text('or continue with'),
                  ),
                  Row(
                    spacing: Spacing.d12,
                    children: [
                      Expanded(
                        child: Button(
                          variant: ButtonVariant.outline,
                          onPressed: () {},
                          child: const Text('Notebook'),
                        ),
                      ),
                      Expanded(
                        child: Button(
                          variant: ButtonVariant.outline,
                          onPressed: () {},
                          child: const Text('Sketchpad'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            CardFooter(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    'No password. The link lasts an hour.',
                    style: theme.typography.interface(
                      cssSize: 14,
                      color: theme.colors.inkMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
