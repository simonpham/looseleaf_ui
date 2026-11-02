import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SpinnerSizeExample extends StatelessWidget {
  const SpinnerSizeExample({super.key});

  @override
  Widget build(BuildContext context) => const Row(
    mainAxisSize: MainAxisSize.min,
    spacing: Spacing.d24,
    children: [
      Spinner(size: Spacing.d12, semanticLabel: 'Loading, extra small'),
      Spinner(size: Spacing.d16, semanticLabel: 'Loading, small'),
      Spinner(size: Spacing.d24, semanticLabel: 'Loading, medium'),
      Spinner(size: Spacing.d32, semanticLabel: 'Loading, large'),
    ],
  );
}
