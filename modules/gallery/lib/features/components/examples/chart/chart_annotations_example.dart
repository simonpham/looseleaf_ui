import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _week = <ChartRow>[
  {'day': 'Mon', 'sales': 12},
  {'day': 'Tue', 'sales': 19},
  {'day': 'Wed', 'sales': 8},
  {'day': 'Thu', 'sales': 24},
  {'day': 'Fri', 'sales': 16},
  {'day': 'Sat', 'sales': 21},
  {'day': 'Sun', 'sales': 14},
];

const _config = {'sales': ChartSeriesConfig(label: 'Sales')};

const _highlights = <String, List<ChartHighlight>>{
  'best day': [],
  'rainy day': [ChartHighlight(from: 'Tue', to: 'Wed', text: 'storm')],
  'both ends': [ChartHighlight(from: 'Fri', to: 'Sun', text: 'weekend')],
};

const _notes = <String, List<ChartAnnotation>>{
  'best day': [
    ChartAnnotation(at: 'max', text: 'best day!', pen: NotePen.blue),
  ],
  'rainy day': [
    ChartAnnotation(
      at: 'Wed',
      text: 'rainy day',
      pen: NotePen.ink,
      shape: NoteShape.underline,
      dx: 44,
      dy: -56,
    ),
  ],
  'both ends': [
    ChartAnnotation(
      at: 'first',
      text: 'slow start',
      pen: NotePen.red,
      shape: NoteShape.loop,
    ),
    ChartAnnotation(
      at: 'last',
      text: 'still going',
      pen: NotePen.green,
      shape: NoteShape.loop,
    ),
  ],
};

class ChartAnnotationsExample extends StatefulWidget {
  const ChartAnnotationsExample({super.key});

  @override
  State<ChartAnnotationsExample> createState() =>
      _ChartAnnotationsExampleState();
}

class _ChartAnnotationsExampleState extends State<ChartAnnotationsExample> {
  String _which = 'best day';

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: Spacing.d12,
    children: [
      Semantics(
        container: true,
        label: 'Annotation',
        child: Wrap(
          spacing: Spacing.d8,
          runSpacing: Spacing.d8,
          children: [
            for (final key in _notes.keys)
              Button(
                size: ButtonSize.sm,
                variant: switch (key == _which) {
                  true => ButtonVariant.primary,
                  false => ButtonVariant.outline,
                },
                onPressed: () => setState(() => _which = key),
                child: Text(key),
              ),
          ],
        ),
      ),
      ChartContainer(
        config: _config,
        height: Spacing.d256,
        children: [
          BarChart(
            data: _week,
            xKey: 'day',
            label: 'Sales per day',
            annotations: _notes[_which] ?? const [],
            highlights: _highlights[_which] ?? const [],
            references: const [
              ChartReference(y: 18, label: 'goal', pen: NotePen.red),
            ],
          ),
          const ChartTooltip(),
        ],
      ),
      const ChartContainer(
        config: _config,
        height: Spacing.d96 * 2,
        children: [
          LineChart(
            data: _week,
            xKey: 'day',
            label: 'Sales per day, as a line',
            annotations: [
              ChartAnnotation(
                at: 'min',
                text: 'dip',
                pen: NotePen.red,
                dx: -60,
                dy: -8,
              ),
              ChartAnnotation(
                at: 'max',
                text: 'peak',
                pen: NotePen.blue,
                dx: 60,
                dy: -8,
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
