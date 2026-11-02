import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class StepperQuantityExample extends StatefulWidget {
  const StepperQuantityExample({super.key});

  @override
  State<StepperQuantityExample> createState() => _StepperQuantityExampleState();
}

class _StepperQuantityExampleState extends State<StepperQuantityExample> {
  double? _qty = 2;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d8,
      children: [
        const Label(child: Text('Quantity')),
        Stepper(
          value: _qty,
          onChanged: (value) => setState(() => _qty = value),
          min: 0,
          max: 10,
          semanticLabel: 'Quantity',
        ),
        Semantics(
          liveRegion: true,
          child: Text(
            switch (_qty) {
              null => 'Nothing chosen.',
              final qty => '${qty.toInt()} in the basket.',
            },
            style: theme.typography.interface(
              cssSize: 14,
              color: theme.colors.inkMuted,
            ),
          ),
        ),
      ],
    );
  }
}
