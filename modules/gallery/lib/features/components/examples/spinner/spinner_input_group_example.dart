import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SpinnerInputGroupExample extends StatelessWidget {
  const SpinnerInputGroupExample({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 448),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d16,
      children: [
        InputGroup(
          disabled: true,
          children: [
            InputGroupInput(
              placeholder: 'Send a message...',
              semanticLabel: 'Send a message',
            ),
            InputGroupAddon(align: InputGroupAlign.inlineEnd, child: Spinner()),
          ],
        ),
        InputGroup(
          disabled: true,
          children: [
            InputGroupTextarea(
              placeholder: 'Send a message...',
              semanticLabel: 'Send a message, long form',
            ),
            InputGroupAddon(
              align: InputGroupAlign.blockEnd,
              child: Row(
                spacing: Spacing.d8,
                children: [
                  Spinner(),
                  Text('Validating...'),
                  Spacer(),
                  InputGroupButton(
                    variant: ButtonVariant.primary,
                    semanticLabel: 'Send',
                    child: InkIcon('arrow-up'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
