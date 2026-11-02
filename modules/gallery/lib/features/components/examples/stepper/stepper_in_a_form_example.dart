import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-sm`.
const _maxWidth = Spacing.d384;

class StepperInAFormExample extends StatefulWidget {
  const StepperInAFormExample({super.key});

  @override
  State<StepperInAFormExample> createState() => _StepperInAFormExampleState();
}

class _StepperInAFormExampleState extends State<StepperInAFormExample> {
  double? _adults = 2;
  double? _kids = 0;
  double? _highChairs = 3;
  String? _sent;

  void _reset() => setState(() {
    _adults = 2;
    _kids = 0;
    _highChairs = 3;
    _sent = null;
  });

  void _book() => setState(
    () => _sent =
        '${(_adults ?? 1).toInt()} adults, ${(_kids ?? 0).toInt()} kids',
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          seed: 'party',
          tape: PaperTape.corner,
          children: [
            const CardHeader(
              children: [
                CardTitle(Text('Party of ...')),
                CardDescription(Text('How many are coming?')),
              ],
            ),
            CardContent(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.d16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.d16,
                  children: [
                    _Row(
                      label: 'Adults',
                      stepper: Stepper(
                        value: _adults,
                        onChanged: (value) => setState(() => _adults = value),
                        min: 1,
                        max: 12,
                        required: true,
                        semanticLabel: 'Adults',
                      ),
                    ),
                    _Row(
                      label: 'Kids',
                      stepper: Stepper(
                        value: _kids,
                        onChanged: (value) => setState(() => _kids = value),
                        min: 0,
                        max: 12,
                        semanticLabel: 'Kids',
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: Spacing.d8,
                      children: [
                        _Row(
                          label: 'High chairs (we have two)',
                          stepper: Stepper(
                            value: _highChairs,
                            onChanged: (value) =>
                                setState(() => _highChairs = value),
                            min: 0,
                            max: 5,
                            invalid: true,
                            semanticLabel: 'High chairs. We only have two.',
                          ),
                        ),
                        Text(
                          'We only have two.',
                          textAlign: TextAlign.end,
                          style: theme.typography.interface(
                            cssSize: 14,
                            color: theme.colors.red,
                          ),
                        ),
                      ],
                    ),
                    const _Row(
                      label: 'Rooftop seats',
                      stepper: Stepper(
                        value: 0,
                        disabled: true,
                        semanticLabel: 'Rooftop seats',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            CardFooter(
              divider: true,
              spacing: Spacing.d12,
              children: [
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      _sent ?? 'Nothing sent yet.',
                      style: theme.typography.interface(
                        cssSize: 14,
                        color: theme.colors.inkMuted,
                      ),
                    ),
                  ),
                ),
                Button(
                  variant: ButtonVariant.ghost,
                  onPressed: _reset,
                  child: const Text('Reset'),
                ),
                Button(onPressed: _book, child: const Text('Book')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.stepper});

  final String label;
  final Widget stepper;

  @override
  Widget build(BuildContext context) => Row(
    spacing: Spacing.d12,
    children: [
      Expanded(child: Label(child: Text(label))),
      stepper,
    ],
  );
}
