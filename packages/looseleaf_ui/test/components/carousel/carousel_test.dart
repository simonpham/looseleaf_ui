import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Widget _carousel({
  int count = 5,
  double fraction = 1,
  bool loop = false,
  ValueChanged<int>? onSelect,
}) => SizedBox(
  width: 300,
  child: Carousel(
    itemFraction: fraction,
    loop: loop,
    onSelect: onSelect,
    seed: 'c',
    children: [
      CarouselContent(
        children: [
          for (var i = 0; i < count; i++)
            CarouselItem(child: Center(child: Text('Slide $i'))),
        ],
      ),
      const CarouselPrevious(),
      const CarouselNext(),
      const CarouselDots(),
    ],
  ),
);

Button _step(WidgetTester tester, Type type) => tester.widget<Button>(
  find.descendant(of: find.byType(type), matching: find.byType(Button)),
);

void main() {
  testWidgets('the arrows step and grey out at the ends', (tester) async {
    final selected = <int>[];
    await tester.pumpWidget(componentHost(_carousel(onSelect: selected.add)));
    await tester.pump();
    expect(_step(tester, CarouselPrevious).disabled, isTrue);
    expect(_step(tester, CarouselNext).disabled, isFalse);
    await tester.tap(find.byType(CarouselNext));
    await tester.pumpAndSettle();
    expect(selected, [1]);
    expect(_step(tester, CarouselPrevious).disabled, isFalse);
  });

  testWidgets('slides are the strip wide less the arrow room', (tester) async {
    await tester.pumpWidget(componentHost(_carousel()));
    await tester.pump();
    final slide = tester.getSize(find.byType(CarouselItem).first);
    expect(slide.width, 300 - 2 * 48);
    expect(slide.height, 300 - 2 * 48);
  });

  testWidgets('a swipe moves to the next slide', (tester) async {
    final selected = <int>[];
    await tester.pumpWidget(componentHost(_carousel(onSelect: selected.add)));
    await tester.pump();
    await tester.fling(find.text('Slide 0'), const Offset(-200, 0), 1000);
    await tester.pumpAndSettle();
    expect(selected, [1]);
  });

  testWidgets('arrow keys step while focus is inside', (tester) async {
    final selected = <int>[];
    await tester.pumpWidget(componentHost(_carousel(onSelect: selected.add)));
    await tester.pump();
    final tick = find.byType(CarouselTick).first;
    Focus.of(
      tester.element(
        find.descendant(of: tick, matching: find.byType(InkSurface)),
      ),
    ).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(selected, [1, 2]);
    final focused = tester.widget<CarouselTick>(
      find.byType(CarouselTick).at(2),
    );
    expect(focused.focusNode?.hasFocus, isTrue);
  });

  testWidgets('dots: a tick per snap, a tap goes there, every fifth slashes', (
    tester,
  ) async {
    final selected = <int>[];
    await tester.pumpWidget(
      componentHost(_carousel(count: 7, onSelect: selected.add)),
    );
    await tester.pump();
    final ticks = tester.widgetList<CarouselTick>(find.byType(CarouselTick));
    expect(ticks, hasLength(7));
    expect(ticks.elementAt(4).slash, isTrue);
    await tester.tap(find.byType(CarouselTick).at(3));
    await tester.pumpAndSettle();
    expect(selected, [3]);
  });

  testWidgets('three a view leaves count - 2 snaps', (tester) async {
    await tester.pumpWidget(
      componentHost(_carousel(count: 6, fraction: 1 / 3)),
    );
    await tester.pump();
    expect(find.byType(CarouselTick), findsNWidgets(4));
  });

  testWidgets('loop wraps from the last slide', (tester) async {
    final selected = <int>[];
    await tester.pumpWidget(
      componentHost(_carousel(count: 2, loop: true, onSelect: selected.add)),
    );
    await tester.pump();
    expect(_step(tester, CarouselPrevious).disabled, isFalse);
  });

  testWidgets('announces the slide', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(_carousel()));
    await tester.pump();
    expect(find.bySemanticsLabel('Slide 1 of 5'), findsOneWidget);
    expect(find.bySemanticsLabel('Go to slide 2'), findsOneWidget);
    handle.dispose();
  });
}
