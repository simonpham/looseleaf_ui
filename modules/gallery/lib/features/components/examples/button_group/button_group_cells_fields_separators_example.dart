import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ButtonGroupCellsFieldsSeparatorsExample extends StatelessWidget {
  const ButtonGroupCellsFieldsSeparatorsExample({super.key});

  static const _maxWidth = Spacing.d448;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d24,
      children: [
        ButtonGroup(
          semanticLabel: 'Website',
          children: [
            const ButtonGroupText(child: Text('https://')),
            const Expanded(
              child: Input(placeholder: 'example.com', semanticLabel: 'Host'),
            ),
            Button(onPressed: () {}, child: const Text('Go')),
          ],
        ),
        ButtonGroup(
          semanticLabel: 'Clipboard',
          children: [
            Button(
              variant: ButtonVariant.secondary,
              leading: const InkIcon('copy'),
              onPressed: () {},
              child: const Text('Copy'),
            ),
            const ButtonGroupSeparator(),
            Button(
              variant: ButtonVariant.secondary,
              onPressed: () {},
              child: const Text('Paste'),
            ),
          ],
        ),
        ButtonGroup(
          semanticLabel: 'Save options',
          children: [
            Button(onPressed: () {}, child: const Text('Save')),
            const ButtonGroupSeparator(),
            Button(
              size: ButtonSize.icon,
              semanticLabel: 'More save options',
              onPressed: () {},
              child: const InkIcon('chevron-down'),
            ),
          ],
        ),
        ButtonGroup(
          semanticLabel: 'Weight',
          children: [
            Button(
              variant: ButtonVariant.outline,
              size: ButtonSize.icon,
              semanticLabel: 'Less',
              onPressed: () {},
              child: const InkIcon('minus'),
            ),
            const ButtonGroupText(
              alignment: MainAxisAlignment.center,
              minWidth: Spacing.d56,
              child: Text('250'),
            ),
            Button(
              variant: ButtonVariant.outline,
              size: ButtonSize.icon,
              semanticLabel: 'More',
              onPressed: () {},
              child: const InkIcon('plus'),
            ),
            const ButtonGroupText(child: Text('grams')),
          ],
        ),
      ],
    ),
  );
}
