import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _people = [
  'Ada Lovelace',
  'Jo Okafor',
  'Mika Kobayashi',
  'Sam Reyes',
  'Priya Nair',
  'Tomas Berg',
  'Lena Fischer',
  'Omar Haddad',
  'Yuki Tanaka',
  'Ines Moreau',
  'Kofi Mensah',
  'Nora Lindqvist',
];

class AvatarColoursExample extends StatelessWidget {
  const AvatarColoursExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d24,
      children: [
        Wrap(
          spacing: Spacing.d16,
          runSpacing: Spacing.d16,
          children: [
            for (final name in _people)
              Avatar(
                size: AvatarSize.lg,
                children: [AvatarFallback(name: name)],
              ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: Spacing.d20,
          children: [
            const Avatar(
              size: AvatarSize.lg,
              ring: AvatarRing.you,
              children: [
                AvatarFallback(name: 'Ada Lovelace'),
                AvatarBadge(status: AvatarStatus.online),
              ],
            ),
            const Avatar(
              size: AvatarSize.lg,
              ring: AvatarRing.marker,
              children: [AvatarFallback(name: 'Ada Lovelace')],
            ),
            const Avatar(
              size: AvatarSize.lg,
              ring: null,
              children: [AvatarFallback(name: 'Ada Lovelace')],
            ),
            Text(
              'ring: you, marker, none',
              style: theme.typography.interface(
                cssSize: 14,
                color: theme.colors.inkMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
