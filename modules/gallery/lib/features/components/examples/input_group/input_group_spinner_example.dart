import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputGroupSpinnerExample extends StatelessWidget {
  const InputGroupSpinnerExample({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 384),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d16,
      children: [
        InputGroup(
          disabled: true,
          children: [
            InputGroupInput(
              placeholder: 'Searching...',
              semanticLabel: 'Searching',
            ),
            InputGroupAddon(align: InputGroupAlign.inlineEnd, child: Spinner()),
          ],
        ),
        InputGroup(
          disabled: true,
          children: [
            InputGroupInput(
              placeholder: 'Processing...',
              semanticLabel: 'Processing',
            ),
            InputGroupAddon(child: Spinner()),
          ],
        ),
        InputGroup(
          disabled: true,
          children: [
            InputGroupInput(
              placeholder: 'Saving changes...',
              semanticLabel: 'Saving changes',
            ),
            InputGroupAddon(
              align: InputGroupAlign.inlineEnd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d8,
                children: [
                  InputGroupText(child: Text('Saving...')),
                  Spinner(),
                ],
              ),
            ),
          ],
        ),
        InputGroup(
          disabled: true,
          children: [
            InputGroupInput(
              placeholder: 'Refreshing data...',
              semanticLabel: 'Refreshing data',
            ),
            InputGroupAddon(child: Spinner(variant: SpinnerVariant.loops)),
            InputGroupAddon(
              align: InputGroupAlign.inlineEnd,
              child: InputGroupText(child: Text('Please wait...')),
            ),
          ],
        ),
      ],
    ),
  );
}
