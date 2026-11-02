import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class AlertNoteExample extends StatelessWidget {
  const AlertNoteExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d320),
      child: Alert(
        variant: AlertTone.note,
        seed: 'note',
        children: [
          AlertTitle(
            Text(
              'Reminder',
              style: theme.typography.face(
                KevinSansFace.script,
                cssSize: 24,
                cssLineHeight: 1,
              ),
            ),
          ),
          const AlertDescription(
            Text(
              'Bring the good pens. The desk is mint now, so nothing will match.',
            ),
          ),
        ],
      ),
    );
  }
}
