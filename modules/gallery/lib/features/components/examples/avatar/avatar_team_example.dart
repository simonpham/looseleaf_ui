import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _team = [
  (name: 'Ada Lovelace', role: 'Designer', status: AvatarStatus.online),
  (name: 'Jo Okafor', role: 'Engineer', status: AvatarStatus.busy),
  (name: 'Mika Kobayashi', role: 'Writer', status: AvatarStatus.away),
  (name: 'Sam Reyes', role: 'Support', status: AvatarStatus.offline),
];

class AvatarTeamExample extends StatelessWidget {
  const AvatarTeamExample({super.key});

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
      child: Card(
        seed: 'team',
        children: [
          CardHeader(
            children: [
              const CardTitle(Text('On the team')),
              const CardDescription(
                Text('4 people, 2 of them at their desks.'),
              ),
              CardAction(
                child: Button(
                  size: ButtonSize.sm,
                  variant: ButtonVariant.outline,
                  onPressed: () {},
                  child: const Text('Invite'),
                ),
              ),
            ],
          ),
          CardContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d16,
              children: [
                for (final person in _team)
                  Row(
                    spacing: Spacing.d12,
                    children: [
                      Avatar(
                        size: AvatarSize.lg,
                        children: [
                          AvatarFallback(name: person.name),
                          AvatarBadge(
                            status: person.status,
                            semanticLabel: person.status.name,
                          ),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              person.name,
                              style: theme.typography.face(
                                KevinSansFace.hand,
                                cssLineHeight: 1.25,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(person.role, style: muted),
                          ],
                        ),
                      ),
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: Spacing.d4),
                  child: Row(
                    spacing: Spacing.d12,
                    children: [
                      AvatarGroup(
                        size: AvatarSize.sm,
                        children: [
                          for (final name in [
                            'Priya Nair',
                            'Tomas Berg',
                            'Lena Fischer',
                          ])
                            Avatar(children: [AvatarFallback(name: name)]),
                          const AvatarGroupCount(child: Text('+5')),
                        ],
                      ),
                      Text('also watching', style: muted),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
