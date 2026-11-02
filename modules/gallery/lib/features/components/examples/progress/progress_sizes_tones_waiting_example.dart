import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ProgressSizesTonesWaitingExample extends StatelessWidget {
  const ProgressSizesTonesWaitingExample({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: Spacing.d112 * 4),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d16,
      children: [
        Progress(value: 45, size: ProgressSize.sm, semanticLabel: 'Small'),
        Progress(value: 45, semanticLabel: 'Default'),
        Progress(value: 45, size: ProgressSize.lg, semanticLabel: 'Large'),
        Progress(
          value: 70,
          tone: ProgressTone.hi,
          semanticLabel: 'Highlighter',
        ),
        Progress(value: 70, tone: ProgressTone.green, semanticLabel: 'Grass'),
        Progress(value: 70, tone: ProgressTone.blue, semanticLabel: 'Sky'),
        Progress(semanticLabel: 'Waiting'),
      ],
    ),
  );
}
