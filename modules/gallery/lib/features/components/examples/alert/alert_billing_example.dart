import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class AlertBillingExample extends StatefulWidget {
  const AlertBillingExample({super.key});

  @override
  State<AlertBillingExample> createState() => _AlertBillingExampleState();
}

class _AlertBillingExampleState extends State<AlertBillingExample> {
  bool _failed = true;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: Card(
        seed: 'billing',
        children: [
          const CardHeader(
            children: [
              CardTitle(Text('Billing')),
              CardDescription(
                Text('Your plan renews on the first of the month.'),
              ),
            ],
          ),
          CardContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d16,
              children: [
                switch (_failed) {
                  true => Alert(
                    variant: AlertTone.destructive,
                    icon: const InkIcon('circle-alert'),
                    children: [
                      const AlertTitle(
                        Text('Your last payment did not go through'),
                      ),
                      AlertDescription.children([
                        const Text(
                          'The card ending 4242 was declined. We will try again in three days.',
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: Spacing.d8),
                          child: Button(
                            size: ButtonSize.sm,
                            variant: ButtonVariant.outline,
                            onPressed: () => setState(() => _failed = false),
                            child: const Text('Update card'),
                          ),
                        ),
                      ]),
                    ],
                  ),
                  false => const Alert(
                    variant: AlertTone.success,
                    icon: InkIcon('circle-check'),
                    children: [
                      AlertTitle(Text('Card updated')),
                      AlertDescription(
                        Text('The next payment will use the new card.'),
                      ),
                    ],
                  ),
                },
                Text(
                  r'Team plan, 5 seats, $250.00 a month.',
                  style: theme.typography.interface(
                    cssSize: 14,
                    color: theme.colors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          CardFooter(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Button(
                variant: ButtonVariant.ghost,
                size: ButtonSize.sm,
                onPressed: () => setState(() => _failed = true),
                child: const Text('Reset the demo'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
