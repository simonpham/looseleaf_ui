import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
const _revenueByMonth = [18, 26, 22, 31, 29, 38];
const _costsByMonth = [12, 15, 14, 18, 17, 21];
final _revenue = <ChartRow>[
  for (final (i, month) in _months.indexed)
    {
      'month': month,
      'revenue': _revenueByMonth[i] * 100,
      'costs': _costsByMonth[i] * 100,
    },
];

const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _signupsByDay = [42, 58, 35, 71, 64, 30, 22];
final _signups = <ChartRow>[
  for (final (i, day) in _days.indexed)
    {'day': day, 'signups': _signupsByDay[i]},
];

const _plans = <ChartRow>[
  {'plan': 'free', 'users': 640},
  {'plan': 'pro', 'users': 310},
  {'plan': 'team', 'users': 120},
];

const _revenueConfig = {
  'revenue': ChartSeriesConfig(label: 'Revenue'),
  'costs': ChartSeriesConfig(label: 'Costs'),
};

const _stats = [
  (
    label: 'Revenue',
    value: r'$3,800',
    delta: '+12%',
    data: [18, 26, 22, 31, 29, 38],
  ),
  (
    label: 'Active users',
    value: '1,070',
    delta: '+4%',
    data: [900, 940, 930, 990, 1010, 1070],
  ),
  (
    label: 'Churn',
    value: '2.1%',
    delta: '-0.3',
    data: [3.1, 2.8, 2.9, 2.5, 2.4, 2.1],
  ),
];

class ChartDashboardExample extends StatefulWidget {
  const ChartDashboardExample({super.key});

  @override
  State<ChartDashboardExample> createState() => _ChartDashboardExampleState();
}

class _ChartDashboardExampleState extends State<ChartDashboardExample> {
  bool _calm = false;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final colors = theme.colors;
    final signupConfig = {
      'signups': ChartSeriesConfig(label: 'Signups', color: colors.green),
    };
    final planConfig = {
      'free': ChartSeriesConfig(label: 'Free', color: colors.inkYou),
      'pro': ChartSeriesConfig(label: 'Pro', color: colors.marker),
      'team': ChartSeriesConfig(label: 'Team', color: colors.hiDeep),
    };
    return LooseleafTheme(
      data: theme.copyWith(
        density: switch (_calm) {
          true => LooseleafDensity.calm,
          false => LooseleafDensity.comfortable,
        },
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.d16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d16,
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Button(
                size: ButtonSize.sm,
                variant: switch (_calm) {
                  true => ButtonVariant.primary,
                  false => ButtonVariant.outline,
                },
                onPressed: () => setState(() => _calm = !_calm),
                child: const Text('calm'),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d16,
              children: [
                for (final (i, stat) in _stats.indexed)
                  Expanded(
                    child: _StatCard(index: i, stat: stat),
                  ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d16,
              children: [
                Expanded(
                  flex: 2,
                  child: Card(
                    seed: 'rev',
                    children: [
                      const CardHeader(
                        children: [
                          CardTitle(Text('Revenue and costs')),
                          CardDescription(Text('Dollars per month')),
                        ],
                      ),
                      CardContent(
                        child: ChartContainer(
                          config: _revenueConfig,
                          height: Spacing.d52 * 4,
                          children: [
                            AreaChart(
                              data: _revenue,
                              xKey: 'month',
                              label: 'Revenue and costs per month',
                              yFormatter: (v) => '\$${formatNumber(v / 1000)}k',
                            ),
                            const ChartTooltip(),
                            const ChartLegend(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Card(
                    seed: 'plans',
                    children: [
                      const CardHeader(
                        children: [
                          CardTitle(Text('Plans')),
                          CardDescription(Text('Users by plan')),
                        ],
                      ),
                      CardContent(
                        child: ChartContainer(
                          config: planConfig,
                          height: Spacing.d52 * 4,
                          children: [
                            DonutChart(
                              data: _plans,
                              nameKey: 'plan',
                              valueKey: 'users',
                              label: 'Users by plan',
                              showLabels: false,
                              centerLabel: (_) => const ChartCenterLabel(
                                value: '1,070',
                                label: 'users',
                              ),
                            ),
                            const ChartTooltip(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Card(
              seed: 'signups',
              children: [
                const CardHeader(
                  children: [CardTitle(Text('Signups this week'))],
                ),
                CardContent(
                  child: ChartContainer(
                    config: signupConfig,
                    height: Spacing.d160,
                    children: [
                      BarChart(
                        data: _signups,
                        xKey: 'day',
                        label: 'Signups per day',
                      ),
                      const ChartTooltip(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.index, required this.stat});

  final int index;
  final ({String label, String value, String delta, List<num> data}) stat;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final down = stat.delta.startsWith('-');
    final bad = down && stat.label != 'Churn';
    return Card(
      seed: 'stat$index',
      gap: Spacing.d8,
      padding: const EdgeInsets.symmetric(vertical: Spacing.d16),
      children: [
        CardHeader(
          children: [
            CardDescription(Text(stat.label)),
            CardTitle(
              Text(stat.value, style: theme.typography.title(cssSize: 30)),
            ),
            CardAction(
              child: Sparkline(
                width: Spacing.d80,
                data: stat.data,
                variant: SparkVariant.area,
                label: '${stat.label}, last six months',
                slot: index,
              ),
            ),
          ],
        ),
        CardFooter(
          spacing: Spacing.d4,
          children: [
            InkIcon(
              switch (down) {
                true => 'arrow-down',
                false => 'arrow-up',
              },
              size: Spacing.d14,
              color: switch (bad) {
                true => theme.colors.red,
                false => theme.colors.green,
              },
            ),
            Flexible(
              child: Text(
                '${stat.delta} on last month',
                style: theme.typography.interface(
                  cssSize: 14,
                  color: theme.colors.inkMuted,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
