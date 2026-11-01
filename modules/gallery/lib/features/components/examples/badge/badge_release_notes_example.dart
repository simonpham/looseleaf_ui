import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _changes = [
  (
    kind: 'New',
    variant: BadgeVariant.primary,
    text: 'Pencil-drawn spinner that scribbles while it waits',
  ),
  (
    kind: 'Fixed',
    variant: BadgeVariant.secondary,
    text: 'Focus rings no longer clip inside scroll areas',
  ),
  (
    kind: 'Breaking',
    variant: BadgeVariant.destructive,
    text: 'Badge is a span again; wrap it in a link with onPressed',
  ),
  (
    kind: 'Note',
    variant: BadgeVariant.outline,
    text: 'The hover tilt is off for reduced motion',
  ),
];

class BadgeReleaseNotesExample extends StatelessWidget {
  const BadgeReleaseNotesExample({super.key});

  static const _maxWidth = 448.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Card(
          seed: 'release',
          children: [
            const CardHeader(
              children: [
                CardTitle(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: Spacing.d12,
                    children: [
                      Text('v2.4.0'),
                      Badge(
                        variant: BadgeVariant.secondary,
                        leading: InkIcon('badge-check'),
                        child: Text('Latest'),
                      ),
                    ],
                  ),
                ),
                CardDescription(Text('Released this morning, four changes.')),
                CardAction(
                  child: Badge(
                    tally: true,
                    count: 4,
                    variant: BadgeVariant.outline,
                  ),
                ),
              ],
            ),
            CardContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d12,
                children: [
                  for (final change in _changes)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      spacing: Spacing.d12,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: Spacing.d64,
                          ),
                          child: Badge(
                            variant: change.variant,
                            size: BadgeSize.sm,
                            child: Text(change.kind),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            change.text,
                            style: theme.typography.interface(cssSize: 15),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            CardFooter(
              divider: true,
              children: [
                Button(
                  variant: ButtonVariant.link,
                  size: ButtonSize.sm,
                  onPressed: () {},
                  child: const Text('Read the full changelog'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
