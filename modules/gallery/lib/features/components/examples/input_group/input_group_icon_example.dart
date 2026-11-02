import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputGroupIconExample extends StatelessWidget {
  const InputGroupIconExample({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 384),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d24,
      children: [
        InputGroup(
          children: [
            InputGroupInput(placeholder: 'Search...', semanticLabel: 'Search'),
            InputGroupAddon(child: InkIcon('search')),
          ],
        ),
        InputGroup(
          children: [
            InputGroupInput(
              placeholder: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              semanticLabel: 'Email',
            ),
            InputGroupAddon(child: InkIcon('mail')),
          ],
        ),
        InputGroup(
          children: [
            InputGroupInput(
              placeholder: 'Card number',
              semanticLabel: 'Card number',
            ),
            InputGroupAddon(child: InkIcon('credit-card')),
            InputGroupAddon(
              align: InputGroupAlign.inlineEnd,
              child: InkIcon('check'),
            ),
          ],
        ),
        InputGroup(
          children: [
            InputGroupInput(
              placeholder: 'Card number',
              semanticLabel: 'Card number, second',
            ),
            InputGroupAddon(
              align: InputGroupAlign.inlineEnd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d8,
                children: [InkIcon('star'), InkIcon('info')],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
