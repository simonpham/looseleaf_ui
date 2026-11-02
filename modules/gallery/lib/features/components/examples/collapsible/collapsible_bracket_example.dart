import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CollapsibleBracketExample extends StatelessWidget {
  const CollapsibleBracketExample({super.key});

  static const _maxWidth = Spacing.d384;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final muted = theme.typography.interface(
      cssSize: 14,
      color: theme.colors.inkMuted,
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Collapsible(
        defaultOpen: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
              builder: (context) => Button(
                variant: ButtonVariant.link,
                onPressed: Collapsible.of(context).toggle,
                trailing: const CollapsibleIndicator(),
                child: const Text('What is in the box?'),
              ),
            ),
            CollapsibleContent(
              bracket: BracketKind.curly,
              child: Padding(
                padding: const EdgeInsets.only(top: Spacing.d8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d8,
                  children: [
                    Text(
                      'One pencil stub, sharpened crooked. Three felt tips that still work. A yellow highlighter, half dry.',
                      style: muted,
                    ),
                    Text('A ruler with a chip out of the end.', style: muted),
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
