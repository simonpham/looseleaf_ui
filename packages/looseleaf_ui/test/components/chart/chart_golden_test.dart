import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';
import '../../support/paper_panel.dart';
import 'chart_samples.dart';

Widget _cell(double width, double height, Widget child) =>
    SizedBox(width: width, height: height, child: child);

Widget _bar() => _cell(
  448,
  256,
  const ChartContainer(
    config: {'sales': ChartSeriesConfig(label: 'Sales')},
    aspectRatio: null,
    children: [
      BarChart(
        data: ChartSamples.sales,
        xKey: 'day',
        seed: 'bar',
        animate: false,
        label: 'Units sold per day',
        annotations: [
          ChartAnnotation(at: 'max', text: 'best day!', pen: NotePen.blue),
        ],
      ),
      ChartTooltip(defaultIndex: 1),
    ],
  ),
);

Widget _xy() => Wrap(
  spacing: Spacing.d24,
  runSpacing: Spacing.d24,
  children: [
    _cell(
      440,
      288,
      const ChartContainer(
        config: ChartSamples.devices,
        aspectRatio: null,
        children: [
          LineChart(
            data: ChartSamples.visitors,
            xKey: 'month',
            seed: 'line',
            animate: false,
            annotations: [
              ChartAnnotation(
                at: 'max',
                series: 'desktop',
                text: 'launch',
                pen: NotePen.red,
              ),
            ],
          ),
          ChartTooltip(
            defaultIndex: 2,
            content: ChartTooltipContent(
              indicator: ChartTooltipIndicator.line,
            ),
          ),
          ChartLegend(),
        ],
      ),
    ),
    _cell(
      440,
      288,
      const ChartContainer(
        config: ChartSamples.devices,
        aspectRatio: null,
        patterns: ChartPatterns.auto,
        hiddenSeries: ['tablet'],
        children: [
          ChartLegend(verticalAlign: ChartLegendAlign.top),
          AreaChart(
            data: ChartSamples.visitors,
            xKey: 'month',
            stacked: true,
            seed: 'area',
            animate: false,
          ),
        ],
      ),
    ),
    _cell(
      440,
      288,
      const ChartContainer(
        config: ChartSamples.devices,
        aspectRatio: null,
        children: [
          BarChart(
            data: ChartSamples.visitors,
            xKey: 'month',
            series: ['desktop', 'mobile'],
            horizontal: true,
            seed: 'hbar',
            animate: false,
          ),
          ChartTooltip(
            defaultIndex: 3,
            content: ChartTooltipContent(
              indicator: ChartTooltipIndicator.dashed,
            ),
          ),
        ],
      ),
    ),
    _cell(
      440,
      288,
      const ScatterChart(
        data: ChartSamples.points,
        xKey: 'height',
        seed: 'scatter',
        animate: false,
        references: [ChartReference(y: 70, label: 'goal')],
      ),
    ),
  ],
);

Widget _polar() => Wrap(
  spacing: Spacing.d24,
  runSpacing: Spacing.d24,
  crossAxisAlignment: WrapCrossAlignment.center,
  children: [
    _cell(
      320,
      360,
      const ChartContainer(
        config: ChartSamples.browserConfig,
        aspectRatio: null,
        children: [
          PieChart(
            data: ChartSamples.browsers,
            nameKey: 'browser',
            valueKey: 'visitors',
            seed: 'pie',
            animate: false,
          ),
          ChartTooltip(
            defaultIndex: 0,
            content: ChartTooltipContent(hideLabel: true),
          ),
          ChartLegend(),
        ],
      ),
    ),
    _cell(
      320,
      360,
      ChartContainer(
        config: ChartSamples.browserConfig,
        aspectRatio: null,
        children: [
          DonutChart(
            data: ChartSamples.browsers,
            nameKey: 'browser',
            valueKey: 'visitors',
            seed: 'donut',
            animate: false,
            centerLabel: (info) => ChartCenterLabel(
              value: formatNumber(info.active?.value ?? info.total),
              label: info.active?.name ?? 'visitors',
            ),
          ),
          const ChartLegend(),
        ],
      ),
    ),
    _cell(
      320,
      320,
      const ChartContainer(
        config: ChartSamples.devices,
        aspectRatio: null,
        children: [
          RadarChart(
            data: ChartSamples.visitors,
            xKey: 'month',
            series: ['desktop', 'mobile'],
            seed: 'radar',
            animate: false,
          ),
          ChartLegend(),
        ],
      ),
    ),
    _cell(
      320,
      320,
      ChartContainer(
        config: ChartSamples.ringConfig,
        aspectRatio: null,
        children: [
          RadialChart(
            data: ChartSamples.rings,
            nameKey: 'name',
            valueKey: 'value',
            seed: 'radial',
            animate: false,
            centerLabel: (_) =>
                const ChartCenterLabel(value: '78%', label: 'of goal'),
          ),
        ],
      ),
    ),
    SizedBox(
      width: 360,
      child: Gauge(
        value: 68,
        label: 'Server load',
        seed: 'gauge',
        animate: false,
        valueFormatter: (v) => '${formatNumber(v)}%',
        zones: const [
          GaugeZoneInput(to: 40, tone: GaugeTone.good),
          GaugeZoneInput(to: 75, tone: GaugeTone.warn),
          GaugeZoneInput(to: 100, tone: GaugeTone.bad),
        ],
      ),
    ),
  ],
);

Widget _mini() => SizedBox(
  width: 760,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d24,
    children: [
      Row(
        spacing: Spacing.d24,
        children: [
          for (final variant in SparkVariant.values)
            Sparkline(
              data: ChartSamples.trend,
              variant: variant,
              extremes: true,
              seed: 'spark-${variant.name}',
            ),
        ],
      ),
      _cell(
        512,
        256,
        const TallyChart(
          data: ChartSamples.cups,
          nameKey: 'drink',
          valueKey: 'cups',
          seed: 'tally',
          animate: false,
        ),
      ),
      Heatmap(
        data: ChartSamples.pages,
        unit: 'pages',
        seed: 'heat',
        animate: false,
      ),
      SizedBox(
        width: 448,
        child: Heatmap(
          variant: HeatVariant.grid,
          data: ChartSamples.busy,
          rowKey: 'day',
          colKey: 'hour',
          valueKey: 'orders',
          unit: 'orders',
          slot: 0,
          rows: ChartSamples.week,
          cols: ChartSamples.hours,
          showLegend: false,
          seed: 'grid',
          animate: false,
        ),
      ),
    ],
  ),
);

Widget _states() => Wrap(
  spacing: Spacing.d24,
  runSpacing: Spacing.d24,
  children: [
    _cell(
      360,
      220,
      const BarChart(
        data: ChartSamples.sales,
        xKey: 'day',
        loading: true,
        seed: 'loading',
        animate: false,
      ),
    ),
    _cell(
      360,
      220,
      const LineChart(
        data: [],
        xKey: 'day',
        emptyText: 'Nothing yet',
        seed: 'empty',
        animate: false,
      ),
    ),
  ],
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  for (final (name, build, size) in [
    ('chart-bar', _bar, const Size(1000, 700)),
    ('chart-xy', _xy, const Size(1100, 800)),
    ('chart-polar', _polar, const Size(1150, 900)),
    ('chart-mini', _mini, const Size(900, 900)),
    ('chart-states', _states, const Size(900, 400)),
  ]) {
    testWidgets('$name in the light theme', (tester) async {
      tester.view.physicalSize = size * 2;
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        componentHost(
          Align(
            alignment: Alignment.topLeft,
            child: paperPanel(build()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('../goldens/$name.png'),
      );
    });
  }
}
