import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class AlertIconAndTitleExample extends StatelessWidget {
  const AlertIconAndTitleExample({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 576),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d20,
      children: [
        Alert(
          variant: AlertTone.success,
          icon: InkIcon('circle-check'),
          children: [
            AlertTitle(Text('Success! Your changes have been saved')),
            AlertDescription(
              Text('This is an alert with icon, title and description.'),
            ),
          ],
        ),
        Alert(
          icon: InkIcon('sparkles'),
          children: [
            AlertTitle(
              Text('This alert has a title and an icon. No description.'),
            ),
          ],
        ),
        Alert(
          variant: AlertTone.info,
          icon: InkIcon('lightbulb'),
          children: [
            AlertDescription(
              Text('An icon and one sentence, with no title: a quiet tip.'),
            ),
          ],
        ),
      ],
    ),
  );
}
