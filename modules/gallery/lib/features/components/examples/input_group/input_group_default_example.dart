import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputGroupDefaultExample extends StatelessWidget {
  const InputGroupDefaultExample({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: Spacing.d384),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d16,
      children: [
        InputGroup(
          children: [
            InputGroupAddon(child: InkIcon('search')),
            InputGroupInput(
              placeholder: 'Search the notebook',
              semanticLabel: 'Search',
            ),
            InputGroupAddon(
              align: InputGroupAlign.inlineEnd,
              child: Text('12 results'),
            ),
          ],
        ),
        InputGroup(
          children: [
            InputGroupAddon(child: InputGroupText(child: Text('https://'))),
            InputGroupInput(
              placeholder: 'field-notes',
              semanticLabel: 'Site name',
            ),
            InputGroupAddon(
              align: InputGroupAlign.inlineEnd,
              child: InputGroupText(child: Text('.looseleaf.dev')),
            ),
          ],
        ),
        InputGroup(
          children: [
            InputGroupAddon(child: InkIcon('dollar-sign')),
            InputGroupInput(
              placeholder: '0.00',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              semanticLabel: 'Amount',
            ),
            InputGroupAddon(
              align: InputGroupAlign.inlineEnd,
              child: InputGroupText(child: Text('USD')),
            ),
          ],
        ),
      ],
    ),
  );
}
