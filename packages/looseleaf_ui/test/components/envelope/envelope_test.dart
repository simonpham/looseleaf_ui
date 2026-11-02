import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Widget _envelope({
  bool? open,
  ValueChanged<bool>? onOpenChange,
  bool openOnHover = false,
  bool disabled = false,
  bool afterStop = false,
}) => componentHost(
  Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (afterStop)
        const Focus(autofocus: true, child: SizedBox.square(dimension: 8)),
      Envelope(
        seed: 'post',
        open: open,
        onOpenChange: onOpenChange,
        openOnHover: openOnHover,
        disabled: disabled,
        children: [
          const EnvelopeFront(
            children: [
              EnvelopeSender(child: Text('The Stationer')),
              EnvelopeAddress(children: [Text('Ada Lovelace'), Text('Paris')]),
              EnvelopeTrigger(label: 'Read the letter'),
            ],
          ),
          const EnvelopeLetter(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Dear Ada,'),
                Focus(
                  debugLabel: 'reply',
                  child: SizedBox.square(dimension: 8),
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  ),
);

Set<InkState> _back(WidgetTester tester) => tester
    .widgetList<InkSurface>(find.byType(InkSurface))
    .firstWhere((surface) => surface.seed == 'post')
    .states;

void main() {
  testWidgets('is 384 × 240 and closed: no letter, no room above', (
    tester,
  ) async {
    await tester.pumpWidget(_envelope());
    expect(tester.getSize(find.byType(Envelope)), const Size(384, 240));
    expect(find.text('Dear Ada,'), findsNothing);
    expect(_back(tester), isNot(contains(InkState.open)));
  });

  testWidgets('a tap opens it: room above, the flap up, the letter out', (
    tester,
  ) async {
    final changes = <bool>[];
    await tester.pumpWidget(_envelope(onOpenChange: changes.add));
    await tester.tap(find.byType(EnvelopeTrigger));
    await tester.pump();
    expect(changes, [true]);
    expect(_back(tester), contains(InkState.open));
    expect(find.text('Dear Ada,'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(Envelope)).height,
      closeTo(240 + 384 * 0.31, 0.01),
    );
    final letter = tester.getRect(find.byType(Paper));
    final body = tester.getRect(
      find
          .descendant(
            of: find.byType(MouseRegion),
            matching: find.byType(Stack),
          )
          .first,
    );
    expect(letter.left - body.left, closeTo(384 * 0.05, 0.01));
    expect(letter.height, closeTo(240 * 0.86, 0.01));
    expect(
      letter.bottom,
      closeTo(body.bottom - 240 * 0.09 - letter.height * 0.38, 0.01),
    );
    await tester.tap(find.byType(EnvelopeTrigger));
    await tester.pumpAndSettle();
    expect(changes, [true, false]);
    expect(find.text('Dear Ada,'), findsNothing);
    expect(tester.getSize(find.byType(Envelope)).height, 240);
  });

  testWidgets('the letter slides up and fades in', (tester) async {
    await tester.pumpWidget(_envelope());
    await tester.tap(find.byType(EnvelopeTrigger));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    double rise() =>
        tester.getRect(find.byType(EnvelopeFront)).top -
        tester.getRect(find.byType(Paper)).top;
    final start = rise();
    final opacity = tester
        .widget<Opacity>(
          find.ancestor(of: find.byType(Paper), matching: find.byType(Opacity)),
        )
        .opacity;
    expect(opacity, lessThan(0.1));
    await tester.pumpAndSettle();
    expect(rise(), greaterThan(start + 40));
  });

  testWidgets('controlled: open wins', (tester) async {
    final changes = <bool>[];
    await tester.pumpWidget(_envelope(open: false, onOpenChange: changes.add));
    await tester.tap(find.byType(EnvelopeTrigger));
    await tester.pump();
    expect(changes, [true]);
    expect(find.text('Dear Ada,'), findsNothing);
    await tester.pumpWidget(_envelope(open: true, onOpenChange: changes.add));
    expect(find.text('Dear Ada,'), findsOneWidget);
  });

  testWidgets('Space on the trigger opens; Tab then reaches the letter', (
    tester,
  ) async {
    await tester.pumpWidget(_envelope(afterStop: true));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final trigger = find.descendant(
      of: find.byType(EnvelopeTrigger),
      matching: find.byType(DecoratedBox),
    );
    final ring =
        tester.widget<DecoratedBox>(trigger).decoration as BoxDecoration;
    expect(ring.border, isNotNull);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(find.text('Dear Ada,'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'reply');
  });

  testWidgets('a narrow front shrinks the address instead of overflowing', (
    tester,
  ) async {
    Widget sized(double width) => componentHost(
      Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width,
          child: const Envelope(
            seed: 'narrow',
            children: [
              EnvelopeFront(
                children: [
                  EnvelopeAddress(
                    children: [
                      Text('Mr. Charles Babbage'),
                      Text('1 Dorset Street, Marylebone'),
                      Text('London'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    double fontSize() =>
        tester
            .widget<DefaultTextStyle>(
              find
                  .ancestor(
                    of: find.text('London'),
                    matching: find.byType(DefaultTextStyle),
                  )
                  .first,
            )
            .style
            .fontSize ??
        0;

    await tester.pumpWidget(sized(384));
    final full = fontSize();
    await tester.pumpWidget(sized(200));
    expect(tester.takeException(), isNull);
    expect(fontSize(), closeTo(full * 0.8, 0.01));
  });

  testWidgets('sealed: the trigger does nothing', (tester) async {
    final changes = <bool>[];
    await tester.pumpWidget(
      _envelope(disabled: true, openOnHover: true, onOpenChange: changes.add),
    );
    await tester.tap(find.byType(EnvelopeTrigger), warnIfMissed: false);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.byType(EnvelopeTrigger)));
    await tester.pump();
    expect(changes, isEmpty);
  });

  testWidgets('hover lifts the flap; openOnHover opens and closes', (
    tester,
  ) async {
    final changes = <bool>[];
    await tester.pumpWidget(
      _envelope(openOnHover: true, onOpenChange: changes.add),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.byType(EnvelopeTrigger)));
    await tester.pump();
    expect(_back(tester), containsAll({InkState.hovered, InkState.open}));
    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    expect(changes, [true, false]);
    await mouse.moveTo(tester.getCenter(find.byType(EnvelopeTrigger)));
    await tester.pump();
    await tester.tap(find.byType(EnvelopeTrigger));
    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    expect(changes, [true, false, true]);
    expect(find.text('Dear Ada,'), findsOneWidget);
  });

  testWidgets('the trigger is a named button with its expanded state', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_envelope());
    expect(
      tester.getSemantics(find.byType(EnvelopeTrigger)),
      matchesSemantics(
        label: 'Read the letter',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasExpandedState: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    await tester.tap(find.byType(EnvelopeTrigger));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.byType(EnvelopeTrigger)),
      matchesSemantics(
        label: 'Read the letter',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasExpandedState: true,
        isExpanded: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('the front draws stamp params from the envelope', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const Envelope(
          stamp: null,
          airmail: true,
          seed: 'e',
          children: [EnvelopeFront()],
        ),
      ),
    );
    final front = tester
        .widgetList<InkSurface>(find.byType(InkSurface))
        .firstWhere((surface) => surface.seed == 'e|front');
    final params = (front.source as RecipeInkSource).params;
    expect(params, isA<EnvelopeFrontParams>());
    expect((params as EnvelopeFrontParams).toJson(), {
      'stock': 'kraft',
      'stamp': 'none',
      'postmark': false,
      'airmail': true,
    });
  });
}
