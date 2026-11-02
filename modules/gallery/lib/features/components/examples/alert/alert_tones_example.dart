import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class AlertTonesExample extends StatelessWidget {
  const AlertTonesExample({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 576),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d20,
      children: [
        Alert(
          variant: AlertTone.info,
          icon: InkIcon('info'),
          children: [
            AlertTitle(Text('New in this version')),
            AlertDescription(
              Text(
                'Tabs can now stand up on their side, like binder dividers.',
              ),
            ),
          ],
        ),
        Alert(
          variant: AlertTone.success,
          icon: InkIcon('circle-check'),
          children: [
            AlertTitle(Text('Saved')),
            AlertDescription(
              Text('Your changes are on the page. Nothing else to do.'),
            ),
          ],
        ),
        Alert(
          variant: AlertTone.warning,
          icon: InkIcon('triangle-alert'),
          children: [
            AlertTitle(Text('Careful with the highlighter')),
            AlertDescription(
              Text('Two coats will bleed through to the next page.'),
            ),
          ],
        ),
        Alert(
          variant: AlertTone.info,
          children: [
            AlertDescription(
              Text(
                'No icon and no title: just the box, the rule and one line.',
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
