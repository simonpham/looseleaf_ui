import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-xs`.
const _maxWidth = Spacing.d320;

class StepperStepsAndFormatExample extends StatefulWidget {
  const StepperStepsAndFormatExample({super.key});

  @override
  State<StepperStepsAndFormatExample> createState() =>
      _StepperStepsAndFormatExampleState();
}

class _StepperStepsAndFormatExampleState
    extends State<StepperStepsAndFormatExample> {
  double? _price = 4.5;
  double? _temp = 20;
  double? _grams = 250;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d28,
          children: [
            _Field(
              label: 'Price',
              stepper: Stepper(
                value: _price,
                onChanged: (value) => setState(() => _price = value),
                min: 0,
                step: 0.5,
                precision: 2,
                format: (value) => '\$${value.toStringAsFixed(2)}',
                parse: (text) => double.tryParse(text.replaceAll(r'$', '')),
                width: Spacing.d176,
                semanticLabel: 'Price',
              ),
            ),
            _Field(
              label: 'Oven (wheel steps it while focused)',
              stepper: Stepper(
                value: _temp,
                onChanged: (value) => setState(() => _temp = value),
                min: -10,
                max: 250,
                wheel: true,
                format: (value) => '${value.toInt()} C',
                parse: (text) =>
                    int.tryParse(text.split(' ').first)?.toDouble(),
                width: Spacing.d176,
                semanticLabel: 'Oven',
              ),
            ),
            _Field(
              label: 'Flour, in fives',
              stepper: Stepper(
                value: _grams,
                onChanged: (value) => setState(() => _grams = value),
                min: 0,
                max: 1000,
                step: 5,
                largeStep: 50,
                snap: true,
                format: (value) => '${value.toInt()} g',
                parse: (text) =>
                    int.tryParse(text.split(' ').first)?.toDouble(),
                width: Spacing.d176,
                semanticLabel: 'Flour, in fives',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.stepper});

  final String label;
  final Widget stepper;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d8,
    children: [
      Label(child: Text(label)),
      stepper,
    ],
  );
}
