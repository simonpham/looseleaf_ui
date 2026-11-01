import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Stickers, doodles and Stubby the pencil stub.
class ArtSamples extends StatelessWidget {
  const ArtSamples({super.key});

  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: Spacing.d28,
    runSpacing: Spacing.d28,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Sticker('done', seed: 'art-done'),
      Sticker('sale', seed: 'art-sale'),
      Sticker('hand-point-right', seed: 'art-hand'),
      Doodle('star', seed: 'art-star'),
      Doodle('sun', seed: 'art-sun'),
      Doodle('flower', seed: 'art-flower'),
      Mascot(seed: 'art-idle'),
      Mascot(pose: 'think', seed: 'art-think'),
    ],
  );
}
