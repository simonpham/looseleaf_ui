import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-lg`.
const _maxWidth = 512.0;

/// Below this width the tallies hide (`hidden sm:inline-block`).
const _tallyWidth = 440.0;

const _lines = [
  (id: 'pencils', name: 'Beeswax pencils', price: 4.5, qty: 7.0),
  (id: 'tape', name: 'Washi tape', price: 3.0, qty: 2.0),
  (id: 'paper', name: 'Graph paper pad', price: 6.25, qty: 1.0),
];

class StepperCartLinesExample extends StatefulWidget {
  const StepperCartLinesExample({super.key});

  @override
  State<StepperCartLinesExample> createState() =>
      _StepperCartLinesExampleState();
}

class _StepperCartLinesExampleState extends State<StepperCartLinesExample> {
  late final Map<String, double?> _qty = {
    for (final line in _lines) line.id: line.qty,
  };

  double get _total => _lines.fold(
    0,
    (sum, line) => sum + (_qty[line.id] ?? 0) * line.price,
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final total = _total;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          seed: 'cart',
          tape: PaperTape.top,
          children: [
            const CardHeader(
              children: [
                CardTitle(Text('Your basket')),
                CardDescription(Text('Hold the plus to run up a big order.')),
              ],
            ),
            CardContent(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final showTally = constraints.maxWidth >= _tallyWidth;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: Spacing.d16),
                    child: Column(
                      spacing: Spacing.d16,
                      children: [
                        for (final line in _lines)
                          Row(
                            spacing: Spacing.d16,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      line.name,
                                      style: theme.typography.face(
                                        KevinSansFace.hand,
                                        cssSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      '\$${line.price.toStringAsFixed(2)} each'
                                      '${switch (_qty[line.id] ?? 0) {
                                        0 => ' (none)',
                                        _ => '',
                                      }}',
                                      style: theme.typography.interface(
                                        cssSize: 14,
                                        color: theme.colors.inkMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (showTally) StepperTally(value: _qty[line.id]),
                              Stepper(
                                value: _qty[line.id],
                                onChanged: (value) =>
                                    setState(() => _qty[line.id] = value),
                                min: 0,
                                max: 99,
                                semanticLabel: '${line.name} quantity',
                                decrementLabel: 'Fewer ${line.name}',
                                incrementLabel: 'More ${line.name}',
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            CardFooter(
              divider: true,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: Spacing.d12,
              children: [
                Semantics(
                  liveRegion: true,
                  child: Text(
                    'Total \$${total.toStringAsFixed(2)}',
                    style: theme.typography.title(cssSize: 24),
                  ),
                ),
                Button(
                  disabled: total == 0,
                  onPressed: () {},
                  child: const Text('Check out'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
