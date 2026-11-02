import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/features_01/features_01.dart';

/// Both looks of the features section, one above the other, like upstream's
/// preview (`src/docs/content/blocks/features-01.tsx`).
class Features01Preview extends StatelessWidget {
  const Features01Preview({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Features01Block(),
      Features01Block(
        variant: Features01Variant.bento,
        title: 'Or pin it all to a corkboard',
        lead: 'The same section, five things on cork.',
      ),
    ],
  );
}
