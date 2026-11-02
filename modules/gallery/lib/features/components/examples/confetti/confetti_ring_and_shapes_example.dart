import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ConfettiRingAndShapesExample extends StatelessWidget {
  const ConfettiRingAndShapesExample({super.key});

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: Spacing.d16,
    runSpacing: Spacing.d16,
    children: [
      ConfettiTrigger(
        options: const ConfettiOptions(
          spread: 360,
          velocity: 700,
          count: 90,
          shapes: [ConfettiKind.dot, ConfettiKind.strip],
        ),
        builder: (context, burst) => Button(
          variant: ButtonVariant.outline,
          onPressed: burst,
          child: const Text('Ring'),
        ),
      ),
      ConfettiTrigger(
        options: const ConfettiOptions(
          angle: 60,
          spread: 40,
          count: 50,
          shapes: [ConfettiKind.curl],
          drift: 120,
        ),
        builder: (context, burst) => Button(
          variant: ButtonVariant.outline,
          onPressed: burst,
          child: const Text('Streamers'),
        ),
      ),
      ConfettiTrigger(
        options: const ConfettiOptions(
          colors: [ConfettiColor.bubblegum, ConfettiColor.tomato],
          shapes: [ConfettiKind.dot, ConfettiKind.star],
          count: 60,
        ),
        builder: (context, burst) => Button(
          variant: ButtonVariant.outline,
          onPressed: burst,
          child: const Text('Pink'),
        ),
      ),
    ],
  );
}
