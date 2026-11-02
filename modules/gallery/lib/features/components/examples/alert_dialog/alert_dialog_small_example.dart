import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class AlertDialogSmallExample extends StatelessWidget {
  const AlertDialogSmallExample({super.key});

  @override
  Widget build(BuildContext context) => AlertDialog(
    content: const AlertDialogContent(
      size: AlertDialogSize.small,
      seed: 'discard',
      children: [
        AlertDialogHeader(
          children: [
            AlertDialogMedia(child: InkIcon('circle-question-mark')),
            AlertDialogTitle(Text('Discard changes?')),
            AlertDialogDescription(
              Text('You have unsaved edits. They will be lost.'),
            ),
          ],
        ),
        AlertDialogFooter(
          children: [
            AlertDialogCancel(child: Text('Keep editing')),
            AlertDialogAction(child: Text('Discard')),
          ],
        ),
      ],
    ),
    child: AlertDialogTrigger.builder(
      builder: (context, dialog) => Button(
        variant: ButtonVariant.outline,
        onPressed: dialog.show,
        child: const Text('Discard draft'),
      ),
    ),
  );
}
