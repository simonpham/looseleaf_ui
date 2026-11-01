import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';

class _Harness extends StatefulWidget {
  const _Harness({
    this.initial = 5,
    this.max = 10,
    this.step = 1,
    this.snap = false,
    this.required = false,
    this.disabled = false,
  });

  final double? initial;
  final double? max;
  final double step;
  final bool snap;
  final bool required;
  final bool disabled;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late double? value = widget.initial;

  @override
  Widget build(BuildContext context) => Stepper(
    value: value,
    min: 0,
    max: widget.max,
    step: widget.step,
    snap: widget.snap,
    required: widget.required,
    disabled: widget.disabled,
    semanticLabel: 'Quantity',
    onChanged: (next) => setState(() => value = next),
  );
}

double? _value(WidgetTester tester) =>
    tester.state<_HarnessState>(find.byType(_Harness)).value;

Finder _button(String label) => find.byWidgetPredicate(
  (widget) => widget is StepperButton && widget.semanticLabel == label,
);

void main() {
  testWidgets('the buttons step and stop at the bounds', (tester) async {
    await tester.pumpWidget(overlayHost(const _Harness(initial: 9)));
    await tester.tap(_button('Increase'));
    await tester.pump();
    expect(_value(tester), 10);
    await tester.tap(_button('Increase'));
    await tester.pump();
    expect(_value(tester), 10);
    expect(tester.widget<StepperButton>(_button('Increase')).exhausted, isTrue);
    await tester.tap(_button('Decrease'));
    await tester.pumpAndSettle();
    expect(_value(tester), 9);
  });

  testWidgets('holding a button repeats until released', (tester) async {
    await tester.pumpWidget(
      overlayHost(const _Harness(initial: 0, max: 100)),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(_button('Increase')),
    );
    await tester.pump();
    expect(_value(tester), 1);
    await tester.pump(const Duration(milliseconds: 420));
    await tester.pump(const Duration(milliseconds: 90));
    await tester.pump(const Duration(milliseconds: 90));
    expect(_value(tester), 3);
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 500));
    expect(_value(tester), 3);
  });

  testWidgets('keys step, jump and take Shift', (tester) async {
    await tester.pumpWidget(overlayHost(const _Harness(max: 100)));
    await tester.tap(find.byType(EditableText));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(_value(tester), 6);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(_value(tester), 5);
    await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
    await tester.pump();
    expect(_value(tester), 15);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    expect(_value(tester), 5);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(_value(tester), 100);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(_value(tester), 0);
  });

  testWidgets('typed text commits on Enter, clamped and snapped', (
    tester,
  ) async {
    await tester.pumpWidget(overlayHost(const _Harness(step: 5, snap: true)));
    await tester.enterText(find.byType(EditableText), '7');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(_value(tester), 5);
    await tester.enterText(find.byType(EditableText), '1.000,5');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(_value(tester), 10);
  });

  testWidgets('Escape drops typed text, bad text is refused', (tester) async {
    await tester.pumpWidget(overlayHost(const _Harness()));
    await tester.enterText(find.byType(EditableText), '8');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(find.text('5'), findsOneWidget);
    await tester.enterText(find.byType(EditableText), 'abc');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(_value(tester), 5);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('clearing empties the value', (tester) async {
    await tester.pumpWidget(overlayHost(const _Harness()));
    await tester.enterText(find.byType(EditableText), '');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(_value(tester), isNull);
  });

  testWidgets('a required stepper refuses to be cleared', (tester) async {
    await tester.pumpWidget(overlayHost(const _Harness(required: true)));
    await tester.enterText(find.byType(EditableText), '');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(_value(tester), isNotNull);
  });

  testWidgets('decimal steps do not drift', (tester) async {
    await tester.pumpWidget(
      overlayHost(const _Harness(initial: 0.1, step: 0.2, max: null)),
    );
    await tester.tap(_button('Increase'));
    await tester.pump();
    expect(_value(tester), 0.3);
  });

  testWidgets('focus draws the ring', (tester) async {
    await tester.pumpWidget(overlayHost(const _Harness()));
    await tester.tap(find.byType(EditableText));
    await tester.pump();
    expect(
      tester.widget<InkSurface>(find.byType(InkSurface).first).states,
      contains(InkState.focused),
    );
  });

  testWidgets('disabled ignores the buttons', (tester) async {
    await tester.pumpWidget(overlayHost(const _Harness(disabled: true)));
    await tester.tap(_button('Increase'));
    await tester.pump();
    expect(_value(tester), 5);
  });

  testWidgets('reads as a named spin field with buttons', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(overlayHost(const _Harness()));
    final node = tester.getSemantics(find.bySemanticsLabel('Quantity'));
    expect(node.value, '5');
    expect(node.increasedValue, '6');
    expect(node.decreasedValue, '4');
    expect(find.bySemanticsLabel('Increase'), findsOneWidget);
    expect(find.bySemanticsLabel('Decrease'), findsOneWidget);
    handle.dispose();
  });

  test('parse understands points, commas and grouping', () {
    expect(StepperNumber.parse('1,5'), 1.5);
    expect(StepperNumber.parse('1.234,5'), 1234.5);
    expect(StepperNumber.parse('1,234'), 1.234);
    expect(StepperNumber.parse('1,234,567'), 1234567);
    expect(StepperNumber.parse('−3'), -3);
    expect(StepperNumber.parse('٣'), 3);
    expect(StepperNumber.parse('12a'), isNull);
    expect(StepperNumber.parse(''), isNull);
    expect(StepperNumber.decimals(0.25), 2);
    expect(StepperNumber.decimals(1e-7), 7);
  });

  testWidgets('the tally draws nothing at zero', (tester) async {
    await tester.pumpWidget(overlayHost(const StepperTally(value: 0)));
    expect(find.byType(InkSurface), findsNothing);
  });

  testWidgets('the tally caps its marks', (tester) async {
    await tester.pumpWidget(overlayHost(const StepperTally(value: 40)));
    expect(
      tester.getSize(find.byType(StepperTally)).width,
      tallyWidth(20),
    );
  });
}
