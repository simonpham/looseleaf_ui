import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

ConfettiPainter? _painter(WidgetTester tester) =>
    tester
            .widget<CustomPaint>(
              find.descendant(
                of: find.byType(Confetti),
                matching: find.byType(CustomPaint),
              ),
            )
            .painter
        as ConfettiPainter?;

Widget _layer({
  ConfettiController? controller,
  bool active = false,
  Object? burstKey,
  ConfettiOptions options = const ConfettiOptions(),
  LooseleafThemeData theme = const LooseleafThemeData(),
}) => componentHost(
  SizedBox(
    width: 300,
    height: 200,
    child: Confetti(
      controller: controller,
      active: active,
      burstKey: burstKey,
      options: options,
    ),
  ),
  theme: theme,
);

void main() {
  test('a burst interpolates between flight frames', () {
    final burst = ConfettiBurst.simulate(
      const ConfettiOptions(count: 3, seed: 7),
      number: 1,
      started: Duration.zero,
    );
    final flight = burst.flights.first;
    final a = flight.frames[2];
    final b = flight.frames[3];
    final mid = ConfettiBurst.frameAt(
      flight,
      const Duration(milliseconds: 2 * stepMs + stepMs ~/ 2),
    );
    expect(mid?.x, closeTo((a.x + b.x) / 2, 1e-9));
    expect(mid?.opacity, closeTo((a.opacity + b.opacity) / 2, 1e-9));
    expect(ConfettiBurst.frameAt(flight, burst.length), isNull);
    expect(burst.length, const Duration(milliseconds: 2600));
  });

  test('count is clamped to 400 and options merge', () {
    final burst = ConfettiBurst.simulate(
      const ConfettiOptions(count: 9000),
      number: 1,
      started: Duration.zero,
    );
    expect(burst.flights, hasLength(400));
    final merged = const ConfettiOptions(
      count: 10,
      spread: 30,
    ).merge(const ConfettiOptions(spread: 360));
    expect(merged.count, 10);
    expect(merged.spread, 360);
  });

  testWidgets('the controller throws a burst that lands and calls onDone', (
    tester,
  ) async {
    final controller = ConfettiController();
    var done = 0;
    await tester.pumpWidget(_layer(controller: controller));
    expect(controller.attached, isTrue);
    expect(_painter(tester), isNull);
    controller.burst(ConfettiOptions(count: 20, onDone: () => done++));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(_painter(tester)?.bursts, hasLength(1));
    expect(_painter(tester)?.bursts.single.origin, const Offset(150, 100));
    await tester.pump(const Duration(seconds: 3));
    expect(done, 1);
    expect(_painter(tester), isNull);
  });

  testWidgets('active and burstKey throw bursts', (tester) async {
    await tester.pumpWidget(_layer(active: true));
    await tester.pump();
    expect(_painter(tester)?.bursts, hasLength(1));
    await tester.pumpWidget(_layer(active: true, burstKey: 1));
    await tester.pump();
    expect(_painter(tester)?.bursts, hasLength(2));
    await tester.pumpAndSettle();
    expect(_painter(tester), isNull);
  });

  testWidgets('the stop function ends a burst early', (tester) async {
    final controller = ConfettiController();
    var done = 0;
    await tester.pumpWidget(_layer(controller: controller));
    final stop = controller.burst(ConfettiOptions(onDone: () => done++));
    await tester.pump(const Duration(milliseconds: 100));
    stop();
    await tester.pump();
    expect(done, 1);
    expect(_painter(tester), isNull);
  });

  testWidgets('reduced motion throws nothing', (tester) async {
    final controller = ConfettiController();
    await tester.pumpWidget(
      _layer(
        controller: controller,
        theme: const LooseleafThemeData(motion: LooseleafMotion.reduced),
      ),
    );
    controller.burst();
    await tester.pump();
    expect(_painter(tester), isNull);
  });

  testWidgets('a trigger bursts from itself over the screen', (tester) async {
    var done = 0;
    await tester.pumpWidget(
      componentHost(
        Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => Center(
                child: ConfettiTrigger(
                  options: ConfettiOptions(count: 10, onDone: () => done++),
                  builder: (context, burst) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: burst,
                    child: const SizedBox(width: 80, height: 30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    final center = tester.getCenter(find.byType(ConfettiTrigger));
    await tester.tap(find.byType(ConfettiTrigger));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final painter = _painter(tester);
    expect(
      painter?.bursts.single.origin,
      center,
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(done, 1);
    expect(find.byType(Confetti), findsNothing);
  });
}
