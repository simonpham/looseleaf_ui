import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

enum _Mode {
  calm(fps: 3, strength: 0.6),
  normal(fps: 6, strength: 1),
  restless(fps: 12, strength: 2.2);

  const _Mode({required this.fps, required this.strength});

  final double fps;
  final double strength;
}

class BoilControlsExample extends StatefulWidget {
  const BoilControlsExample({super.key});

  @override
  State<BoilControlsExample> createState() => _BoilControlsExampleState();
}

class _BoilControlsExampleState extends State<BoilControlsExample> {
  _Mode _mode = _Mode.normal;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 576),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d20,
      children: [
        Boil(
          fps: _mode.fps,
          strength: _mode.strength,
          builder: (context, frame, seed) => Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: Spacing.d16,
            runSpacing: Spacing.d16,
            children: [
              Doodle('mushroom', size: 72, seed: seed('mushroom')),
              Button(
                size: ButtonSize.lg,
                seed: seed('join'),
                onPressed: () {},
                child: const Text('Join the club'),
              ),
              SizedBox(
                width: Spacing.d192,
                child: Input(
                  semanticLabel: 'Email',
                  placeholder: 'you@example.com',
                  seed: seed('email'),
                ),
              ),
            ],
          ),
        ),
        Semantics(
          container: true,
          label: 'How nervous',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Spacing.d16,
            children: [
              for (final mode in _Mode.values)
                Button(
                  size: ButtonSize.sm,
                  variant: switch (mode == _mode) {
                    true => ButtonVariant.secondary,
                    false => ButtonVariant.outline,
                  },
                  onPressed: () => setState(() => _mode = mode),
                  child: Text(mode.name),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
