import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import 'chart_samples.dart';

Widget _sized(Widget child) =>
    componentHost(SizedBox(width: 480, height: 300, child: child));

Widget _sales({
  ValueChanged<ChartPoint?>? onActiveChange,
  ValueChanged<ChartPoint>? onSelect,
  int? defaultIndex,
}) => _sized(
  ChartContainer(
    config: const {'sales': ChartSeriesConfig(label: 'Sales')},
    aspectRatio: null,
    children: [
      BarChart(
        data: ChartSamples.sales,
        xKey: 'day',
        label: 'Units sold per day',
        animate: false,
        onActiveChange: onActiveChange,
        onSelect: onSelect,
      ),
      ChartTooltip(defaultIndex: defaultIndex),
    ],
  ),
);

FocusNode _chartFocus(WidgetTester tester) => Focus.of(
  tester.element(find.byType(ChartLabels)),
);

Future<void> _focusChart(WidgetTester tester) async {
  _chartFocus(tester).requestFocus();
  await tester.pump();
  await tester.pump();
}

SemanticsNode _chartNode(WidgetTester tester, String label) =>
    tester.getSemantics(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == label &&
            widget.properties.hint != null,
      ),
    );

void main() {
  testWidgets('names the chart and speaks its summary', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_sales());
    final node = _chartNode(tester, 'Units sold per day');
    expect(
      node.hint,
      startsWith('Units sold per day. Bar chart with 1 series'),
    );
    expect(
      find.bySemanticsLabel(RegExp(r'^Thu, Sales 24$')),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('arrow keys walk the bars and announce them', (tester) async {
    final handle = tester.ensureSemantics();
    final seen = <ChartPoint?>[];
    final picked = <ChartPoint>[];
    await tester.pumpWidget(
      _sales(onActiveChange: seen.add, onSelect: picked.add),
    );
    await _focusChart(tester);
    expect(seen.last, (index: 0, series: null));
    expect(find.text('Mon'), findsNWidgets(2));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    await tester.pump();
    expect(seen.last, (index: 1, series: null));
    expect(find.bySemanticsLabel('Tue: Sales 19'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(picked.single, (index: 6, series: null));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(seen.last, isNull);
    expect(find.byType(ChartTooltipContent), findsNothing);
    handle.dispose();
  });

  testWidgets('hover shows the tooltip and the column cursor', (tester) async {
    await tester.pumpWidget(_sales());
    expect(find.byType(ChartTooltipContent), findsNothing);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    final box = tester.getRect(find.byType(ChartLabels));
    await mouse.addPointer(location: box.topLeft);
    await mouse.moveTo(box.center);
    await tester.pump();
    expect(find.byType(ChartTooltipContent), findsOneWidget);
    expect(find.byType(ChartCursorMark), findsOneWidget);
    expect(
      tester.widget<ChartCursorMark>(find.byType(ChartCursorMark)).cursor.kind,
      CursorKind.column,
    );
    await mouse.moveTo(const Offset(-50, -50));
    await tester.pump();
    expect(find.byType(ChartTooltipContent), findsNothing);
    await mouse.removePointer();
  });

  testWidgets('defaultIndex shows a point with nothing hovered', (
    tester,
  ) async {
    await tester.pumpWidget(_sales(defaultIndex: 3));
    expect(find.byType(ChartTooltipContent), findsOneWidget);
    expect(find.text('Thu'), findsNWidgets(2));
  });

  testWidgets('up and down pick a series on a multi-series chart', (
    tester,
  ) async {
    final seen = <ChartPoint?>[];
    await tester.pumpWidget(
      _sized(
        ChartContainer(
          config: ChartSamples.devices,
          aspectRatio: null,
          children: [
            LineChart(
              data: ChartSamples.visitors,
              xKey: 'month',
              animate: false,
              onActiveChange: seen.add,
            ),
          ],
        ),
      ),
    );
    await _focusChart(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    expect(seen.last, (index: 0, series: 0));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    expect(seen.last, (index: 0, series: 2));
  });

  testWidgets('legend entries switch series off and on', (tester) async {
    final handle = tester.ensureSemantics();
    final changes = <List<String>>[];
    await tester.pumpWidget(
      _sized(
        ChartContainer(
          config: ChartSamples.devices,
          aspectRatio: null,
          onHiddenSeriesChange: changes.add,
          children: const [
            LineChart(
              data: ChartSamples.visitors,
              xKey: 'month',
              label: 'Visitors',
              animate: false,
            ),
            ChartLegend(),
          ],
        ),
      ),
    );
    expect(
      tester.getSemantics(find.text('Mobile')),
      matchesSemantics(
        label: 'Mobile',
        isButton: true,
        hasToggledState: true,
        isToggled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    await tester.tap(find.text('Mobile'));
    await tester.pump();
    expect(changes.single, ['mobile']);
    final hint = _chartNode(tester, 'Visitors').hint;
    expect(hint, contains('2 series (Desktop and Tablet)'));
    await tester.tap(find.text('Mobile'));
    await tester.pump();
    expect(changes.last, isEmpty);
    handle.dispose();
  });

  testWidgets('a configured color repaints its slot', (tester) async {
    const teal = Color(0xFF2FB1A3);
    await tester.pumpWidget(
      _sized(
        const ChartContainer(
          config: {
            'desktop': ChartSeriesConfig(label: 'Desktop'),
            'mobile': ChartSeriesConfig(label: 'Mobile', color: teal),
          },
          aspectRatio: null,
          children: [
            BarChart(data: ChartSamples.visitors, xKey: 'month'),
          ],
        ),
      ),
    );
    final colors = LooseleafTheme.of(
      tester.element(find.byType(ChartLabels)),
    ).colors;
    expect(colors.inkYou, teal);
    expect(colors.marker, const LooseleafColors().marker);
  });

  testWidgets('a chart on its own brings a container, tooltip and legend', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 480,
          child: LineChart(data: ChartSamples.visitors, animate: false),
        ),
      ),
    );
    expect(find.byType(ChartContainer), findsOneWidget);
    expect(find.byType(ChartLegend), findsOneWidget);
    expect(find.text('desktop'), findsOneWidget);
    expect(tester.getSize(find.byType(ChartContainer)).height, 270);
  });

  testWidgets('loading and empty charts are pictures, not stops', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _sized(
        const BarChart(
          data: ChartSamples.sales,
          loading: true,
          label: 'Sales',
          animate: false,
        ),
      ),
    );
    final node = _chartNode(tester, 'Sales');
    expect(node.hint, 'Sales. Bar chart. Loading.');
    expect(node.flagsCollection.isImage, isTrue);
    expect(
      find.descendant(
        of: find.byType(ChartCanvas<XYSpec>),
        matching: find.byType(Focus),
      ),
      findsNothing,
    );
    handle.dispose();
  });

  testWidgets('a gauge is a meter with its reading', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(
        const Gauge(
          value: 68,
          label: 'Server load',
          animate: false,
          zones: [
            GaugeZoneInput(to: 40, tone: GaugeTone.good),
            GaugeZoneInput(to: 75, tone: GaugeTone.warn),
          ],
        ),
      ),
    );
    final node = _chartNode(tester, 'Server load');
    expect(node.value, '68 of 100, warn');
    expect(find.text('68'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('pie keys walk the slices and the center follows', (
    tester,
  ) async {
    await tester.pumpWidget(
      _sized(
        ChartContainer(
          config: ChartSamples.browserConfig,
          aspectRatio: null,
          children: [
            DonutChart(
              data: ChartSamples.browsers,
              nameKey: 'browser',
              valueKey: 'visitors',
              animate: false,
              centerLabel: (info) => ChartCenterLabel(
                value: formatNumber(info.active?.value ?? info.total),
                label: info.active?.name ?? 'visitors',
              ),
            ),
          ],
        ),
      ),
    );
    expect(find.text('925'), findsOneWidget);
    await _focusChart(tester);
    expect(find.text('275'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(find.text('200'), findsOneWidget);
  });

  testWidgets('the reveal wipes the drawing on once', (tester) async {
    await tester.pumpWidget(
      _sized(const BarChart(data: ChartSamples.sales, xKey: 'day')),
    );
    final clip = find.descendant(
      of: find.byType(ChartCanvas<XYSpec>),
      matching: find.byType(ClipRect),
    );
    expect(clip, findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
    final opacity = tester.widget<FadeTransition>(
      find
          .ancestor(
            of: find.byType(ChartLabels),
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(opacity.opacity.value, inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
    expect(opacity.opacity.value, 1);
  });
}
