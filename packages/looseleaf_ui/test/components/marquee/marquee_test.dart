import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

const _items = [
  MarqueeItem(Text('Fresh bread at seven')),
  MarqueeItem(Text('Open late on Fridays')),
];

Widget _host(
  Widget child, {
  double width = 600,
  LooseleafThemeData theme = const LooseleafThemeData(),
}) => componentHost(
  SizedBox(width: width, child: child),
  theme: theme,
);

double _firstX(WidgetTester tester) =>
    tester.getTopLeft(find.text('Fresh bread at seven').first).dx;

int _copies(WidgetTester tester) =>
    find.text('Fresh bread at seven').evaluate().length;

void main() {
  testWidgets('is a 44 px band with a 28 px pause button 8 px from the end', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const Marquee(children: _items)));
    await tester.pump();
    final band = tester.getRect(find.byType(Marquee));
    expect(band.size, const Size(600, 44));
    final control = tester.getRect(find.byType(MarqueeControl));
    expect(control.size, const Size(28, 28));
    expect(band.right - control.right, 8);
    expect(control.center.dy, band.center.dy);
  });

  testWidgets('repeats the line to fill the band and slides it', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const Marquee(children: _items)));
    await tester.pump();
    expect(_copies(tester), greaterThanOrEqualTo(2));
    final start = _firstX(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(_firstX(tester), closeTo(start - 60, 1));
  });

  testWidgets('runs the other way with direction end', (tester) async {
    await tester.pumpWidget(
      _host(
        const Marquee(direction: MarqueeDirection.end, children: _items),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final start = _firstX(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(_firstX(tester), closeTo(start + 60, 1));
  });

  testWidgets('only the first copy reaches screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(const Marquee(children: _items)));
    await tester.pump();
    expect(
      find.bySemanticsLabel(RegExp('Fresh bread at seven')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Ticker'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the pause button toggles and holds the line still', (
    tester,
  ) async {
    final changes = <bool>[];
    await tester.pumpWidget(
      _host(Marquee(onPausedChange: changes.add, children: _items)),
    );
    await tester.pump();
    final handle = tester.ensureSemantics();
    await tester.tap(find.byType(MarqueeControl));
    await tester.pump();
    expect(changes, [true]);
    expect(
      tester.getSemantics(find.byType(MarqueeControl)),
      matchesSemantics(
        label: 'Pause ticker',
        isButton: true,
        hasToggledState: true,
        isToggled: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
      ),
    );
    final held = _firstX(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(_firstX(tester), held);
    await tester.tap(find.byType(MarqueeControl));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(_firstX(tester), lessThan(held));
    expect(changes, [true, false]);
    handle.dispose();
  });

  testWidgets('a controlled marquee follows paused', (tester) async {
    final changes = <bool>[];
    await tester.pumpWidget(
      _host(
        Marquee(paused: true, onPausedChange: changes.add, children: _items),
      ),
    );
    await tester.pump();
    final held = _firstX(tester);
    await tester.tap(find.byType(MarqueeControl));
    await tester.pump(const Duration(seconds: 1));
    expect(changes, [false]);
    expect(_firstX(tester), held);
  });

  testWidgets('hover pauses it', (tester) async {
    await tester.pumpWidget(_host(const Marquee(children: _items)));
    await tester.pump();
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: tester.getCenter(find.byType(Marquee)));
    await tester.pump();
    final held = _firstX(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(_firstX(tester), held);
    await mouse.moveTo(Offset.zero);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(_firstX(tester), lessThan(held));
  });

  testWidgets('focus inside pauses it; Space presses the button', (
    tester,
  ) async {
    final changes = <bool>[];
    await tester.pumpWidget(
      _host(Marquee(onPausedChange: changes.add, children: _items)),
    );
    await tester.pump();
    Focus.of(
      tester.element(
        find.descendant(
          of: find.byType(MarqueeControl),
          matching: find.byType(InkSurface),
        ),
      ),
    ).requestFocus();
    await tester.pump();
    final held = _firstX(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(_firstX(tester), held);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(changes, [true]);
  });

  testWidgets('reduced motion shows one still copy, centred', (tester) async {
    await tester.pumpWidget(
      _host(
        const Marquee(
          controls: false,
          children: [MarqueeItem(Text('Hi'), separator: null)],
        ),
        theme: const LooseleafThemeData(motion: LooseleafMotion.reduced),
      ),
    );
    await tester.pump();
    expect(_copiesOf(tester, 'Hi'), 1);
    final band = tester.getRect(find.byType(Marquee));
    final text = tester.getRect(find.byType(MarqueeItem));
    expect(text.center.dx, closeTo(band.center.dx, 1));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.getRect(find.byType(MarqueeItem)), text);
  });

  testWidgets('hides the pause button with controls false', (tester) async {
    await tester.pumpWidget(
      _host(const Marquee(controls: false, children: _items)),
    );
    expect(find.byType(MarqueeControl), findsNothing);
  });

  testWidgets('stops its ticker when removed', (tester) async {
    await tester.pumpWidget(_host(const Marquee(children: _items)));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpWidget(_host(const SizedBox()));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('a control outside a marquee throws', (tester) async {
    await tester.pumpWidget(componentHost(const MarqueeControl()));
    expect(tester.takeException(), isA<FlutterError>());
  });
}

int _copiesOf(WidgetTester tester, String text) =>
    find.text(text).evaluate().length;
