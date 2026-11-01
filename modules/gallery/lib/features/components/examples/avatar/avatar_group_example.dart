import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class AvatarGroupExample extends StatelessWidget {
  const AvatarGroupExample({super.key});

  static const _warm = AssetImage(
    'lib/features/components/examples/avatar/portrait_warm.png',
    package: 'gallery',
  );
  static const _cool = AssetImage(
    'lib/features/components/examples/avatar/portrait_cool.png',
    package: 'gallery',
  );

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d24,
    children: [
      const AvatarGroup(
        children: [
          Avatar(
            children: [
              AvatarImage(image: _warm, semanticLabel: 'Ada Lovelace'),
              AvatarFallback(name: 'Ada Lovelace'),
            ],
          ),
          Avatar(children: [AvatarFallback(name: 'Jo Okafor')]),
          Avatar(
            children: [
              AvatarImage(image: _cool, semanticLabel: 'Mika Kobayashi'),
              AvatarFallback(name: 'Mika Kobayashi'),
            ],
          ),
          Avatar(children: [AvatarFallback(name: 'Sam Reyes')]),
          AvatarGroupCount(child: Text('+3')),
        ],
      ),
      AvatarGroup(
        size: AvatarSize.lg,
        children: [
          for (final name in ['Priya Nair', 'Tomas Berg', 'Lena Fischer'])
            Avatar(children: [AvatarFallback(name: name)]),
          AvatarGroupCount(
            child: Semantics(
              label: 'Invite someone',
              child: const InkIcon('plus'),
            ),
          ),
        ],
      ),
      AvatarGroup(
        size: AvatarSize.sm,
        children: [
          for (final name in [
            'Omar Haddad',
            'Yuki Tanaka',
            'Ines Moreau',
            'Kofi Mensah',
          ])
            Avatar(children: [AvatarFallback(name: name)]),
          const AvatarGroupCount(child: Text('+8')),
        ],
      ),
    ],
  );
}
