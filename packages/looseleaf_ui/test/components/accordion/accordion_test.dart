import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Widget _accordion({
  AccordionType type = AccordionType.single,
  bool collapsible = false,
  Set<String> defaultValue = const {},
  ValueChanged<Set<String>>? onValueChange,
  List<FocusNode> focusNodes = const [],
  Set<String> disabledItems = const {},
}) => SizedBox(
  width: 400,
  child: Accordion(
    type: type,
    collapsible: collapsible,
    defaultValue: defaultValue,
    onValueChange: onValueChange,
    children: [
      for (final (index, name) in ['a', 'b', 'c'].indexed)
        AccordionItem(
          value: name,
          disabled: disabledItems.contains(name),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AccordionTrigger(
                focusNode: switch (index < focusNodes.length) {
                  true => focusNodes[index],
                  false => null,
                },
                child: Text('Trigger $name'),
              ),
              AccordionContent(child: Text('Content $name')),
            ],
          ),
        ),
    ],
  ),
);

void main() {
  testWidgets('single opens one item at a time', (tester) async {
    final values = <Set<String>>[];
    await tester.pumpWidget(
      componentHost(
        _accordion(defaultValue: {'a'}, onValueChange: values.add),
      ),
    );
    expect(find.text('Content a'), findsOneWidget);
    await tester.tap(find.text('Trigger b'));
    await tester.pumpAndSettle();
    expect(find.text('Content a'), findsNothing);
    expect(find.text('Content b'), findsOneWidget);
    await tester.tap(find.text('Trigger b'));
    await tester.pumpAndSettle();
    expect(find.text('Content b'), findsOneWidget);
    expect(values, [
      {'b'},
    ]);
  });

  testWidgets('collapsible lets the open item shut', (tester) async {
    await tester.pumpWidget(
      componentHost(_accordion(collapsible: true, defaultValue: {'a'})),
    );
    await tester.tap(find.text('Trigger a'));
    await tester.pumpAndSettle();
    expect(find.text('Content a'), findsNothing);
  });

  testWidgets('multiple opens any', (tester) async {
    await tester.pumpWidget(
      componentHost(_accordion(type: AccordionType.multiple)),
    );
    await tester.tap(find.text('Trigger a'));
    await tester.tap(find.text('Trigger c'));
    await tester.pumpAndSettle();
    expect(find.text('Content a'), findsOneWidget);
    expect(find.text('Content c'), findsOneWidget);
  });

  testWidgets('arrows, Home and End move between triggers', (tester) async {
    final nodes = [for (var i = 0; i < 3; i++) FocusNode()];
    for (final node in nodes) {
      addTearDown(node.dispose);
    }
    await tester.pumpWidget(
      componentHost(_accordion(focusNodes: nodes, disabledItems: {'b'})),
    );
    nodes[0].requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(nodes[2].hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(nodes[0].hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(nodes[2].hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(nodes[0].hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Content a'), findsOneWidget);
  });

  testWidgets('a disabled item ignores taps and reads disabled', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(_accordion(disabledItems: {'b'})));
    await tester.tap(find.text('Trigger b'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Content b'), findsNothing);
    expect(
      tester.getSemantics(find.text('Trigger a')),
      matchesSemantics(
        label: 'Trigger a',
        isButton: true,
        hasExpandedState: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('rules sit under every item but the last', (tester) async {
    await tester.pumpWidget(componentHost(_accordion()));
    final rules = find.byWidgetPredicate(
      (widget) =>
          widget is InkSurface && widget.source.id.startsWith('accordion-rule'),
    );
    expect(rules, findsNWidgets(2));
  });

  testWidgets('trigger padding follows density', (tester) async {
    for (final (density, padding) in [
      (LooseleafDensity.comfortable, 14.0),
      (LooseleafDensity.compact, 10.0),
      (LooseleafDensity.calm, 8.0),
    ]) {
      await tester.pumpWidget(
        componentHost(
          _accordion(),
          theme: LooseleafThemeData(density: density),
        ),
      );
      expect(
        tester.getTopLeft(find.text('Trigger a')).dy -
            tester.getTopLeft(find.byType(AccordionTrigger).first).dy,
        closeTo(padding, 0.01),
      );
    }
  });

  testWidgets('the brace draws on only after the user opens a row', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(_accordion(defaultValue: {'a'})));
    expect(
      tester
          .widget<CollapsibleBracket>(find.byType(CollapsibleBracket))
          .animate,
      isFalse,
    );
    await tester.tap(find.text('Trigger b'));
    await tester.pump();
    expect(
      tester
          .widget<CollapsibleBracket>(find.byType(CollapsibleBracket).last)
          .animate,
      isTrue,
    );
    await tester.pumpAndSettle();
  });

  testWidgets('an item can hide its rule; a trigger takes its own room', (
    tester,
  ) async {
    Widget item(String name, {bool showRule = true}) => AccordionItem(
      value: name,
      showRule: showRule,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AccordionTrigger(
            minHeight: Spacing.d56,
            padding: const EdgeInsets.only(top: Spacing.d28),
            crossAxisAlignment: CrossAxisAlignment.end,
            child: Text('Trigger $name'),
          ),
          AccordionContent(
            padding: EdgeInsets.zero,
            child: Text('Content $name'),
          ),
        ],
      ),
    );
    await tester.pumpWidget(
      componentHost(
        SizedBox(
          width: 400,
          child: Accordion(
            children: [item('a', showRule: false), item('b')],
          ),
        ),
      ),
    );
    final rules = find.byWidgetPredicate(
      (widget) => widget.runtimeType.toString() == '_Rule',
    );
    expect(rules, findsNothing);
    final trigger = tester.getRect(find.byType(AccordionTrigger).first);
    expect(trigger.height, Spacing.d56);
    expect(trigger.bottom, tester.getRect(find.text('Trigger a')).bottom);
    await tester.pumpWidget(
      componentHost(
        SizedBox(
          width: 400,
          child: Accordion(children: [item('a'), item('b')]),
        ),
      ),
    );
    expect(rules, findsOneWidget);
  });
}
