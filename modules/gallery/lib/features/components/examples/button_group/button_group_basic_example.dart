import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ButtonGroupBasicExample extends StatelessWidget {
  const ButtonGroupBasicExample({super.key});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Spacing.d40,
    runSpacing: Spacing.d24,
    children: [
      ButtonGroup(
        semanticLabel: 'Range',
        children: [
          for (final label in const ['Years', 'Months', 'Days'])
            Button(
              variant: ButtonVariant.outline,
              onPressed: () {},
              child: Text(label),
            ),
        ],
      ),
      ButtonGroup(
        semanticLabel: 'Page',
        children: [
          for (final (icon, label) in const [
            ('chevron-left', 'Previous'),
            ('search', 'Search'),
            ('chevron-right', 'Next'),
          ])
            Button(
              variant: ButtonVariant.outline,
              size: ButtonSize.icon,
              semanticLabel: label,
              onPressed: () {},
              child: InkIcon(icon),
            ),
        ],
      ),
      ButtonGroup(
        orientation: SeparatorOrientation.vertical,
        semanticLabel: 'Zoom',
        children: [
          Button(
            variant: ButtonVariant.outline,
            size: ButtonSize.icon,
            semanticLabel: 'Zoom in',
            onPressed: () {},
            child: const InkIcon('plus'),
          ),
          Button(
            variant: ButtonVariant.outline,
            size: ButtonSize.icon,
            semanticLabel: 'Zoom out',
            onPressed: () {},
            child: const InkIcon('minus'),
          ),
        ],
      ),
    ],
  );
}
