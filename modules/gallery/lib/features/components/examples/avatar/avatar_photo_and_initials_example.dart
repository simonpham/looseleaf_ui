import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class AvatarPhotoAndInitialsExample extends StatelessWidget {
  const AvatarPhotoAndInitialsExample({super.key});

  static const _warm = AssetImage(
    'lib/features/components/examples/avatar/portrait_warm.png',
    package: 'gallery',
  );
  static const _cool = AssetImage(
    'lib/features/components/examples/avatar/portrait_cool.png',
    package: 'gallery',
  );
  static const _missing = AssetImage('missing-portrait.png');

  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: Spacing.d24,
    runSpacing: Spacing.d24,
    crossAxisAlignment: WrapCrossAlignment.end,
    children: [
      Avatar(
        size: AvatarSize.sm,
        children: [
          AvatarImage(image: _warm, semanticLabel: 'Ada Lovelace'),
          AvatarFallback(name: 'Ada Lovelace'),
        ],
      ),
      Avatar(
        children: [
          AvatarImage(image: _cool, semanticLabel: 'Jo Okafor'),
          AvatarFallback(name: 'Jo Okafor'),
          AvatarBadge(status: AvatarStatus.online),
        ],
      ),
      Avatar(
        size: AvatarSize.lg,
        children: [
          AvatarImage(image: _missing),
          AvatarFallback(name: 'Mika Kobayashi'),
          AvatarBadge(status: AvatarStatus.away),
        ],
      ),
      Avatar(
        size: AvatarSize.xl,
        children: [
          AvatarFallback(name: 'Sam Reyes'),
          AvatarBadge(status: AvatarStatus.busy),
        ],
      ),
    ],
  );
}
