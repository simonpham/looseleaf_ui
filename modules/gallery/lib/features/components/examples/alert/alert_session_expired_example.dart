import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class AlertSessionExpiredExample extends StatefulWidget {
  const AlertSessionExpiredExample({super.key});

  @override
  State<AlertSessionExpiredExample> createState() =>
      _AlertSessionExpiredExampleState();
}

class _AlertSessionExpiredExampleState
    extends State<AlertSessionExpiredExample> {
  bool _again = false;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 576),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d20,
      children: [
        const Alert(
          variant: AlertTone.destructive,
          icon: InkIcon('circle-alert'),
          children: [
            AlertTitle(Text('Error')),
            AlertDescription(
              Text('Your session has expired. Please log in again.'),
            ),
          ],
        ),
        switch (_again) {
          true => const Alert(
            variant: AlertTone.success,
            icon: InkIcon('circle-check'),
            children: [
              AlertTitle(Text('Signed in')),
              AlertDescription(
                Text('Welcome back. Your drafts are where you left them.'),
              ),
            ],
          ),
          false => Alert(
            variant: AlertTone.destructive,
            icon: const InkIcon('circle-alert'),
            children: [
              const AlertTitle(Text('You were signed out')),
              AlertDescription.children([
                const Text('It has been a while since your last visit.'),
                Padding(
                  padding: const EdgeInsets.only(top: Spacing.d8),
                  child: Button(
                    size: ButtonSize.sm,
                    variant: ButtonVariant.outline,
                    onPressed: () => setState(() => _again = true),
                    child: const Text('Log in again'),
                  ),
                ),
              ]),
            ],
          ),
        },
      ],
    ),
  );
}
