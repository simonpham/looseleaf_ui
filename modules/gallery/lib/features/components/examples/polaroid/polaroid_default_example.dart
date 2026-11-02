import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PolaroidDefaultExample extends StatelessWidget {
  const PolaroidDefaultExample({super.key});

  @override
  Widget build(BuildContext context) => const Polaroid(
    tape: PaperTape.top,
    seed: 'august',
    children: [
      PolaroidImage(
        scene: PolaroidScene.hills,
        label: 'Hills, a tree and a sun',
        seed: 'hills',
      ),
      PolaroidCaption(Text('august, finally')),
    ],
  );
}
