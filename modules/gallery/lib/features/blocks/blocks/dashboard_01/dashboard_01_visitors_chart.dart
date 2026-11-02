import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/dashboard_01/dashboard_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Visitors per day as a stacked area, pinned to the page, re-cut to the
/// last 3 months, 30 days or 7 days (7 on a phone): toggles on a wide card,
/// a select on a narrow one.
///
/// Mirrors `ChartAreaInteractive` in upstream
/// `src/blocks/dashboard-01/components/dashboard-01-chart-area-interactive.tsx`.
class Dashboard01VisitorsChart extends StatefulWidget {
  const Dashboard01VisitorsChart({super.key});

  @override
  State<Dashboard01VisitorsChart> createState() =>
      _Dashboard01VisitorsChartState();
}

class _Dashboard01VisitorsChartState extends State<Dashboard01VisitorsChart> {
  static const double _mobileBelow = 768;
  static const double _togglesFrom = 767;
  static const double _longFrom = 540;
  static const double _chartHeight = 250;
  static const double _selectWidth = 160;
  static const double _widePadFrom = 640;

  static const _ranges = [
    (value: '90d', label: 'Last 3 months', days: 90),
    (value: '30d', label: 'Last 30 days', days: 30),
    (value: '7d', label: 'Last 7 days', days: 7),
  ];

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  var _range = '90d';
  bool? _wasMobile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mobile = MediaQuery.sizeOf(context).width < _mobileBelow;
    if (mobile && _wasMobile != true) _range = '7d';
    _wasMobile = mobile;
  }

  static String _day(Object? iso, [int index = 0]) {
    final parts = '$iso'.split('-');
    if (parts case [_, final month, final day]) {
      final name = _months.elementAtOrNull(int.parse(month) - 1) ?? month;
      return '$name ${int.parse(day)}';
    }
    return '$iso';
  }

  @override
  Widget build(BuildContext context) {
    final range = _ranges.firstWhere(
      (entry) => entry.value == _range,
      orElse: () => _ranges.first,
    );
    final start = dashboard01ReferenceDay
        .subtract(Duration(days: range.days))
        .toIso8601String()
        .substring(0, 10);
    final data = [
      for (final row in dashboard01Visitors)
        if ('${row['date']}'.compareTo(start) >= 0) row,
    ];
    final current = range.label;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final toggles = width >= _togglesFrom;
        return Card(
          fastener: FastenerKind.pin,
          seed: 's01-visitors',
          children: [
            CardHeader(
              children: [
                Semantics(
                  header: true,
                  child: const CardTitle(Text('Total visitors')),
                ),
                CardDescription(
                  Text(switch (width >= _longFrom) {
                    true => 'Total for the ${current.toLowerCase()}',
                    false => current,
                  }),
                ),
                CardAction(
                  child: switch (toggles) {
                    true => ToggleGroup<String>(
                      variant: ToggleVariant.outline,
                      value: {_range},
                      semanticLabel: 'Time range',
                      onChanged: (value) {
                        if (value.firstOrNull case final picked?) {
                          setState(() => _range = picked);
                        }
                      },
                      children: [
                        for (final entry in _ranges)
                          ToggleGroupItem(
                            value: entry.value,
                            child: Text(entry.label),
                          ),
                      ],
                    ),
                    false => SizedBox(
                      width: _selectWidth,
                      child: Select(
                        value: _range,
                        onChanged: (value) => setState(() => _range = value),
                        content: SelectContent(
                          children: [
                            for (final entry in _ranges)
                              SelectItem(
                                value: entry.value,
                                child: Text(entry.label),
                              ),
                          ],
                        ),
                        child: const SelectTrigger(
                          size: SelectSize.sm,
                          semanticLabel: 'Time range',
                          child: SelectValue(placeholder: 'Last 3 months'),
                        ),
                      ),
                    ),
                  },
                ),
              ],
            ),
            CardContent(
              padding: EdgeInsets.symmetric(
                horizontal: switch (width >= _widePadFrom) {
                  true => Spacing.d24,
                  false => Spacing.d8,
                },
              ),
              child: ChartContainer(
                config: dashboard01ChartConfig,
                height: _chartHeight,
                children: [
                  AreaChart(
                    data: data,
                    xKey: 'date',
                    stacked: true,
                    xFormatter: _day,
                    label: 'Visitors per day, ${current.toLowerCase()}',
                    annotations: const [
                      ChartAnnotation(
                        at: 'max',
                        text: 'best day',
                        series: 'desktop',
                      ),
                    ],
                  ),
                  ChartTooltip(
                    content: ChartTooltipContent(
                      indicator: ChartTooltipIndicator.dot,
                      labelFormatter: (label, items) =>
                          Text(_day(items.firstOrNull?.payload?['date'])),
                    ),
                  ),
                  const ChartLegend(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
