import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class EmptyInputGroupExample extends StatelessWidget {
  const EmptyInputGroupExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Empty(
      children: [
        const EmptyHeader(
          children: [
            EmptyTitle(child: Text('404 - Not Found')),
            EmptyDescription(
              child: Text(
                "The page you're looking for doesn't exist. Try searching for what you need below.",
              ),
            ),
          ],
        ),
        EmptyContent(
          children: [
            const FractionallySizedBox(
              widthFactor: 0.75,
              child: InputGroup(
                children: [
                  InputGroupInput(
                    placeholder: 'Try searching for pages...',
                    semanticLabel: 'Search pages',
                  ),
                  InputGroupAddon(child: InkIcon('search')),
                  InputGroupAddon(
                    align: InputGroupAlign.inlineEnd,
                    child: Kbd(child: Text('/')),
                  ),
                ],
              ),
            ),
            EmptyDescription(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('Need help? '),
                  Button(
                    variant: ButtonVariant.link,
                    size: ButtonSize.xs,
                    onPressed: () {},
                    child: Text(
                      'Contact support',
                      style: TextStyle(color: theme.colors.inkMuted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
