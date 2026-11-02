import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Widget _ticket({
  bool? torn,
  ValueChanged<bool>? onTornChange,
  VoidCallback? onTear,
  bool disabled = false,
  Axis orientation = Axis.horizontal,
  FocusNode? focusNode,
  LooseleafThemeData theme = const LooseleafThemeData(),
}) => componentHost(
  TearOff(
    torn: torn,
    onTornChange: onTornChange,
    onTear: onTear,
    disabled: disabled,
    orientation: orientation,
    tornMessage: 'Coupon torn off.',
    children: [
      const TearOffBody(width: 200, child: Text('Studio night')),
      TearOffStub(
        width: 120,
        label: 'Tear off the coupon',
        focusNode: focusNode,
        children: const [Text('10% off')],
      ),
    ],
  ),
  theme: theme,
);

bool _torn(WidgetTester tester) =>
    TearOffScope.of(tester.element(find.byType(TearOffBody))).torn;

void main() {
  testWidgets('a tap tears the stub off and it leaves the layout', (
    tester,
  ) async {
    final changes = <bool>[];
    var tears = 0;
    await tester.pumpWidget(
      _ticket(onTornChange: changes.add, onTear: () => tears++),
    );
    expect(tester.getSize(find.byType(TearOff)).width, 320);
    await tester.tap(find.text('10% off'));
    await tester.pump();
    expect(changes, [true]);
    expect(tears, 1);
    expect(_torn(tester), isTrue);
    expect(find.text('10% off'), findsOneWidget);
    await tester.pump(TearOff.fall);
    expect(find.text('10% off'), findsNothing);
    expect(tester.getSize(find.byType(TearOff)).width, 200);
    await tester.tap(find.text('Studio night'));
    expect(tears, 1);
  });

  testWidgets('the edges are perforated, then torn', (tester) async {
    await tester.pumpWidget(_ticket());
    EdgeSpec? edge(Type part) => tester
        .widget<Paper>(
          find.descendant(of: find.byType(part), matching: find.byType(Paper)),
        )
        .edge;
    expect(edge(TearOffBody)?.right, EdgeKind.perf);
    expect(edge(TearOffStub)?.left, EdgeKind.perf);
    await tester.pumpWidget(_ticket(torn: true));
    expect(edge(TearOffBody)?.right, EdgeKind.torn);
    await tester.pumpWidget(_ticket(orientation: Axis.vertical));
    expect(edge(TearOffBody)?.bottom, EdgeKind.perf);
    expect(edge(TearOffStub)?.top, EdgeKind.perf);
  });

  testWidgets('Enter tears it and focus stays on the ticket', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(_ticket(focusNode: focus));
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(_torn(tester), isTrue);
    final primary = FocusManager.instance.primaryFocus;
    expect(primary?.debugLabel, 'TearOff');
  });

  testWidgets('Space tears it too', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(_ticket(focusNode: focus));
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(_torn(tester), isTrue);
  });

  testWidgets('a pull past half way tears, a short one springs back', (
    tester,
  ) async {
    await tester.pumpWidget(_ticket());
    final stub = tester.getCenter(find.byType(TearOffStub));
    final short = await tester.startGesture(stub);
    await short.moveBy(const Offset(20, 0));
    await tester.pump();
    await short.up();
    await tester.pumpAndSettle();
    expect(_torn(tester), isFalse);

    final long = await tester.startGesture(stub);
    await long.moveBy(const Offset(10, 0));
    await long.moveBy(const Offset(40, 0));
    await tester.pump();
    await long.up();
    await tester.pump();
    expect(_torn(tester), isTrue);
    await tester.pumpAndSettle();
  });

  testWidgets('a pull the wrong way does nothing', (tester) async {
    await tester.pumpWidget(_ticket());
    final stub = tester.getCenter(find.byType(TearOffStub));
    final pull = await tester.startGesture(stub);
    await pull.moveBy(const Offset(-80, 0));
    await pull.up();
    await tester.pumpAndSettle();
    expect(_torn(tester), isFalse);
  });

  testWidgets('disabled keeps the stub on', (tester) async {
    await tester.pumpWidget(_ticket(disabled: true));
    await tester.tap(find.text('10% off'));
    await tester.pump();
    expect(_torn(tester), isFalse);
  });

  testWidgets('the stub is a described button; torn, a status speaks', (
    tester,
  ) async {
    await tester.pumpWidget(_ticket());
    expect(
      tester.getSemantics(find.bySemanticsLabel(RegExp('Tear off the'))),
      matchesSemantics(
        label: 'Tear off the coupon\n10% off',
        hint: TearOffStub.help,
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    await tester.pumpWidget(_ticket(torn: true));
    await tester.pump();
    expect(find.bySemanticsLabel('Coupon torn off.'), findsOneWidget);
    final hidden = tester.widget<ExcludeSemantics>(
      find
          .descendant(
            of: find.byType(TearOffStub),
            matching: find.byType(ExcludeSemantics),
          )
          .first,
    );
    expect(hidden.excluding, isTrue);
  });

  testWidgets('putting it back drops it in', (tester) async {
    await tester.pumpWidget(_ticket(torn: true));
    await tester.pump(TearOff.fall);
    expect(find.text('10% off'), findsNothing);
    await tester.pumpWidget(_ticket(torn: false));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('10% off'), findsOneWidget);
    final opacity = tester.widgetList<Opacity>(
      find.ancestor(of: find.text('10% off'), matching: find.byType(Opacity)),
    );
    expect(opacity.any((widget) => widget.opacity < 1), isTrue);
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion removes it at once', (tester) async {
    await tester.pumpWidget(
      _ticket(theme: const LooseleafThemeData(motion: LooseleafMotion.reduced)),
    );
    await tester.tap(find.text('10% off'));
    await tester.pump(Duration.zero);
    await tester.pump();
    expect(find.text('10% off'), findsNothing);
  });

  testWidgets('side by side, the body gives way to a narrow parent', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 260,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: TearOff(
              children: [
                TearOffBody(width: 200, child: Text('Studio night')),
                TearOffStub(width: 120, children: [Text('10% off')]),
              ],
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(TearOffBody)).width, 140);
    expect(tester.getSize(find.byType(TearOffStub)).width, 120);
  });

  testWidgets('a wide parent still measures the body at its own width', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const TearOff(
          children: [
            TearOffBody(
              width: 150,
              child: Text('Bakery of the month, one croissant, warm, any day'),
            ),
            TearOffStub(width: 100, children: [Text('free')]),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(TearOffBody)).width, 150);
  });
}
