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

  test('snaps follow Embla: trimmed, center by default', () {
    expect(
      carouselSnaps(
        count: 5,
        fraction: 1 / 2,
        align: CarouselAlign.start,
        loop: false,
      ),
      [0, 0.5, 1, 1.5],
    );
    expect(
      carouselSnaps(
        count: 5,
        fraction: 1 / 2,
        align: CarouselAlign.center,
        loop: false,
      ),
      [0, 0.25, 0.75, 1.25, 1.5],
    );
    expect(
      carouselSnaps(
        count: 2,
        fraction: 1,
        align: CarouselAlign.center,
        loop: true,
      ),
      [0, 1],
    );
  });

  testWidgets('a vertical carousel in a column scrolls up and down', (
    tester,
  ) async {
    final controller = CarouselController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      componentHost(
        SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Carousel(
                axis: Axis.vertical,
                align: CarouselAlign.start,
                itemFraction: 1 / 2,
                controller: controller,
                children: [
                  CarouselContent(
                    extent: 200,
                    gap: Spacing.d4,
                    children: [
                      for (var i = 0; i < 4; i++)
                        CarouselItem(child: Center(child: Text('Slide $i'))),
                    ],
                  ),
                  const CarouselPrevious(),
                  const CarouselNext(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(controller.snapCount, 3);
    final slide = tester.getSize(find.byType(CarouselItem).first);
    expect(slide, const Size(300, (200 + Spacing.d4) / 2 - Spacing.d4));
    final top = tester.getTopLeft(find.text('Slide 1')).dy;
    controller.scrollNext();
    await tester.pumpAndSettle();
    expect(controller.value, 1);
    expect(tester.getTopLeft(find.text('Slide 1')).dy, lessThan(top));
  });

  testWidgets('the controller drives it and hears every selection', (
    tester,
  ) async {
    final controller = CarouselController();
    addTearDown(controller.dispose);
    final heard = <int>[];
    controller.addListener(() => heard.add(controller.value));
    await tester.pumpWidget(
      componentHost(
        SizedBox(
          width: 300,
          child: Carousel(
            controller: controller,
            children: [
              CarouselContent(
                children: [
                  for (var i = 0; i < 5; i++)
                    CarouselItem(child: Center(child: Text('Slide $i'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(controller.snapCount, 5);
    expect(controller.canScrollPrev, isFalse);
    controller.scrollTo(3);
    await tester.pumpAndSettle();
    expect(controller.selectedIndex, 3);
    controller.scrollPrev();
    await tester.pumpAndSettle();
    expect(controller.value, 2);
    await tester.fling(find.text('Slide 2'), const Offset(-200, 0), 1000);
    await tester.pumpAndSettle();
    expect(controller.value, 3);
    expect(heard, containsAllInOrder([3, 2, 3]));
  });

  testWidgets('gap sets the room between slides', (tester) async {
    await tester.pumpWidget(
      componentHost(
        SizedBox(
          width: 300,
          child: Carousel(
            itemFraction: 1 / 2,
            children: [
              CarouselContent(
                gap: Spacing.d4,
                children: [
                  for (var i = 0; i < 4; i++)
                    CarouselItem(child: Text('Slide $i')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    final first = tester.getRect(find.byType(CarouselItem).at(0));
    final second = tester.getRect(find.byType(CarouselItem).at(1));
    expect(second.left - first.right, Spacing.d4);
    expect(first.left, tester.getTopLeft(find.byType(Carousel)).dx);
  });
}
