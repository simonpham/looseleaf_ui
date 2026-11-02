import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class AlertDialogDeleteNotebookExample extends StatelessWidget {
  const AlertDialogDeleteNotebookExample({super.key});

  @override
  Widget build(BuildContext context) => AlertDialog(
    content: const AlertDialogContent(
      tone: AlertDialogTone.danger,
      seed: 'delete',
      children: [
        AlertDialogHeader(
          children: [
            AlertDialogMedia(
              tone: AlertMediaTone.danger,
              child: InkIcon('trash'),
            ),
            AlertDialogTitle(Text('Delete this notebook?')),
            AlertDialogDescription(
              Text(
                'This will permanently delete “Field notes” and its 48 pages. You cannot undo this.',
              ),
            ),
          ],
        ),
        AlertDialogFooter(
          children: [
            AlertDialogCancel(child: Text('Cancel')),
            AlertDialogAction(
              variant: ButtonVariant.destructive,
              child: Text('Delete notebook'),
            ),
          ],
        ),
      ],
    ),
    child: AlertDialogTrigger.builder(
      builder: (context, dialog) => Button(
        variant: ButtonVariant.destructive,
        onPressed: dialog.show,
        child: const Text('Delete notebook'),
      ),
    ),
  );
}
