import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

class _Harness extends StatefulWidget {
  const _Harness({
    this.initial = const [50],
    this.step = 1,
    this.inverted = false,
    this.direction = Axis.horizontal,
  });

  final List<double> initial;
  final double step;
  final bool inverted;
  final Axis direction;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late List<double> values = widget.initial;

  @override
  Widget build(BuildContext context) => FocusScope(
    autofocus: true,
    child: SizedBox(
      width: switch (widget.direction) {
        Axis.horizontal => 220,
        Axis.vertical => 24,
      },
      height: switch (widget.direction) {
        Axis.horizontal => 24,
        Axis.vertical => 220,
      },
      child: Slider(
        values: values,
        step: widget.step,
        inverted: widget.inverted,
        direction: widget.direction,
        semanticLabel: 'Volume',
        onChanged: (next) => setState(() => values = next),
      ),
    ),
  );
}

List<double> _values(WidgetTester tester) =>
    tester.widget<Slider>(find.byType(Slider)).values;

void main() {
  testWidgets('tapping the track moves the thumb there', (tester) async {
    await tester.pumpWidget(componentHost(const _Harness()));
    final box = tester.getRect(find.byType(Slider));
    await tester.tapAt(Offset(box.left + 10, box.center.dy));
    await tester.pump();
    expect(_values(tester), [0]);
    await tester.tapAt(Offset(box.right - 10, box.center.dy));
    await tester.pump();
    expect(_values(tester), [100]);
    await tester.tapAt(box.center);
    await tester.pump();
    expect(_values(tester), [50]);
  });

  testWidgets('dragging moves the nearest thumb, not past its neighbour', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(const _Harness(initial: [20, 80])));
    final box = tester.getRect(find.byType(Slider));
    final from = Offset(box.left + 10 + 200 * 0.8, box.center.dy);
    await tester.dragFrom(from, const Offset(-200, 0));
    await tester.pump();
    expect(_values(tester), [20, 20]);
  });

  testWidgets('arrow keys step, Shift and Page keys step ten, Home and End', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(const _Harness()));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(_values(tester), [51]);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(_values(tester), [50]);
    await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
    await tester.pump();
    expect(_values(tester), [60]);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    expect(_values(tester), [50]);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(_values(tester), [100]);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(_values(tester), [0]);
  });

  testWidgets('inverted flips the horizontal keys and the track', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(const _Harness(inverted: true)));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(_values(tester), [49]);
    final box = tester.getRect(find.byType(Slider));
    await tester.tapAt(Offset(box.left + 10, box.center.dy));
    await tester.pump();
    expect(_values(tester), [100]);
  });

  testWidgets('a vertical slider puts min at the bottom', (tester) async {
    await tester.pumpWidget(
      componentHost(const _Harness(direction: Axis.vertical)),
    );
    final box = tester.getRect(find.byType(Slider));
    await tester.tapAt(Offset(box.center.dx, box.bottom - 10));
    await tester.pump();
    expect(_values(tester), [0]);
  });

  testWidgets('values snap to the step', (tester) async {
    await tester.pumpWidget(componentHost(const _Harness(step: 25)));
    final box = tester.getRect(find.byType(Slider));
    await tester.tapAt(Offset(box.left + 10 + 200 * 0.6, box.center.dy));
    await tester.pump();
    expect(_values(tester), [50]);
  });

  testWidgets('each thumb reads as a slider with its value', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(const _Harness()));
    final node = tester.getSemantics(find.bySemanticsLabel('Volume'));
    expect(node.value, '50');
    expect(node.increasedValue, '51');
    expect(node.decreasedValue, '49');
    handle.dispose();
  });

  testWidgets('disabled ignores taps', (tester) async {
    var changes = 0;
    await tester.pumpWidget(
      componentHost(
        SizedBox(
          width: 200,
          height: 24,
          child: Slider(
            values: const [10],
            disabled: true,
            onChanged: (_) => changes++,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(Slider));
    expect(changes, 0);
  });
}
