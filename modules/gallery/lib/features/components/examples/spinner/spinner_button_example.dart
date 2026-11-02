import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SpinnerButtonExample extends StatelessWidget {
  const SpinnerButtonExample({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    mainAxisSize: MainAxisSize.min,
    spacing: Spacing.d16,
    children: [
      Button(
        disabled: true,
        size: ButtonSize.sm,
        leading: Spinner(),
        child: Text('Loading...'),
      ),
      Button(
        variant: ButtonVariant.outline,
        disabled: true,
        size: ButtonSize.sm,
        leading: Spinner(),
        child: Text('Please wait'),
      ),
      Button(
        variant: ButtonVariant.secondary,
        disabled: true,
        size: ButtonSize.sm,
        leading: Spinner(),
        child: Text('Processing'),
      ),
    ],
  );
}
