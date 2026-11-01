import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Widget _tags({ScrollController? controller}) => SizedBox(
  width: 200,
  height: 200,
  child: ScrollArea(
    controller: controller,
    child: Column(
      children: [
        for (var i = 0; i < 40; i++)
          SizedBox(height: 20, child: Text('Tag $i')),
      ],
    ),
  ),
);

double _opacity(WidgetTester tester) =>
    tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;

void main() {
  testWidgets('the mark shows on hover and while scrolling', (tester) async {
    await tester.pumpWidget(componentHost(_tags()));
    expect(_opacity(tester), 0);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.byType(ScrollArea)));
    await tester.pump();
    expect(_opacity(tester), 1);
    await mouse.moveTo(Offset.zero);
    await tester.pump();
    expect(_opacity(tester), 0);
    await mouse.removePointer();
    await tester.drag(find.text('Tag 3'), const Offset(0, -100));
    await tester.pump();
    expect(_opacity(tester), 1);
    await tester.pump(const Duration(milliseconds: 700));
    expect(_opacity(tester), 0);
  });

  testWidgets('the thumb is sized to the view and dragging it scrolls', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(componentHost(_tags(controller: controller)));
    await tester.pump();
    final thumb = find.byWidgetPredicate(
      (widget) =>
          widget is InkSurface && widget.source.id.startsWith('scroll-thumb'),
    );
    expect(tester.getSize(thumb).height, closeTo(198 * 200 / 800, 0.01));
    expect(tester.getSize(thumb).width, 7);
    await tester.drag(thumb, const Offset(0, 50), touchSlopY: 0);
    await tester.pump();
    expect(controller.offset, closeTo(50 * 600 / (198 - 49.5), 0.5));
  });

  testWidgets('a tap on the gutter pages towards it', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(componentHost(_tags(controller: controller)));
    await tester.pump();
    final bar = tester.getRect(find.byType(ScrollBar));
    await tester.tapAt(Offset(bar.center.dx, bar.bottom - 5));
    await tester.pump();
    expect(controller.offset, 200);
  });

  testWidgets('the focused viewport scrolls with the keyboard', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(componentHost(_tags(controller: controller)));
    Focus.of(tester.element(find.text('Tag 0'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pumpAndSettle();
    expect(controller.offset, greaterThan(0));
  });

  testWidgets('both orientations get both marks', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 100,
          height: 100,
          child: ScrollArea(
            orientation: ScrollAreaOrientation.both,
            child: SizedBox(width: 400, height: 400),
          ),
        ),
      ),
    );
    expect(find.byType(ScrollBar), findsNWidgets(2));
  });
}
