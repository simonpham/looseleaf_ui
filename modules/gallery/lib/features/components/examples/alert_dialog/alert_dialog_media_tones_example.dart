import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class AlertDialogMediaTonesExample extends StatelessWidget {
  const AlertDialogMediaTonesExample({super.key});

  static const _kinds = [
    (
      tone: AlertMediaTone.neutral,
      trigger: 'Publish',
      icon: 'circle-check',
      title: 'Publish now?',
      body: 'Everyone with the link will be able to read it. You can unpublish later.',
      ok: 'Publish',
    ),
    (
      tone: AlertMediaTone.info,
      trigger: 'Sign out',
      icon: 'info',
      title: 'Sign out everywhere?',
      body: 'You will be signed out of every device, including this one.',
      ok: 'Sign out',
    ),
    (
      tone: AlertMediaTone.danger,
      trigger: 'Clear history',
      icon: 'triangle-alert',
      title: 'Clear all history?',
      body: 'Every search and every draft will be removed from this device.',
      ok: 'Clear it',
    ),
  ];

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: Spacing.d12,
    runSpacing: Spacing.d12,
    children: [
      for (final kind in _kinds)
        AlertDialog(
          content: AlertDialogContent(
            seed: kind.tone.id,
            children: [
              AlertDialogHeader(
                children: [
                  AlertDialogMedia(tone: kind.tone, child: InkIcon(kind.icon)),
                  AlertDialogTitle(Text(kind.title)),
                  AlertDialogDescription(Text(kind.body)),
                ],
              ),
              AlertDialogFooter(
                children: [
                  const AlertDialogCancel(child: Text('Not yet')),
                  AlertDialogAction(
                    variant: switch (kind.tone) {
                      AlertMediaTone.danger => ButtonVariant.destructive,
                      _ => ButtonVariant.primary,
                    },
                    child: Text(kind.ok),
                  ),
                ],
              ),
            ],
          ),
          child: AlertDialogTrigger.builder(
            builder: (context, dialog) => Button(
              variant: ButtonVariant.outline,
              onPressed: dialog.show,
              child: Text(kind.trigger),
            ),
          ),
        ),
    ],
  );
}
