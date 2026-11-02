import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PolaroidDevelopingExample extends StatefulWidget {
  const PolaroidDevelopingExample({super.key});

  @override
  State<PolaroidDevelopingExample> createState() =>
      _PolaroidDevelopingExampleState();
}

class _PolaroidDevelopingExampleState extends State<PolaroidDevelopingExample> {
  int _shot = 0;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Spacing.d16),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.d32,
        children: [
          Polaroid(
            key: ValueKey(_shot),
            seed: 'dev',
            tape: PaperTape.top,
            children: const [
              PolaroidImage(
                scene: PolaroidScene.sea,
                develop: true,
                seed: 'dev-img',
              ),
              PolaroidCaption(Text('wait for it')),
            ],
          ),
          Button(
            variant: ButtonVariant.secondary,
            onPressed: () => setState(() => _shot++),
            child: const Text('Take another'),
          ),
        ],
      ),
    ),
  );
}
