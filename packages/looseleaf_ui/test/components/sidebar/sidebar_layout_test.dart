import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1024, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(componentHost(child));
  await tester.pumpAndSettle();
}

Widget _row(String label) => SidebarMenuItem(
  child: SidebarMenuButton(onPressed: () {}, child: Text(label)),
);

void main() {
  testWidgets('a menu sets its rows the gap apart, 4 px by default', (
    tester,
  ) async {
    for (final (gap, expected) in [(null, Spacing.d4), (Spacing.d8, 8.0)]) {
      await _pump(
        tester,
        SizedBox(
          width: 240,
          child: switch (gap) {
            final gap? => SidebarMenu(
              gap: gap,
              children: [_row('A'), _row('B')],
            ),
            null => SidebarMenu(children: [_row('A'), _row('B')]),
          },
        ),
      );
      final first = tester.getRect(find.byType(SidebarMenuButton).first);
      final second = tester.getRect(find.byType(SidebarMenuButton).last);
      expect(second.top - first.bottom, expected);
    }
  });

  testWidgets('a group takes its padding, 8 px all round by default', (
    tester,
  ) async {
    for (final (padding, inset) in [
      (null, const EdgeInsets.all(Spacing.d8)),
      (
        const EdgeInsets.symmetric(vertical: Spacing.d8),
        const EdgeInsets.symmetric(vertical: Spacing.d8),
      ),
    ]) {
      const label = SizedBox(key: Key('label'), height: 20);
      await _pump(
        tester,
        SizedBox(
          width: 240,
          child: switch (padding) {
            final padding? => SidebarGroup(
              padding: padding,
              children: const [label],
            ),
            null => const SidebarGroup(children: [label]),
          },
        ),
      );
      final group = tester.getRect(find.byType(SidebarGroup));
      final child = tester.getRect(find.byKey(const Key('label')));
      expect(child.left - group.left, inset.left);
      expect(child.top - group.top, inset.top);
    }
  });

  testWidgets('a badge leaves room at the end of the label, like an action', (
    tester,
  ) async {
    final ends = <double>[];
    for (final badge in [false, true]) {
      await _pump(
        tester,
        SizedBox(
          width: 240,
          child: SidebarMenu(
            children: [
              SidebarMenuItem(
                badge: switch (badge) {
                  true => const SidebarMenuBadge(child: Text('3')),
                  false => null,
                },
                child: SidebarMenuButton(
                  onPressed: () {},
                  child: const SizedBox(key: Key('label'), height: 10),
                ),
              ),
            ],
          ),
        ),
      );
      ends.add(tester.getRect(find.byKey(const Key('label'))).right);
    }
    expect(ends.first - ends.last, Spacing.d32 - Spacing.d8);
  });

  testWidgets('a leading action sits over the icon, filled with the pad', (
    tester,
  ) async {
    var folds = 0;
    await _pump(
      tester,
      SizedBox(
        width: 240,
        child: SidebarMenu(
          children: [
            SidebarMenuItem(
              leadingAction: SidebarMenuAction(
                fill: true,
                semanticLabel: 'Fold',
                onPressed: () => folds++,
                child: const SizedBox(key: Key('chevron'), width: 16),
              ),
              action: SidebarMenuAction(
                semanticLabel: 'Add',
                onPressed: () {},
                child: const SizedBox(width: 16),
              ),
              child: SidebarMenuButton(
                onPressed: () {},
                leading: const SizedBox(
                  key: Key('icon'),
                  width: 16,
                  height: 16,
                ),
                child: const Text('Notes'),
              ),
            ),
          ],
        ),
      ),
    );
    final button = tester.getRect(find.byType(SidebarMenuButton));
    Finder action(String label) => find.byWidgetPredicate(
      (widget) => widget is SidebarMenuAction && widget.semanticLabel == label,
    );
    final leading = tester.getRect(action('Fold'));
    expect(leading.left - button.left, Spacing.d4);
    expect(leading.center.dy, button.center.dy);
    expect(
      leading.overlaps(tester.getRect(find.byKey(const Key('icon')))),
      isTrue,
    );
    expect(
      tester.getRect(action('Add')).right,
      button.right - Spacing.d4,
    );
    expect(
      find.descendant(
        of: action('Fold'),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is ColoredBox &&
              widget.color == const LooseleafThemeData().colors.pad,
        ),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('chevron')));
    expect(folds, 1);
  });

  testWidgets('a fit-width button hugs its content at the row start', (
    tester,
  ) async {
    await _pump(
      tester,
      SizedBox(
        width: 240,
        child: SidebarMenu(
          children: [
            SidebarMenuItem(
              child: SidebarMenuButton(
                fitWidth: true,
                onPressed: () {},
                leading: const SizedBox(width: 16, height: 16),
                trailing: const SizedBox(key: Key('chevron'), width: 16),
                child: const SizedBox(width: 60, height: 10),
              ),
            ),
          ],
        ),
      ),
    );
    final menu = tester.getRect(find.byType(SidebarMenu));
    final button = tester.getRect(find.byType(InkInteraction));
    expect(button.left, menu.left);
    expect(button.width, Spacing.d8 * 4 + 16 + 60 + 16);
    expect(
      tester.getRect(find.byKey(const Key('chevron'))).right,
      button.right - Spacing.d8,
    );
  });
}
