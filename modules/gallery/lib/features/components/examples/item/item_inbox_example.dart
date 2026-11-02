import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ItemInboxExample extends StatelessWidget {
  const ItemInboxExample({super.key});

  static const _maxWidth = 512.0;
  static const _messages = [
    (
      doodle: 'sun',
      from: 'Mara',
      subject: 'Sunday plans',
      preview: 'The lake, if the weather holds, and there will be bread.',
      fresh: true,
    ),
    (
      doodle: 'flower',
      from: 'The garden club',
      subject: 'Bulbs, finally',
      preview: 'Two hundred tulips to plant before the ground freezes.',
      fresh: false,
    ),
    (
      doodle: 'mushroom',
      from: 'Ines',
      subject: 'You will not believe it',
      preview: 'A whole ring of them, right behind the shed.',
      fresh: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Card(
          seed: 'inbox',
          children: [
            const CardHeader(
              children: [
                CardTitle(Text('Inbox')),
                CardDescription(Text('Three letters, one of them new.')),
                CardAction(
                  child: Badge(
                    tally: true,
                    count: 3,
                    variant: BadgeVariant.outline,
                  ),
                ),
              ],
            ),
            CardContent(
              child: ItemGroup(
                ruled: true,
                children: [
                  for (final message in _messages)
                    InkItem(
                      children: [
                        ItemMedia(
                          variant: ItemMediaVariant.image,
                          child: Padding(
                            padding: const EdgeInsets.only(top: Spacing.d2),
                            child: Doodle(message.doodle, size: Spacing.d36),
                          ),
                        ),
                        ItemContent(
                          children: [
                            ItemTitle(
                              Text(message.subject),
                              trailing: switch (message.fresh) {
                                true => const Badge(
                                  size: BadgeSize.sm,
                                  child: Text('New'),
                                ),
                                false => null,
                              },
                            ),
                            ItemDescription(
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: message.from,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    TextSpan(text: ' · ${message.preview}'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        ItemActions(
                          children: [
                            Button(
                              variant: ButtonVariant.ghost,
                              size: ButtonSize.sm,
                              onPressed: () {},
                              child: const Text('Open'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: Spacing.d16),
                    child: InkItem(
                      variant: ItemVariant.muted,
                      children: [
                        const ItemHeader(children: [ItemTitle(Text('Tip'))]),
                        const ItemContent(
                          children: [
                            ItemDescription(
                              Text(
                                'Press a letter and it opens; press it again and it closes.',
                              ),
                            ),
                          ],
                        ),
                        ItemFooter(
                          children: [
                            Text(
                              'Keep going',
                              style: theme.typography.interface(
                                cssSize: 14,
                                color: theme.colors.inkMuted,
                              ),
                            ),
                            const Kbd(child: Text('J')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
