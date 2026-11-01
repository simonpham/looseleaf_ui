import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Widget _group({
  Axis axis = Axis.horizontal,
  ValueChanged<List<double>>? onLayout,
  FocusNode? focusNode,
  bool disabled = false,
}) => SizedBox(
  width: 408,
  height: 408,
  child: ResizablePanelGroup(
    axis: axis,
    disabled: disabled,
    onLayout: onLayout,
    children: [
      const ResizablePanel(defaultSize: 50, minSize: 20, child: Text('One')),
      ResizableHandle(focusNode: focusNode, semanticLabel: 'Resize'),
      const ResizablePanel(minSize: 20, child: Text('Two')),
    ],
  ),
);

double _first(WidgetTester tester, Axis axis) {
  final size = tester.getSize(
    find.ancestor(of: find.text('One'), matching: find.byType(SizedBox)).first,
  );
  return switch (axis) {
    Axis.horizontal => size.width,
    Axis.vertical => size.height,
  };
}

void main() {
  testWidgets('panels split the space less the seam', (tester) async {
    await tester.pumpWidget(componentHost(_group()));
    expect(_first(tester, Axis.horizontal), 200);
    expect(tester.getSize(find.byType(InkSurface)).width, 8);
  });

  testWidgets('dragging the seam resizes within the limits', (tester) async {
    final layouts = <List<double>>[];
    await tester.pumpWidget(componentHost(_group(onLayout: layouts.add)));
    await tester.drag(find.byType(ResizableHandle), const Offset(40, 0));
    await tester.pump();
    expect(_first(tester, Axis.horizontal), closeTo(240, 0.01));
    expect(layouts.last.first, closeTo(60, 0.01));
    await tester.drag(find.byType(ResizableHandle), const Offset(300, 0));
    await tester.pump();
    expect(_first(tester, Axis.horizontal), closeTo(320, 0.01));
  });

  testWidgets('arrows move 5%, Home and End jump to the limits', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      componentHost(_group(axis: Axis.vertical, focusNode: focusNode)),
    );
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(_first(tester, Axis.vertical), closeTo(220, 0.01));
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(_first(tester, Axis.vertical), closeTo(80, 0.01));
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(_first(tester, Axis.vertical), closeTo(320, 0.01));
  });

  testWidgets('dragging shows the pressed seam; disabled holds still', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(_group()));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ResizableHandle)),
    );
    await gesture.moveBy(const Offset(20, 0));
    await tester.pump();
    expect(
      tester.widget<InkSurface>(find.byType(InkSurface)).states,
      contains(InkState.pressed),
    );
    await gesture.up();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(componentHost(_group(disabled: true)));
    await tester.drag(
      find.byType(ResizableHandle),
      const Offset(40, 0),
      warnIfMissed: false,
    );
    await tester.pump();
    expect(_first(tester, Axis.horizontal), 200);
  });

  testWidgets('the seam is a slider to screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(_group()));
    expect(
      tester.getSemantics(find.byType(ResizableHandle)),
      matchesSemantics(
        label: 'Resize',
        value: '50',
        increasedValue: '55',
        decreasedValue: '45',
        isSlider: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
        hasIncreaseAction: true,
        hasDecreaseAction: true,
      ),
    );
    handle.dispose();
  });
}
