import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class HoverCardMentionsExample extends StatelessWidget {
  const HoverCardMentionsExample({super.key});

  static const _people = [
    (
      handle: 'ada',
      name: 'Ada Lovelace',
      bio:
          'Wrote the first program. Notes longer than the paper they annotate.',
      doodle: 'star',
    ),
    (
      handle: 'grace',
      name: 'Grace Hopper',
      bio:
          'Found the first bug, taped it in the log, kept the nanosecond wire.',
      doodle: 'sun',
    ),
    (
      handle: 'margaret',
      name: 'Margaret Hamilton',
      bio: 'Flew the software that flew to the Moon.',
      doodle: 'flower',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d112 * 4),
      child: Text.rich(
        style: theme.typography.interface().copyWith(height: 1.75),
        TextSpan(
          children: [
            const TextSpan(text: "Today's notebook was started by "),
            for (final (index, person) in _people.indexed) ...[
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: HoverCard(
                  content: HoverCardContent(
                    tape: switch (index) {
                      1 => PaperTape.top,
                      _ => null,
                    },
                    seed: person.handle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        HoverCardMedia(
                          child: Doodle(person.doodle, size: 80),
                        ),
                        HoverCardCaption(Text(person.name)),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.d4,
                          ),
                          child: Text(
                            person.bio,
                            style: theme.typography.interface(
                              cssSize: 14,
                              color: theme.colors.inkMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  child: Button(
                    variant: ButtonVariant.link,
                    size: ButtonSize.xs,
                    onPressed: () {},
                    child: Text('@${person.handle}'),
                  ),
                ),
              ),
              TextSpan(
                text: switch (_people.length - index) {
                  1 => '',
                  2 => ' and ',
                  _ => ', ',
                },
              ),
            ],
            const TextSpan(text: ', and finished by nobody yet.'),
          ],
        ),
      ),
    );
  }
}
