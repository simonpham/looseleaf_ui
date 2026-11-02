import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Widget _tabs({
  ValueChanged<String>? onValueChange,
  TabsActivationMode mode = TabsActivationMode.automatic,
  TabsOrientation orientation = TabsOrientation.horizontal,
  List<FocusNode> nodes = const [],
}) => Tabs(
  defaultValue: 'a',
  onValueChange: onValueChange,
  activationMode: mode,
  orientation: orientation,
  children: [
    TabsList(
      children: [
        for (final (index, name) in ['a', 'b', 'c'].indexed)
          TabsTrigger(
            value: name,
            disabled: name == 'b',
            focusNode: switch (index < nodes.length) {
              true => nodes[index],
              false => null,
            },
            child: Text('Tab $name'),
          ),
      ],
    ),
    for (final name in ['a', 'b', 'c'])
      TabsContent(value: name, child: Text('Panel $name')),
  ],
);

List<FocusNode> _nodes(WidgetTester tester) {
  final nodes = [for (var i = 0; i < 3; i++) FocusNode()];
  for (final node in nodes) {
    addTearDown(node.dispose);
  }
  return nodes;
}

void main() {
  testWidgets('a tap opens its panel; disabled tabs do not', (tester) async {
    final opened = <String>[];
    await tester.pumpWidget(componentHost(_tabs(onValueChange: opened.add)));
    expect(find.text('Panel a'), findsOneWidget);
    await tester.tap(find.text('Tab c'));
    await tester.pumpAndSettle();
    expect(find.text('Panel a'), findsNothing);
    expect(find.text('Panel c'), findsOneWidget);
    await tester.tap(find.text('Tab b'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(opened, ['c']);
  });

  testWidgets('arrows skip disabled tabs and open them automatically', (
    tester,
  ) async {
    final nodes = _nodes(tester);
    await tester.pumpWidget(componentHost(_tabs(nodes: nodes)));
    nodes[0].requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(nodes[2].hasFocus, isTrue);
    expect(find.text('Panel c'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(find.text('Panel a'), findsOneWidget);
  });

  testWidgets('manual activation waits for Enter', (tester) async {
    final nodes = _nodes(tester);
    await tester.pumpWidget(
      componentHost(_tabs(nodes: nodes, mode: TabsActivationMode.manual)),
    );
    nodes[0].requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('Panel a'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Panel c'), findsOneWidget);
  });

  testWidgets('vertical tabs move with up and down', (tester) async {
    final nodes = _nodes(tester);
    await tester.pumpWidget(
      componentHost(
        _tabs(nodes: nodes, orientation: TabsOrientation.vertical),
      ),
    );
    nodes[0].requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(find.text('Panel c'), findsOneWidget);
  });

  testWidgets('the active folder tab lifts 2 and checks its drawing', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(_tabs()));
    await tester.pumpAndSettle();
    final surfaces = tester
        .widgetList<InkSurface>(find.byType(InkSurface))
        .toList();
    expect(surfaces[0].states, contains(InkState.checked));
    expect(surfaces[2].states, isNot(contains(InkState.checked)));
    expect(surfaces.every((surface) => surface.swipeOnCheck), isTrue);
    final a = tester.getRect(find.byType(InkSurface).at(0));
    final c = tester.getRect(find.byType(InkSurface).at(2));
    expect(c.top - a.top, 2);
    expect(a.height, 36);
  });

  testWidgets('semantics: a tab bar of tabs and a panel', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(_tabs()));
    expect(
      tester.getSemantics(find.byType(TabsTrigger).first),
      isSemantics(label: 'Tab a', isSelected: true, isButton: false),
    );
    handle.dispose();
  });

  testWidgets('a list wider than its parent scrolls to the focused tab', (
    tester,
  ) async {
    final names = [for (var i = 0; i < 12; i++) 'tab$i'];
    final first = FocusNode();
    addTearDown(first.dispose);
    await tester.pumpWidget(
      componentHost(
        SizedBox(
          width: 240,
          child: Tabs(
            defaultValue: names.first,
            children: [
              TabsList(
                children: [
                  for (final (index, name) in names.indexed)
                    TabsTrigger(
                      value: name,
                      focusNode: switch (index) {
                        0 => first,
                        _ => null,
                      },
                      child: Text('Tab $name'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(TabsList)).width, 240);
    first.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    final list = tester.getRect(find.byType(TabsList));
    final last = tester.getRect(find.text('Tab tab11'));
    expect(last.right, lessThanOrEqualTo(list.right));
    expect(last.left, greaterThanOrEqualTo(list.left));
  });
}
