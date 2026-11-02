import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class AlertDefaultExample extends StatelessWidget {
  const AlertDefaultExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 576),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d20,
        children: [
          const Alert(
            icon: InkIcon('info'),
            children: [
              AlertTitle(Text('Heads up!')),
              AlertDescription(
                Text('You can add components to your app using the cli.'),
              ),
            ],
          ),
          Alert(
            variant: AlertTone.destructive,
            icon: const InkIcon('circle-alert'),
            children: [
              const AlertTitle(Text('Unable to process your payment.')),
              AlertDescription.children([
                const Text(
                  'Please verify your billing information and try again.',
                ),
                for (final item in const [
                  'Check your card details',
                  'Ensure sufficient funds',
                  'Verify billing address',
                ])
                  Text(
                    '•  $item',
                    style: theme.typography.interface(cssSize: 14),
                  ),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
