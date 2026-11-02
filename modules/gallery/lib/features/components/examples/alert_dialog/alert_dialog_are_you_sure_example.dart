import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class AlertDialogAreYouSureExample extends StatelessWidget {
  const AlertDialogAreYouSureExample({super.key});

  @override
  Widget build(BuildContext context) => AlertDialog(
    content: const AlertDialogContent(
      seed: 'sure',
      children: [
        AlertDialogHeader(
          children: [
            AlertDialogTitle(Text('Are you absolutely sure?')),
            AlertDialogDescription(
              Text(
                'This action cannot be undone. This will permanently delete your account and remove your data from our servers.',
              ),
            ),
          ],
        ),
        AlertDialogFooter(
          children: [
            AlertDialogCancel(child: Text('Cancel')),
            AlertDialogAction(child: Text('Continue')),
          ],
        ),
      ],
    ),
    child: AlertDialogTrigger.builder(
      builder: (context, dialog) => Button(
        variant: ButtonVariant.outline,
        onPressed: dialog.show,
        child: const Text('Show dialog'),
      ),
    ),
  );
}
