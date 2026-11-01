import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _rings = <ChartRow>[
  {'name': 'move', 'value': 78},
  {'name': 'exercise', 'value': 52},
  {'name': 'stand', 'value': 91},
];

const _config = {
  'move': ChartSeriesConfig(label: 'Move'),
  'exercise': ChartSeriesConfig(label: 'Exercise'),
  'stand': ChartSeriesConfig(label: 'Stand'),
};

class ChartRadialAndGaugeExample extends StatelessWidget {
  const ChartRadialAndGaugeExample({super.key});

  @override
  Widget build(BuildContext context) => Row(
    spacing: Spacing.d32,
    children: [
      Expanded(
        child: ChartContainer(
          config: _config,
          aspectRatio: 1,
          children: [
            RadialChart(
              data: _rings,
              nameKey: 'name',
              valueKey: 'value',
              label: 'Daily rings',
              centerLabel: (_) =>
                  const ChartCenterLabel(value: '78%', label: 'of goal'),
            ),
            const ChartTooltip(content: ChartTooltipContent(hideLabel: true)),
          ],
        ),
      ),
      Expanded(
        child: Gauge(
          value: 68,
          label: 'Server load',
          zones: const [
            GaugeZoneInput(to: 40, tone: GaugeTone.good),
            GaugeZoneInput(to: 75, tone: GaugeTone.warn),
            GaugeZoneInput(to: 100, tone: GaugeTone.bad),
          ],
          valueFormatter: (value) => '${formatNumber(value)}%',
        ),
      ),
    ],
  );
}
