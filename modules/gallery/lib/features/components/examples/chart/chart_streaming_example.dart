import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

int _sample(int t) =>
    (120 + 50 * math.sin(t / 5) + 22 * math.sin(t / 1.7) + ((t * 37) % 9))
        .round();

class ChartStreamingExample extends StatefulWidget {
  const ChartStreamingExample({super.key});

  @override
  State<ChartStreamingExample> createState() => _ChartStreamingExampleState();
}

class _ChartStreamingExampleState extends State<ChartStreamingExample> {
  int _tick = 40;
  Timer? _timer;

  bool get _running => _timer != null;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() => _timer = Timer.periodic(
    const Duration(seconds: 1),
    (_) => setState(() => _tick++),
  );

  void _toggle() => setState(() {
    if (_timer case final timer?) {
      timer.cancel();
      _timer = null;
      return;
    }
    _start();
  });

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final data = <ChartRow>[
      for (var i = 0; i < 30; i++)
        {'t': '${_tick - 29 + i}s', 'rps': _sample(_tick - 29 + i)},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d12,
      children: [
        Row(
          spacing: Spacing.d16,
          children: [
            Button(
              size: ButtonSize.sm,
              variant: switch (_running) {
                true => ButtonVariant.outline,
                false => ButtonVariant.primary,
              },
              onPressed: _toggle,
              child: Text(switch (_running) {
                true => 'pause',
                false => 'resume',
              }),
            ),
            Text(
              '${data.last['rps']}',
              style: theme.typography
                  .face(KevinSansFace.script, cssSize: 24)
                  .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
            ),
            Sparkline(
              width: Spacing.d96,
              height: Spacing.d32,
              data: data,
              dataKey: 'rps',
              label: 'Requests per second, last 30 seconds',
            ),
          ],
        ),
        ChartContainer(
          config: {
            'rps': ChartSeriesConfig(
              label: 'Requests / s',
              color: theme.colors.inkYou,
            ),
          },
          height: Spacing.d224,
          children: [
            AreaChart(
              data: data,
              xKey: 't',
              curve: CurveKind.smooth,
              label: 'Requests per second',
              yDomain: const (0, 240),
            ),
            const ChartTooltip(),
          ],
        ),
      ],
    );
  }
}
